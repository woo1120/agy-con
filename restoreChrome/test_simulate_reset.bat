@echo off
chcp 65001 >nul 2>&1
title 보안 초기화 시뮬레이션

set "CHROME_DEFAULT=%LOCALAPPDATA%\Google\Chrome\User Data\Default"

echo ============================================
echo   보안 초기화 시뮬레이션 (테스트용)
echo ============================================
echo.
echo   보안 프로그램이 크롬 쿠키/로그인 데이터를
echo   삭제하는 것을 재현합니다.
echo.

:: 백업 확인
if not exist "%~dp0backup\Default" (
    echo [오류] 백업이 없습니다!
    echo 먼저 chrome_backup.bat 을 실행하세요.
    pause
    exit /b 1
)

set /p CONFIRM="계속하시겠습니까? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo 취소.
    pause
    exit /b 0
)

:: 크롬 종료
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    echo.
    echo [!] 크롬을 종료합니다...
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
)

echo.
echo 쿠키 및 로그인 데이터 삭제 중...

del /F /Q "%CHROME_DEFAULT%\Cookies" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Cookies-journal" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Network\Cookies" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Network\Cookies-journal" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Login Data" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Login Data-journal" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Login Data For Account" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Login Data For Account-journal" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Web Data" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Web Data-journal" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Account Web Data" >nul 2>&1
del /F /Q "%CHROME_DEFAULT%\Account Web Data-journal" >nul 2>&1

echo.
echo ============================================
echo   시뮬레이션 완료!
echo   크롬을 열어서 "일시중지됨" 확인 후
echo   chrome_restore.bat 으로 복원하세요.
echo ============================================
echo.

set /p LAUNCH="크롬을 열어서 확인할까요? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe"
)

pause
