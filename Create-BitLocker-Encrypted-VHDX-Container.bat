@echo off
set VDISK_NAME=%RANDOM%
rem ask where to store this.
set DISKFILE=%temp%\virtualdisk-new-%VDISK_NAME%.vhdx
rem ask
set DISKSIZE=1000
rem check if available.
set DRIVELETTER=V

rem Check for Admin-Rights
cd /d %~dp0
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo. ERROR! Can not run without Administrator-Permissions!
	echo.
    echo. Start this script with "Run as Administrator ..."
	echo.
	pause
	exit 1
) 

rem Create a diskpart-Script in TEMP-Directory
set DISKPARTSCRIPT=%TEMP%\diskpart-script.txt

rem Create a new VHDX-File and attach it to the System als virtual Disk
echo create vdisk file="%DISKFILE%" maximum=%DISKSIZE% type=expandable >"%DISKPARTSCRIPT%"
echo select vdisk file="%DISKFILE%" >>"%DISKPARTSCRIPT%"
echo attach vdisk >>"%DISKPARTSCRIPT%"
rem echo convert MBR >>"%DISKPARTSCRIPT%"

rem Create a Partition as "Recovery Partition" to avoid automatically mounting
echo create partition primary ID=27 >>"%DISKPARTSCRIPT%"

rem Format the Partition, using NTFS Filesystem
echo format FS=NTFS Label="vDisk-%VDISK_NAME%" QUICK >>"%DISKPARTSCRIPT%"

rem Now after formating the Partition change ID from "Recovery Partition" to regular Data-Partition exFAT ID7 for mounting
rem echo set ID=07 >>"%DISKPARTSCRIPT%"

rem Assign a Drive Letter
echo assign letter=%DRIVELETTER% >>"%DISKPARTSCRIPT%"

rem Run the created Diskpart-Script
diskpart /s "%DISKPARTSCRIPT%"

if not "%ERRORLEVEL%" == "0" goto end
echo.
echo.
echo Virtual Disk "%DISKFILE%" created
echo.
echo To apply Bitlocker encryption press Space - or close this Script to leave partition in plaintext
echo.
pause

rem Apply Bitlocker Encryption
rem https://learn.microsoft.com/en-us/windows/win32/secprov/getencryptionmethod-win32-encryptablevolume
manage-bde.exe -on %DRIVELETTER%: -UsedSpaceOnly -Password -Encryptionmethod XtsAes256

:end
pause
