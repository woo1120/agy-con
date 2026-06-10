@echo off
chcp 65001 >nul 2>&1
title 크롬 프로필 복원

set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "BACKUP_ROOT=%~dp0backup"

echo ============================================
echo   크롬 프로필 복원
echo ============================================
echo.

:: 백업 존재 확인
if not exist "%BACKUP_ROOT%\Default" (
    echo [오류] 백업이 없습니다.
    echo 먼저 chrome_backup.bat 을 실행하세요.
    pause
    exit /b 1
)

:: 크롬 종료
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    echo [!] 크롬을 종료합니다...
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo     완료.
) else (
    echo [OK] 크롬이 종료된 상태입니다.
)
echo.

echo [1/2] Default 프로필 전체 복원 중... (수 분 걸릴 수 있음)
xcopy "%BACKUP_ROOT%\Default" "%CHROME_USER_DATA%\Default" /E /C /I /Y /H
if %errorlevel% neq 0 (
    echo [오류] 복원 실패!
    pause
    exit /b 1
)
echo.

echo [2/2] Local State 복원 중...
if exist "%BACKUP_ROOT%\Local State" (
    copy /Y "%BACKUP_ROOT%\Local State" "%CHROME_USER_DATA%\Local State" >nul
    echo      완료.
) else (
    echo      Local State 백업 없음 - 건너뜀.
)

echo.
echo ============================================
echo   복원 완료! 이제 크롬을 실행하세요.
echo ============================================
echo.

set /p LAUNCH="크롬을 바로 실행할까요? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe"
)

pause
