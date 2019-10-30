#
# Oct 30 2019
#

$hostname = hostname
$group = $env:FAILOVER_NAME
$active_srv = clpgrp -n $group

$targetVMName = $env:TARGET_VM_NAME
$primaryHostname =  $env:PRIMARY_HOSTNAME
$secondaryHostname =  $env:SECONDARY_HOSTNAME
$primaryHostIp = $env:PRIMARY_HOST_IP_ADDRESS
$secondaryHostIp = $env:SECONDARY_HOST_IP_ADDRESS

#
# If primary server is shutdown and secondary server becomes active server,
# replication is stopped forcibly.
# Get-VMReplication server shows the below value.
# PrimaryServer: crashed server
# ReplicaServer: active server
#
$VMRepInfo = Get-VMReplication -VMName $targetVMName
$mode = $VMRepInfo.Mode
$primaryFQDN = $VMRepInfo.PrimaryServer
$secondaryFQDN = $VMRepInfo.ReplicaServer

#
# Get information of opposite server.
#
$tmpPNameList = $primaryFQDN.Split(".")
$tmpPName = $tmpPNameList[0]
$ownHostname = "null"
$ownFQDN = "null"
$ownIp = "null"
$oppositeHostname = "null"
$oppositeFQDN = "null"
$oppositeIp = "null"
if ($tmpPName -eq $primaryHostname) {
    if ($mode -eq "Primary") {
        $ownHostname = $primaryHostname
        $ownFQDN = $primaryFQDN
        $ownIp = $primaryHostIp
        $oppositeHostname = $secondaryHostname
        $oppositeFQDN = $secondaryFQDN
        $oppositeIp = $secondaryHostIp
    } else {
        $ownHostname = $secondaryHostname
        $ownFQDN = $secondaryFQDN
        $ownIp = $secondaryHostIp
        $oppositeHostname = $primaryHostname
        $oppositeFQDN = $primaryFQDN
        $oppositeIp = $primaryHostIp
    }
} else {
    if ($mode -eq "Primary") {
        $ownHostname = $secondaryHostname
        $ownFQDN = $primaryFQDN
        $ownIp = $secondaryHostIp
        $oppositeHostname = $primaryHostname
        $oppositeFQDN = $secondaryFQDN
        $oppositeIp = $primaryHostIp
    } else {
        $ownHostname = $primaryHostname
        $ownFQDN = $secondaryFQDN
        $ownIp = $primaryHostIp
        $oppositeHostname = $secondaryHostname
        $oppositeFQDN = $primaryFQDN
        $oppositeIp = $secondaryHostIp
    }
}


try {
    Start-VMFailover -VMName $targetVMName -ComputerName $ownFQDN -Confirm:$False
} catch {
    exit 1
}

try {
    Start-VM -VMName $targetVMName -Confirm:$False
} catch {
    exit 1
}