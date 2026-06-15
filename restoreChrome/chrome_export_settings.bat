@echo off
set "CHROME_DEFAULT=%LOCALAPPDATA%\Google\Chrome\User Data\Default"
set "SCRIPT_DIR=%~dp0"
set "EXPORT_DIR=%SCRIPT_DIR%chrome_settings_export"

echo ============================================
echo  Chrome Settings Export (for another PC)
echo ============================================
echo.

if not exist "%CHROME_DEFAULT%" (
    echo ERROR: Chrome Default profile not found.
    pause
    exit /b 1
)

echo Closing Chrome...
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel%==0 (
    taskkill /F /IM chrome.exe /T >nul 2>&1
    timeout /t 3 /nobreak >nul
)

if not exist "%EXPORT_DIR%" mkdir "%EXPORT_DIR%"

echo.
echo [1/4] Bookmarks...
if exist "%CHROME_DEFAULT%\Bookmarks" copy /Y "%CHROME_DEFAULT%\Bookmarks" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\Bookmarks.bak" copy /Y "%CHROME_DEFAULT%\Bookmarks.bak" "%EXPORT_DIR%\" >nul
echo   OK

echo [2/4] Preferences...
if exist "%CHROME_DEFAULT%\Preferences" copy /Y "%CHROME_DEFAULT%\Preferences" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\Secure Preferences" copy /Y "%CHROME_DEFAULT%\Secure Preferences" "%EXPORT_DIR%\" >nul
echo   OK

echo [3/4] Extensions...
if exist "%CHROME_DEFAULT%\Extensions" (
    xcopy "%CHROME_DEFAULT%\Extensions" "%EXPORT_DIR%\Extensions" /E /C /I /Y /H /Q >nul
)
echo   OK

echo [4/4] Other settings...
if exist "%CHROME_DEFAULT%\Favicons" copy /Y "%CHROME_DEFAULT%\Favicons" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\History" copy /Y "%CHROME_DEFAULT%\History" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\Top Sites" copy /Y "%CHROME_DEFAULT%\Top Sites" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\Shortcuts" copy /Y "%CHROME_DEFAULT%\Shortcuts" "%EXPORT_DIR%\" >nul
if exist "%CHROME_DEFAULT%\Web Data" copy /Y "%CHROME_DEFAULT%\Web Data" "%EXPORT_DIR%\" >nul
echo   OK

echo.
echo ============================================
echo  Export complete!
echo  Location: %EXPORT_DIR%
echo.
echo  NOTE: Passwords and cookies are NOT included
echo  (encrypted with this PC's key, cannot be moved)
echo.
echo  To import on another PC:
echo  1. Close Chrome on the target PC
echo  2. Copy the exported files to:
echo     %%LOCALAPPDATA%%\Google\Chrome\User Data\Default\
echo  3. For Extensions, copy the Extensions folder
echo  4. Launch Chrome
echo ============================================
pause
