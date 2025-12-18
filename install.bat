@echo off
:: =====================================================
:: Cross Editor Installer
:: =====================================================

:: --- Self-elevate to Administrator if not already ---
>nul 2>&1 net session
if %errorLevel% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion
title Cross Editor Installer

:: Step 1: Check for Python
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python not found in PATH.
    echo Please install Python 3.7+ and re-run this installer.
    goto :end
)

:: Step 2: Prepare install directory
set "Cross_DIR=%USERPROFILE%\AppData\itsbrodev\Cross-editor"

echo.
echo Cleaning existing Cross-Editor directory with FORCE...
taskkill /f /im python.exe >nul 2>&1
taskkill /f /im pythonw.exe >nul 2>&1

if exist "%Cross_DIR%" (
    powershell -NoLogo -NoProfile -Command ^
        "Remove-Item -LiteralPath '%Cross_DIR%' -Recurse -Force -ErrorAction SilentlyContinue"
)

mkdir "%Cross_DIR%"

:: Step 3: Show banner
echo.
echo ==================================
echo        Cross EDITOR SETUP
echo ==================================
echo.
set /p "=Press ENTER to install Cross Editor: " <nul
pause >nul

:: Step 4: Move LIBS folder into Cross_DIR
if exist "%~dp0LIBS" (
    echo Moving LIBS folder...
    robocopy "%~dp0LIBS" "%Cross_DIR%\LIBS" /E /MOVE /NFL /NDL /NJH /NJS /nc /ns /np >nul
) else (
    echo [ERROR] LIBS folder not found next to installer.
    goto :end
)

:: Step 5: Move LAUNCH.bat from inside moved LIBS
if exist "%Cross_DIR%\LIBS\launch\LAUNCH.bat" (
    echo Moving LAUNCH.bat...
    move "%Cross_DIR%\LIBS\launch\LAUNCH.bat" "%Cross_DIR%\LAUNCH.bat" >nul
) else (
    echo [ERROR] LAUNCH.bat not found in %Cross_DIR%\LIBS\launch
    goto :end
)

:: Step 6: Copy icon.png from LIBS/ASSETS
if exist "%Cross_DIR%\LIBS\ASSETS\icon.png" (
    echo Copying icon.png...
    copy "%Cross_DIR%\LIBS\ASSETS\icon.png" "%Cross_DIR%\icon.png" >nul
) else (
    echo [WARNING] icon.png not found in LIBS\ASSETS
)

:: Step 7: Create Desktop Shortcut with icon
echo.
echo Creating desktop shortcut for Cross Editor...
set "TARGET=%Cross_DIR%\LAUNCH.bat"
set "SHORTCUT=%USERPROFILE%\Desktop\Cross Editor.lnk"
set "ICON=%Cross_DIR%\icon.png"

powershell -NoLogo -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('%SHORTCUT%'); ^
   $s.TargetPath = '%TARGET%'; ^
   $s.WorkingDirectory = '%Cross_DIR%'; ^
   $s.IconLocation = '%ICON%'; ^
   $s.Save()"

echo Shortcut created on Desktop: %SHORTCUT%

:end
echo.
echo Installation finished. You can now start Cross Editor using the desktop shortcut.
pause
exit