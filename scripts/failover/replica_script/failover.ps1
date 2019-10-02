$hostname = hostname
$group = $env:FAILOVER_NAME
$active_srv = clpgrp -n $group

$targetVMName = $env:TARGET_VM_NAME
$primaryHostname =  $env:PRIMARY_HOSTNAME
$secondaryHostname =  $env:SECONDARY_HOSTNAME
$primaryHostIp = $env:PRIMARY_HOST_IP_ADDRESS
$secondaryHostIp = $env:SECONDARY_HOST_IP_ADDRESS

#
# Get-VMReplication server shows the primary server and replica server
# of Hyper-V Replica
#
$VMRepInfo = Get-VMReplication -VMName $targetVMName
$primaryFQDN = $VMRepInfo.PrimaryServer
$secondaryFQDN = $VMRepInfo.ReplicaServer

#
# Get information of opposite server (crushed server).
# Check whether primary server of Hyper-V Replica and active server of ECX
# are same or not.
# If these server is same, no need to reverse replication.
#
$tmpPNameList = $primaryFQDN.Split(".")
$tmpPName = $tmpPNameList[0]
if ($tmpPName -eq $hostname) {
    $vmRepInfoP = Get-VMReplication -VMName $targetVMName -ComputerName $primaryFQDN
    $vmRepInfoS = Get-VMReplication -VMName $targetVMName -ComputerName $secondaryFQDN
    if ($vmRepInfoP.State -eq "Replicating" -And $vmRepInfoS.State -eq "Replicating") {
        exit 0
    }
    
    ### We have to add any codes here to support other uncosidered situation.
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
# Start VM on secondary server.
#
Start-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
# Complete-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Start-VM -VMName $targetVMName -Confirm:$False