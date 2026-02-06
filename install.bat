@echo off
setlocal enabledelayedexpansion

title Dragon Ball Context Menu Setup
color 0E

echo.
echo ============================================================
echo       DRAGON BALL CONTEXT MENU INSTALLATION
echo ============================================================
echo.

where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] PowerShell not found
    echo     This requires PowerShell 5.1+
    pause
    exit /b 1
)

set "DRAGON_HOME=%~dp0"
if "%DRAGON_HOME:~-1%"=="\" set "DRAGON_HOME=%DRAGON_HOME:~0,-1%"

echo [*] Install location: %DRAGON_HOME%
echo.

echo [1/4] Checking installation files...

set "missing="
if not exist "%DRAGON_HOME%\scripts\super-saiyan.ps1" set "missing=!missing! super-saiyan.ps1"
if not exist "%DRAGON_HOME%\scripts\kamehameha.ps1" set "missing=!missing! kamehameha.ps1"
if not exist "%DRAGON_HOME%\scripts\instant-transmission.ps1" set "missing=!missing! instant-transmission.ps1"
if not exist "%DRAGON_HOME%\scripts\power-scanner.ps1" set "missing=!missing! power-scanner.ps1"
if not exist "%DRAGON_HOME%\scripts\shenron-menu.ps1" set "missing=!missing! shenron-menu.ps1"
if not exist "%DRAGON_HOME%\scripts\hyperbolic-chamber.ps1" set "missing=!missing! hyperbolic-chamber.ps1"

if defined missing (
    echo [X] Missing: !missing!
    pause
    exit /b 1
)

echo [OK] All scripts found

echo.
echo [2/4] Building registry configuration...

set "REG_TEMP=%TEMP%\dragon-menu-setup.reg"

powershell -Command "(Get-Content '%DRAGON_HOME%\menu-template.reg') -replace '%%DRAGON_HOME%%', '%DRAGON_HOME:\=\\%' | Set-Content '%REG_TEMP%'"

if not exist "%REG_TEMP%" (
    echo [X] Registry file generation failed
    pause
    exit /b 1
)

echo [OK] Registry file ready

echo.
echo [3/4] Applying registry entries...

reg import "%REG_TEMP%" >nul 2>&1

if %errorlevel% equ 0 (
    echo [OK] Registry entries applied
) else (
    echo [X] Registry installation failed
    echo     Error code: %errorlevel%
    pause
    exit /b 1
)

del "%REG_TEMP%" >nul 2>nul

echo.
echo [*] Refreshing Windows Explorer...

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

timeout /t 3 >nul

echo.
echo [4/4] Creating uninstaller...

set "UNINSTALL=%DRAGON_HOME%\remove-menu.bat"

(
    echo @echo off
    echo title Dragon Ball Menu Removal
    echo color 0C
    echo.
    echo Removing Dragon Ball context menu...
    echo.
    echo Deleting file entries...
    echo reg delete "HKEY_CURRENT_USER\Software\Classes\*\shell\DragonMenu" /f ^^^>nul 2^^^>^^^&1
    echo Deleting folder entries...
    echo reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\shell\DragonMenu" /f ^^^>nul 2^^^>^^^&1
    echo Deleting background entries...
    echo reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\DragonMenu" /f ^^^>nul 2^^^>^^^&1
    echo.
    echo [OK] Context menu removed
    echo.
    echo Installation files remain at:
    echo %DRAGON_HOME%
    echo.
    pause
) > "%UNINSTALL%"

echo [OK] Uninstaller created: remove-menu.bat

echo.
echo ============================================================
echo.
echo   [OK] Installation Complete!
echo.
echo ============================================================
echo.
echo Dragon Ball context menu is now active.
echo Right-click any file or folder to access the menu.
echo.
echo Available options:
echo   - Super Saiyan Mode (admin access^)
echo   - Kamehameha (safe delete^)
echo   - Instant Transmission (quick move^)
echo   - Power Scanner (file info^)
echo   - Summon Shenron (utilities^)
echo   - Time Chamber (compression^)
echo.
echo To remove: Run remove-menu.bat
echo.
pause
