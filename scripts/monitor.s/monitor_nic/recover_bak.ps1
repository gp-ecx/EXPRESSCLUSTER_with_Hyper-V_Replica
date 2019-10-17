<#
function MakePSCredential($ID, $PlainPassword){
    $SecurePassword = ConvertTo-SecureString -String $PlainPassword -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($ID, $SecurePassword)
    Return $Credential
}
#>

$group = $env:FAILOVER_NAME
$active_srv = clpgrp -n $group
$host_name = hostname

if ($host_name -eq $active_srv) {
#    Write-Output $active_srv >> .\test.txt
    exit 0
}


#Set-ExecutionPolicy -Scope LocalMachine RemoteSigned -Force

$user = "Administrator"
<#
$pass = "Clusterpr0"

$cred = MakePSCredential $user $pass
#>

$pass = ".\pass"
$secpass = cat $pass | ConvertTo-SecureString -Key (1..16)
$cred = New-Object System.Management.Automation.PSCredential($user, $secpass)

#$ret = Start-Process Powershell -Credential $cred -ArgumentList '-File .\recover_nic.ps1' *>> .\start_process.txt
#$ret = Start-Process Powershell -ArgumentList '-File .\recover_nic.ps1' *>> .\start_process.txt
armload "NICRECOVERY" /U $user /W powershell.exe .\recover_nic.ps1
armkill "NICRECOVERY"

#Get-ExecutionPolicy -List >> .\policy.txt
