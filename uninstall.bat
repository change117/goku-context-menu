@echo off
REM Goku Context Menu - Uninstallation Script
REM Author: Goku Context Menu Project

title Goku Context Menu - Uninstallation
color 0C

echo.
echo ============================================================
echo          GOKU'S POWER MENU - UNINSTALLATION
echo ============================================================
echo.
echo This will remove Goku's Power Menu from your system.
echo.
echo [WARNING] This action will remove all context menu entries.
echo.
pause

echo.
echo [1/3] Removing context menu entries...
echo.

echo Removing file context menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\*\shell\GokuMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] File context menu removed
) else (
    echo [INFO] File context menu not found or already removed
)

echo Removing folder context menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\shell\GokuMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Folder context menu removed
) else (
    echo [INFO] Folder context menu not found or already removed
)

echo Removing background context menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\GokuMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Background context menu removed
) else (
    echo [INFO] Background context menu not found or already removed
)

echo.
echo [2/3] Refreshing Windows Explorer...
REM Kill and restart explorer to refresh the context menu
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo [OK] Windows Explorer refreshed

echo.
echo [3/3] Cleanup complete
echo.
echo ============================================================
echo.
echo   ✓ Goku's Power Menu has been removed from your system.
echo.
echo ============================================================
echo.
echo The installation files are still present in this directory.
echo You can safely delete this entire folder if you want to
echo completely remove all files.
echo.
echo Installation directory: %~dp0
echo.
echo Thank you for using Goku's Power Menu!
echo Power level returned to normal.
echo.
pause
