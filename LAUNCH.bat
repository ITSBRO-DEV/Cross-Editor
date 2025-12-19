@echo off
setlocal enabledelayedexpansion

:: Get current username dynamically
set "USER_DIR=%USERPROFILE%\AppData\Local\Programs"

:: First, check if python is in PATH
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=python"
    goto :check_packages
)

:: If not in PATH, check common install folders
set "FOUND=0"
for %%V in (313 312 311 310 39 38 37) do (
    set "PYDIR=%USER_DIR%\Python%%V"
    if exist "!PYDIR!\python.exe" (
        set "PYTHON_CMD=!PYDIR!\python.exe"
        set "FOUND=1"
        goto :check_packages
    )
)

:: If still not found
if !FOUND! EQU 0 (
    echo Python not found in PATH or common install directories.
    goto :end
)

:check_packages
echo Using Python: %PYTHON_CMD%
"%PYTHON_CMD%" --version

:: List of required packages
set "REQUIRED=PySide6 cryptography psutil"

set "NEED_INSTALL=0"
for %%P in (%REQUIRED%) do (
    "%PYTHON_CMD%" -m pip show %%P >nul 2>&1
    if errorlevel 1 (
        echo Package %%P not found, will install...
        set "NEED_INSTALL=1"
    ) else (
        echo Package %%P already installed.
    )
)

if !NEED_INSTALL! EQU 1 (
    echo Installing missing packages...
    "%PYTHON_CMD%" -m pip install --upgrade pip >nul
    "%PYTHON_CMD%" -m pip install %REQUIRED% >nul
) else (
    echo All required packages are already installed.
)

:: Navigate to LIBS\ASSITS and run crs.py
echo.
echo Moving into LIBS\ASSITS folder...
pushd "%~dp0LIBS\ASSITS"

if exist Crs.py (
    echo Running crs.py...
    "%PYTHON_CMD%" Crs.py
    if errorlevel 1 (
        echo ERROR: Crs.py exited with code %ERRORLEVEL%
    )
) else (
    echo ERROR: crs.py not found in %CD%
)

popd

:end
pause