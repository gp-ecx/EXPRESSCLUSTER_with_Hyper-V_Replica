rem ***************************************
rem *               genw.bat              *
rem ***************************************
rem ***************************************
rem *               genw.bat              *
rem ***************************************

cd "C:\Program Files\CLUSTERPRO\scripts\monitor.s\monitor_replica
call .\cluster_config.bat
armload REPRECOVER /U Administrator /W Powershell.exe .\recover.ps1
armkill REPRECOVER

set ret=%ERRORLEVEL%
echo %ret%