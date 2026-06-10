@echo off
chcp 65001 >nul 2>&1

set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "BACKUP_ROOT=%~dp0backup"

:: 로그 파일
set "LOG=%~dp0backup_log.txt"
echo [%date% %time%] 백업 시작 >> "%LOG%"

tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo [%date% %time%] 크롬 종료됨 >> "%LOG%"
)

if not exist "%BACKUP_ROOT%" mkdir "%BACKUP_ROOT%"

xcopy "%CHROME_USER_DATA%\Default" "%BACKUP_ROOT%\Default" /E /C /I /Y /H /Q >nul
if %errorlevel% neq 0 (
    echo [%date% %time%] 백업 실패! >> "%LOG%"
    exit /b 1
)

copy /Y "%CHROME_USER_DATA%\Local State" "%BACKUP_ROOT%\Local State" >nul

echo [%date% %time%] 백업 완료 >> "%LOG%"
exit /b 0
