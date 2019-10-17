echo test > .\test.txt
call .\cluster_config.bat
Powershell -File .\start.ps1
