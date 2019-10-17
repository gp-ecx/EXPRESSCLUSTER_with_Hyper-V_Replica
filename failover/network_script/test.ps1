$line = "root@"
$line = $line + "192.168.145.10"
ssh -q -o StrictHostKeyChecking=no $line "nmcli c up eth1"