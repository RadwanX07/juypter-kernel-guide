@echo off
REM Usage: setup_kernel.bat <name> <display-name>
REM Example: setup_kernel.bat econ "Python (Econ)"

SET NAME=%1
SET DISPLAY=%2
SET VENV_DIR=%USERPROFILE%\venvs\%NAME%

IF "%NAME%"=="" GOTO usage
IF "%DISPLAY%"=="" GOTO usage

echo Creating virtual environment at %VENV_DIR% ...
python -m venv %VENV_DIR%

echo Installing jupyter and ipykernel ...
call %VENV_DIR%\Scripts\activate
pip install jupyter ipykernel

echo Registering kernel '%NAME%' with display name '%DISPLAY%' ...
python -m ipykernel install --user --name=%NAME% --display-name="%DISPLAY%"

echo Done! Kernel '%NAME%' created.
echo To install packages: %VENV_DIR%\Scripts\activate ^&^& pip install ^<package^>
GOTO end

:usage
echo Usage: setup_kernel.bat ^<name^> ^<display-name^>
echo Example: setup_kernel.bat econ "Python (Econ)"

:end
