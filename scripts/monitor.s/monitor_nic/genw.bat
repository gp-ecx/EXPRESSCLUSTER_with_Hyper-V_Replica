rem ***************************************
rem *               genw.bat              *
rem ***************************************
rem ***************************************
rem *               genw.bat              *
rem *              2019/10/28             *
rem ***************************************

cd "C:\Program Files\CLUSTERPRO\scripts\monitor.s\monitor_nic
call .\cluster_config.bat
armload NICRECOVER /U Administrator /W Powershell.exe .\recover.ps1
armkill NICRECOVER

set ret=%ERRORLEVEL%
echo %ret%