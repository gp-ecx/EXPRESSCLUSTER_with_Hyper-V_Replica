cd "C:\Program Files\CLUSTERPRO\work\trnreq"
call .\cluster_config.bat
armload REPREXEC /U Administrator /W Powershell.exe .\recover.ps1
armkill REPREXEC