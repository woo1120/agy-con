@echo off
chcp 65001 >nul 2>&1

set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "BACKUP_ROOT=%~dp0backup"

:: 로그 파일
set "LOG=%~dp0restore_log.txt"
echo [%date% %time%] 복원 시작 >> "%LOG%"

if not exist "%BACKUP_ROOT%\Default" (
    echo [%date% %time%] 백업 없음 - 복원 건너뜀 >> "%LOG%"
    exit /b 1
)

tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo [%date% %time%] 크롬 종료됨 >> "%LOG%"
)

xcopy "%BACKUP_ROOT%\Default" "%CHROME_USER_DATA%\Default" /E /C /I /Y /H /Q >nul
if %errorlevel% neq 0 (
    echo [%date% %time%] 복원 실패! >> "%LOG%"
    exit /b 1
)

if exist "%BACKUP_ROOT%\Local State" (
    copy /Y "%BACKUP_ROOT%\Local State" "%CHROME_USER_DATA%\Local State" >nul
)

echo [%date% %time%] 복원 완료 >> "%LOG%"
exit /b 0
