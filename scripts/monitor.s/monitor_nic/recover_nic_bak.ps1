$host_name = hostname
$VMName = "RouterVM_template"
$primaryHostname =  $env:PRIMARY_HOSTNAME
$primaryIp = $env:PRIMARY_IP_ADDRESS
$secondaryHostname =  $env:SECONDARY_HOSTNAME
$secondaryIp = $env:SECONDARY_IP_ADDRESS
#$line = "root@192.168.146.10"
#Write-Output $host_name >> .\test.txt
#Write-Output $primaryIp >> .\test.txt
#Write-Output $secondaryIp >> .\test.txt
if ($host_name -eq $primaryHostname) {
    $line = "root@" + $primaryIp
} elseif ($host_name -eq $secondaryHostname) {
    $line = "root@" + $secondaryIp
}

ssh -t $line "nmcli c down eth1"
