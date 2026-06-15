@echo off
set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "SCRIPT_DIR=%~dp0"
set "BACKUP_DIR=%SCRIPT_DIR%backup\Default"
set "BACKUP_LS=%SCRIPT_DIR%backup\Local State"
set "LOG=%SCRIPT_DIR%restore_log.txt"

echo [%date% %time%] Restore started >> "%LOG%"

if not exist "%BACKUP_DIR%" (
    echo [%date% %time%] SKIP - no backup found >> "%LOG%"
    exit /b 1
)

tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo [%date% %time%] Chrome killed >> "%LOG%"
)

xcopy "%BACKUP_DIR%" "%CHROME_USER_DATA%\Default" /E /C /I /Y /H /Q >nul
if %errorlevel% neq 0 (
    echo [%date% %time%] FAIL - xcopy error >> "%LOG%"
    exit /b 1
)

if exist "%BACKUP_LS%" (
    copy /Y "%BACKUP_LS%" "%CHROME_USER_DATA%\Local State" >nul
)

echo [%date% %time%] Restore OK >> "%LOG%"
exit /b 0
