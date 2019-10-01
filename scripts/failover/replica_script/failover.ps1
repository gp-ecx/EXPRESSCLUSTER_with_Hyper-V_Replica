$hostname = hostname
$targetVMName = $env:TARGET_VM_NAME
$primaryHostname =  $env:PRIMARY_HOSTNAME
$secondaryHostname =  $env:SECONDARY_HOSTNAME

$VMRepInfo = Get-VMReplication -VMName $targetVMName
$primaryFQDN = $VMRepInfo.PrimaryServer
$secondaryFQDN = $VMRepInfo.ReplicaServer

$tmp = "CN=" + $primaryFQDN
$tmp = ls cert:\LocalMachine\My | Where-Object {$_.Subject -eq $tmp}
$primaryThumbprint = $tmp.Thumbprint
$tmp = "CN=" + $secondaryFQDN
$tmp = ls cert:\LocalMachine\My | Where-Object {$_.Subject -eq $tmp}
$secondaryThumbprint = $tmp.Thumbprint

Start-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Complete-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Start-VM -VMName $targetVMName -Confirm:$False