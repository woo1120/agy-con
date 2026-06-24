@echo off
echo ============================================
echo  Post-Reboot: WSL2 Gajae-Code Setup
echo ============================================
echo.
echo Step 1: Setting WSL default version to 2...
wsl --set-default-version 2
echo.
echo Step 2: Installing Ubuntu 24.04 LTS...
wsl --install Ubuntu-24.04
echo.
echo ============================================
echo  Ubuntu installed! 
echo  After setting up your username/password,
echo  run the following in WSL:
echo.
echo    bash /mnt/d/etc/setup-gjc-wsl.sh
echo.
echo ============================================
pause
