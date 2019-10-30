#
# Oct 30 2019
#

$targetVMName = $env:TARGET_VM_NAME

$VMRepInfo = Get-VMReplication -VMName $targetVMName
$primaryFQDN = $VMRepInfo.PrimaryServer

set-vmreplication -VMName $targetVMName -AsReplica -ComputerName $primaryFQDN

sleep -s 3