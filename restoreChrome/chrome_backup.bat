@echo off
chcp 65001 >nul 2>&1
title 크롬 프로필 백업

set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
set "BACKUP_ROOT=%~dp0backup"

echo ============================================
echo   크롬 프로필 백업
echo ============================================
echo.

:: 크롬 프로필 존재 확인
if not exist "%CHROME_USER_DATA%\Default" (
    echo [오류] 크롬 Default 프로필을 찾을 수 없습니다.
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

:: 백업 디렉토리 생성
if not exist "%BACKUP_ROOT%" mkdir "%BACKUP_ROOT%"

echo [1/2] Default 프로필 전체 복사 중... (수 분 걸릴 수 있음)
xcopy "%CHROME_USER_DATA%\Default" "%BACKUP_ROOT%\Default" /E /C /I /Y /H
if %errorlevel% neq 0 (
    echo [오류] 백업 실패!
    pause
    exit /b 1
)
echo.

echo [2/2] Local State 복사 중...
copy /Y "%CHROME_USER_DATA%\Local State" "%BACKUP_ROOT%\Local State" >nul
echo      완료.

echo.
echo ============================================
echo   백업 완료!
echo   위치: %BACKUP_ROOT%
echo ============================================
echo.
pause
