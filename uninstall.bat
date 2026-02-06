@echo off

title Dragon Ball Menu Removal
color 0C

echo.
echo ============================================================
echo       DRAGON BALL CONTEXT MENU REMOVAL
echo ============================================================
echo.
echo This will remove the Dragon Ball context menu entries.
echo.
pause

echo.
echo [1/2] Removing registry entries...
echo.

echo Removing file menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\*\shell\DragonMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] File menu removed
) else (
    echo [INFO] File menu not found
)

echo Removing folder menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\shell\DragonMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Folder menu removed
) else (
    echo [INFO] Folder menu not found
)

echo Removing background menu...
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\DragonMenu" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Background menu removed
) else (
    echo [INFO] Background menu not found
)

echo.
echo [2/2] Refreshing explorer...

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo [OK] Explorer refreshed

echo.
echo ============================================================
echo.
echo   [OK] Removal Complete
echo.
echo ============================================================
echo.
echo The context menu has been removed.
echo.
echo Installation files are still here:
echo %~dp0
echo.
echo Delete this folder to completely remove all files.
echo.
pause
