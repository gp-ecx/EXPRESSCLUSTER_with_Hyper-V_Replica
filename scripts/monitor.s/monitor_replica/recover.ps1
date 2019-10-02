$hostname = hostname
$group = $env:FAILOVER_NAME
$active_srv = clpgrp -n $group

#
# This script is executed only on active server.
#
if ($hostname -ne $active_srv) {
    exit 0
}

$targetVMName = $env:TARGET_VM_NAME
$primaryHostname =  $env:PRIMARY_HOSTNAME
$secondaryHostname =  $env:SECONDARY_HOSTNAME
$primaryHostIp = $env:PRIMARY_HOST_IP_ADDRESS
$secondaryHostIp = $env:SECONDARY_HOST_IP_ADDRESS

#
# If primary server is shutdown and secondary server becomes active server,
# replication is stopped forcibly.
# Get-VMReplication server shows the below value.
# PrimaryServer: crushed server
# ReplicaServer: active server
#
$VMRepInfo = Get-VMReplication -VMName $targetVMName
$primaryFQDN = $VMRepInfo.PrimaryServer
$secondaryFQDN = $VMRepInfo.ReplicaServer

#
# Get information of opposite server (crushed server).
#
$tmpPNameList = $primaryFQDN.Split(".")
$tmpPName = $tmpPNameList[0]
$oppositeHostname = "null"
$oppositeFQDN = "null"
$oppositeIp = "null"
if ($tmpPName -eq $primaryHostname) {
    $oppositeHostname = $primaryHostname
    $oppositeFQDN = $primaryFQDN
    $oppositeIp = $primaryHostIp
} else {
    $oppositeHostname = $secondaryHostname
    $oppositeFQDN = $secondaryFQDN
    $oppositeIp = $secondaryHostIp
}

#
# Get credential information of both servers.
#
$tmp = "CN=" + $primaryFQDN
$tmp = ls cert:\LocalMachine\My | Where-Object {$_.Subject -eq $tmp}
$primaryThumbprint = $tmp.Thumbprint
$tmp = "CN=" + $secondaryFQDN
$tmp = ls cert:\LocalMachine\My | Where-Object {$_.Subject -eq $tmp}
$secondaryThumbprint = $tmp.Thumbprint

#
# Check if opposite returns to a cluster.
#
$ret = ping $oppositeIp
if ($? -eq $False) {
    exit 0
}

#
# Check if cluster service is running on opposite server.
#
$ret = clprexec --script "check.bat" -h $oppositeIp
if ($? -eq $False) {
    exit 0
}

#
# Check if opposite server is waiting for VM replication.
#
try {
    $vmRepInfo = Get-VMReplication -VMName $targetVMName -ComputerName $primaryFQDN
} catch {
    exit 1
}
if ($vmRepInfo.State -eq "WaitingForStartResynchronize") {
    ##### Recover Process for Turned off situation #####
    try {
        clprexec --script "recover.bat" -h $oppositeIp
    } catch {
        exit 1
    }

    while (1) {
        $vmRepInfo = Get-VMReplication -VMName $targetVMName -ComputerName $primaryFQDN
        if ($vmRepInfo.State -eq "WaitingForInitialReplication") {
            Write-Output $vmRepInfo.State > .\repinfo2.txt
           break
        }
    }

    try {
        Set-VMReplication -VMName $targetVMName -Reverse -ReplicaServerName $primaryFQDN -ComputerName $secondaryFQDN -AuthenticationType "Certificate" -CertificateThumbprint $secondaryThumbprint -Confirm:$False
    } catch {
        exit 1
    }

    while (1) {
        $vmRepInfo = Get-VMReplication -VMName $targetVMName
        if ($vmRepInfo.State -eq "ReadyForInitialReplication") {
            Write-Output $vmRepInfo.State > .\repinfo3.txt
            break
        }
    }

    try {
        Start-VMInitialReplication -VMName $targetVMName -ComputerName $secondaryFQDN
    } catch {
        exit 1
    }


    while (1) {
        $vmRepInfo = Get-VMReplication -VMName $targetVMName
        sleep -s 5
        if ($vmRepInfo.State -eq "Replicating") {
            break
        }
    }
    exit 0
} elseif ($vmRepInfo.State -eq "Error") {
    ##### Recover Process for OS shutdown situation #####
    $vmRepInfo = Get-VMReplication -VMName $targetVMName
    if ($vmRepInfo.State -ne "FailedOverWaitingCompletion") {
        exit 1
    }

    try {
        Stop-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
    } catch {
        exit 1
    }

    try {
        Resume-VMReplication -VMName $targetVMName -ComputerName $primaryFQDN -Confirm:$False
    } catch {
        exit 1
    }

    try {
        Start-VM -Name $targetVMName -ComputerName $primaryFQDN -Confirm:$False
    } catch {
        exit 1
    }

    #
    # For consistency between ECX and Hyper-V Replica
    #
    clpgrp -m
    exit 0
} else {
    Write-Output $vmRepInfo.State > .\repinfo.txt
    exit 0
}
