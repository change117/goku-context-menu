@echo off
REM Goku Context Menu - Installation Script
REM Dragon Ball Z Themed Right-Click Menu for Windows 11
REM Author: Goku Context Menu Project

title Goku Context Menu - Installation
color 0E

echo.
echo ============================================================
echo    _____ ____  _  ___    _   __  __ _____ _   _ _   _ 
echo   / ____/ __ \^| ^|/ / ^|  ^| ^| ^|  \/  ^|  ___^| ^| ^| ^| ^| ^| ^|
echo  ^| ^|  _^| ^|  ^| ^| ' /^| ^|  ^| ^| ^| ^|\/^| ^| ^|_  ^| ^|^_^| ^| ^| ^| ^|
echo  ^| ^|_^| ^| ^|__^| ^| . \^| ^|__^| ^| ^| ^|  ^| ^|  _^| ^|  _  ^| ^|_^| ^|
echo   \_____\____/^|_^|\_\\____/  ^|_^|  ^|_^|_^|   ^|_^| ^|_^|\___/ 
echo.
echo        GOKU'S POWER MENU - INSTALLATION WIZARD
echo ============================================================
echo.

REM Check for PowerShell
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is not installed or not in PATH!
    echo This tool requires PowerShell 5.1 or later.
    pause
    exit /b 1
)

REM Get installation directory (current directory)
set "INSTALL_DIR=%~dp0"
REM Remove trailing backslash
if "%INSTALL_DIR:~-1%"=="\" set "INSTALL_DIR=%INSTALL_DIR:~0,-1%"

echo [INFO] Installation Directory: %INSTALL_DIR%
echo.

REM Check if scripts directory exists
if not exist "%INSTALL_DIR%\scripts" (
    echo [ERROR] Scripts directory not found!
    echo Please ensure all files are extracted correctly.
    pause
    exit /b 1
)

REM Verify all required scripts exist
echo [1/4] Verifying installation files...
set "MISSING_FILES="
if not exist "%INSTALL_DIR%\scripts\super-saiyan.ps1" set "MISSING_FILES=!MISSING_FILES! super-saiyan.ps1"
if not exist "%INSTALL_DIR%\scripts\kamehameha.ps1" set "MISSING_FILES=!MISSING_FILES! kamehameha.ps1"
if not exist "%INSTALL_DIR%\scripts\instant-transmission.ps1" set "MISSING_FILES=!MISSING_FILES! instant-transmission.ps1"
if not exist "%INSTALL_DIR%\scripts\power-scanner.ps1" set "MISSING_FILES=!MISSING_FILES! power-scanner.ps1"
if not exist "%INSTALL_DIR%\scripts\shenron-menu.ps1" set "MISSING_FILES=!MISSING_FILES! shenron-menu.ps1"
if not exist "%INSTALL_DIR%\scripts\hyperbolic-chamber.ps1" set "MISSING_FILES=!MISSING_FILES! hyperbolic-chamber.ps1"

if defined MISSING_FILES (
    echo [ERROR] Missing required files: %MISSING_FILES%
    pause
    exit /b 1
)
echo [OK] All files verified!

REM Create registry file from template
echo.
echo [2/4] Generating registry entries...
set "REG_FILE=%TEMP%\goku-menu-install.reg"

REM Read template and replace INSTALL_PATH
powershell -Command "(Get-Content '%INSTALL_DIR%\goku-menu.reg.template') -replace '%%INSTALL_PATH%%', '%INSTALL_DIR:\=\\%' | Set-Content '%REG_FILE%'"

if not exist "%REG_FILE%" (
    echo [ERROR] Failed to generate registry file!
    pause
    exit /b 1
)
echo [OK] Registry file generated!

REM Import registry entries
echo.
echo [3/4] Installing context menu entries...
echo.
echo [WARNING] You will see a confirmation dialog from Registry Editor.
echo           Click "Yes" to proceed with the installation.
echo.
pause

regedit /s "%REG_FILE%"

if %errorlevel% equ 0 (
    echo [OK] Registry entries installed successfully!
) else (
    echo [ERROR] Failed to install registry entries!
    echo Please run this script with appropriate permissions.
    pause
    exit /b 1
)

REM Clean up temporary registry file
del "%REG_FILE%" >nul 2>nul

REM Create uninstaller with correct path
echo.
echo [4/4] Creating uninstaller...
set "UNINSTALL_SCRIPT=%INSTALL_DIR%\uninstall-generated.bat"
(
    echo @echo off
    echo title Goku Context Menu - Uninstallation
    echo color 0C
    echo.
    echo ============================================================
    echo          GOKU'S POWER MENU - UNINSTALLATION
    echo ============================================================
    echo.
    echo This will remove Goku's Power Menu from your system.
    echo.
    pause
    echo.
    echo Removing context menu entries...
    echo.
    echo Removing file context menu...
    reg delete "HKEY_CURRENT_USER\Software\Classes\*\shell\GokuMenu" /f >nul 2^>^&1
    echo Removing folder context menu...
    reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\shell\GokuMenu" /f >nul 2^>^&1
    echo Removing background context menu...
    reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\GokuMenu" /f >nul 2^>^&1
    echo.
    echo [OK] Goku's Power Menu has been removed from your system.
    echo.
    echo NOTE: The installation files are still present in:
    echo %INSTALL_DIR%
    echo You can safely delete this folder if you want to completely remove all files.
    echo.
    pause
) > "%UNINSTALL_SCRIPT%"

echo [OK] Uninstaller created: %UNINSTALL_SCRIPT%

REM Success message
echo.
echo ============================================================
echo.
echo   ✓ Installation Complete! Your power level is OVER 9000!
echo.
echo ============================================================
echo.
echo Goku's Power Menu has been successfully installed!
echo.
echo You can now right-click on any file or folder to see the menu.
echo.
echo Available Options:
echo   🔥 Super Saiyan Mode - Open with admin privileges
echo   ⚡ Kamehameha - Safe delete with confirmation
echo   🌟 Instant Transmission - Quick move to common folders
echo   💪 Power Level Scanner - Detailed file properties
echo   🐉 Summon Shenron - Custom actions submenu
echo   📁 Hyperbolic Time Chamber - Compress to ZIP
echo.
echo To uninstall, run: uninstall-generated.bat
echo.
echo ============================================================
echo.
pause
