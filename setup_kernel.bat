@echo off
rem ============================================================================
rem Script: setup_kernel.bat
rem Purpose: Automatically create a venv and register kernel on Windows (CMD)
rem Usage: setup_kernel.bat <kernel_name> ["Display Name"]
rem ============================================================================

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: setup_kernel.bat ^<kernel_name^> ["Display Name"]
    echo Example: setup_kernel.bat data "Python (Data)"
    exit /b 1
)

set "NAME=%~1"
set "DISPLAY=%~2"
if "%DISPLAY%"=="" set "DISPLAY=Python (%NAME%)"
set "VENV_DIR=%USERPROFILE%\venvs\%NAME%"

echo [1/4] Creating virtual environment at "%VENV_DIR%"...
if not exist "%USERPROFILE%\venvs" mkdir "%USERPROFILE%\venvs"
python -m venv "%VENV_DIR%"
if errorlevel 1 (
    echo Error: Failed to create virtualenv. Ensure Python is installed and in your PATH.
    exit /b 1
)

echo [2/4] Upgrading pip and installing ipykernel...
call "%VENV_DIR%\Scripts\activate.bat"
python -m pip install --upgrade pip
pip install ipykernel

echo [3/4] Registering kernel with Jupyter...
python -m ipykernel install --user --name="%NAME%" --display-name="%DISPLAY%"

echo.
echo ============================================================================
echo Kernel '%DISPLAY%' successfully registered!
echo Virtual environment location: %VENV_DIR%
echo Activate anytime with: call "%VENV_DIR%\Scripts\activate.bat"
echo ============================================================================
