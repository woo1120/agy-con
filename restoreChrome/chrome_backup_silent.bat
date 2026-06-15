@echo off
set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "SCRIPT_DIR=%~dp0"
set "BACKUP_DIR=%SCRIPT_DIR%backup"
set "LOG=%SCRIPT_DIR%backup_log.txt"

echo [%date% %time%] Backup started >> "%LOG%"

set "LOGIN_DATA=%CHROME_USER_DATA%\Default\Login Data"
if not exist "%LOGIN_DATA%" (
    echo [%date% %time%] SKIP - Login Data missing >> "%LOG%"
    exit /b 1
)
for %%A in ("%LOGIN_DATA%") do set "FSIZE=%%~zA"
if %FSIZE% LSS 51200 (
    echo [%date% %time%] SKIP - Login Data %FSIZE% bytes, wiped state >> "%LOG%"
    exit /b 1
)

tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
)

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

xcopy "%CHROME_USER_DATA%\Default" "%BACKUP_DIR%\Default" /E /C /I /Y /H /Q >nul
if %errorlevel% neq 0 (
    echo [%date% %time%] FAIL - xcopy error >> "%LOG%"
    exit /b 1
)

copy /Y "%CHROME_USER_DATA%\Local State" "%BACKUP_DIR%\Local State" >nul

echo [%date% %time%] Backup OK (%FSIZE% bytes) >> "%LOG%"
exit /b 0
