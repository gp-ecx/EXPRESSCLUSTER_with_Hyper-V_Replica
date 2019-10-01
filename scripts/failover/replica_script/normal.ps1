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
<#
Stop-VM $targetVMName -ComputerName $primaryFQDN -Confirm:$False -Force
Start-VMFailover -VMName $targetVMName -ComputerName $primaryFQDN -Prepare -Confirm:$False
Start-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Complete-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Start-VM -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False
Set-VMReplication -VMName $targetVMName -Reverse -ReplicaServerName $primaryFQDN -ComputerName $secondaryFQDN -AuthenticationType "Certificate" -CertificateThumbprint $secondaryThumbprint -Confirm:$False
#>
Stop-VM $targetVMName -ComputerName $primaryFQDN -Confirm:$False -Force *> .\stopvm.txt
while (1) {
    $vmState = (Get-VM -Name $targetVMName -ComputerName $primaryFQDN).State
    sleep -s 5
    if ($vmState -eq "Off") {
        break
    }
}

Start-VMFailover -VMName $targetVMName -ComputerName $primaryFQDN -Prepare -Confirm:$False *> .\startvmfailoverp.txt
Start-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False *> .\startvmfailovers.txt
Complete-VMFailover -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False *> .\completevmfailover.txt
Set-VMReplication -VMName $targetVMName -Reverse -ReplicaServerName $primaryFQDN -ComputerName $secondaryFQDN -AuthenticationType "Certificate" -CertificateThumbprint $secondaryThumbprint -Confirm:$False *> setvmreplication.txt
Start-VM -VMName $targetVMName -ComputerName $secondaryFQDN -Confirm:$False *> .\startvm.txt