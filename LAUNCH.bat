@echo off
setlocal enabledelayedexpansion

:: Get current username dynamically
set "USER_DIR=%USERPROFILE%\AppData\Local\Programs"

:: First, check if python is in PATH
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=python"
    goto :install
)

:: If not in PATH, check common install folders
set "FOUND=0"
for %%V in (313 312 311 310 39 38 37) do (
    set "PYDIR=%USER_DIR%\Python%%V"
    if exist "!PYDIR!\python.exe" (
        set "PYTHON_CMD=!PYDIR!\python.exe"
        set "FOUND=1"
        goto :install
    )
)

:: If still not found
if !FOUND! EQU 0 (
    echo Python not found in PATH or common install directories.
    goto :end
)

:install
echo Using Python: %PYTHON_CMD%
%PYTHON_CMD% --version

echo Installing required packages...
%PYTHON_CMD% -m pip install --upgrade pip >nul
%PYTHON_CMD% -m pip install PySide6 cryptography psutil >nul

:: Navigate to LIBS\ASSITS and run crs.py
echo.
echo Moving into LIBS\ASSITS folder...
cd /d "%~dp0LIBS\ASSITS"

if exist Crs.py (
    echo Running crs.py...
    %PYTHON_CMD% Crs.py
) else (
    echo ERROR: crs.py not found in %CD%
)

:end
pause