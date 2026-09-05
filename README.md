# The Ultimate Jupyter Custom Kernel Guide (Modern Edition)
*A complete, error-free setup guide for Python, JupyterLab, Jupyter Notebook, and isolated custom kernels on Linux and Windows.*

---

## Table of Contents

1. [The Problem: Why Packages Disappear in Notebooks](#the-problem-why-packages-disappear-in-notebooks)
2. [The Core Solution: Server vs. Kernel Architecture](#the-core-solution-server-vs-kernel-architecture)
3. [Step 0: Modern Python Installation & Verification](#step-0-modern-python-installation--verification)
   - [Linux (Ubuntu/Debian, Fedora, Arch)](#linux-python-installation)
   - [Windows (Winget & Official Installer)](#windows-python-installation)
4. [Step 1: Installing JupyterLab & Jupyter Notebook](#step-1-installing-jupyterlab--jupyter-notebook)
   - [The Golden Rule: Install Jupyter ONCE](#the-golden-rule-install-jupyter-once)
   - [Linux Jupyter Installation](#linux-jupyter-installation)
   - [Windows Jupyter Installation](#windows-jupyter-installation)
5. [Step 2: Creating a Project Virtual Environment & Custom Kernel](#step-2-creating-a-project-virtual-environment--custom-kernel)
   - [Linux Setup Walkthrough](#linux-setup-walkthrough)
   - [Windows Setup Walkthrough (CMD & PowerShell)](#windows-setup-walkthrough-cmd--powershell)
6. [Step 3: Launching Jupyter and Using Your Kernel](#step-3-launching-jupyter-and-using-your-kernel)
7. [How It Works Under the Hood (`kernel.json`)](#how-it-works-under-the-hood-kerneljson)
8. [Adding Libraries to an Existing Kernel](#adding-libraries-to-an-existing-kernel)
   - [Method 1: Terminal Activation (Cleanest)](#method-1-terminal-activation-recommended)
   - [Method 2: Direct Pip Call Without Activating](#method-2-direct-pip-call-without-activating)
   - [Method 3: Inside Notebook with `%pip` (Modern Standard)](#method-3-inside-a-notebook-using-pip)
9. [Managing Multiple Kernels](#managing-multiple-kernels)
10. [Listing & Removing Kernels](#listing--removing-kernels)
11. [Troubleshooting & Platform Error Fixes](#troubleshooting--platform-error-fixes)
    - [Fix 1: Linux `error: externally-managed-environment` (PEP 668)](#fix-1-linux-error-externally-managed-environment-pep-668)
    - [Fix 2: Linux `ensurepip is not available` / missing `python3-venv`](#fix-2-linux-ensurepip-is-not-available--missing-python3-venv)
    - [Fix 3: Windows PowerShell `PSSecurityException` (Script execution disabled)](#fix-3-windows-powershell-pssecurityexception-script-execution-disabled)
    - [Fix 4: Windows PowerShell `%USERPROFILE%` variable does not expand](#fix-4-windows-powershell-userprofile-does-not-expand)
    - [Fix 5: Windows `'python'` or `'jupyter'` not recognized as an internal command](#fix-5-windows-python-or-jupyter-not-recognized-path-issue)
    - [Fix 6: Kernel Dead / Kernel Restarting / Failed to Start](#fix-6-kernel-dead--kernel-restarting--failed-to-start)
    - [Fix 7: Kernel does not appear in Jupyter dropdown](#fix-7-kernel-does-not-appear-in-jupyter-dropdown)
12. [One-Click Automation Scripts](#one-click-automation-scripts)
    - [Linux / macOS (`setup_kernel.sh`)](#linux--macos-setup_kernelsh)
    - [Windows Command Prompt (`setup_kernel.bat`)](#windows-command-prompt-setup_kernelbat)
    - [Windows PowerShell (`setup_kernel.ps1`)](#windows-powershell-setup_kernelps1)

---

## The Problem: Why Packages Disappear in Notebooks

When you launch JupyterLab or Jupyter Notebook, it starts with a default `python3` kernel pointing to whatever Python environment launched Jupyter.

If you open your terminal and run:
```bash
pip install pandas
```
...and then try `import pandas` in your notebook, you are often greeted with:
```
ModuleNotFoundError: No module named 'pandas'
```

Frustrated users often resort to messy hacks inside cells:
```python
# Bad practice: slow, creates permission conflicts, and pollutes environments
!pip install pandas
```

**Why does this happen?**
Your terminal `pip` and your notebook's kernel run on **two completely different Python binaries**. 

---

## The Core Solution: Server vs. Kernel Architecture

Jupyter is built on a client-server architecture:
1. **The Jupyter Server (JupyterLab / Notebook):** The web interface and file manager. It only needs to be installed **once** on your machine.
2. **The Kernels (Execution Engines):** Independent Python virtual environments (`venv`) that execute your code cells. Each project has its own kernel containing only that project's dependencies (`numpy`, `torch`, `pandas`, etc.).

```
┌─────────────────────────────────────────────────────────────┐
│                 JupyterLab / Web Interface                  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Reads ~/.local/share/jupyter/kernels/
                               │ (or %APPDATA%\jupyter\kernels\)
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ Kernel: Data  │      │ Kernel: ML    │      │ Kernel: Web   │
│ ~/venvs/data  │      │ ~/venvs/ml    │      │ ~/venvs/web   │
│ (pandas, etc.)│      │ (torch, cuda) │      │ (fastapi, etc)│
└───────────────┘      └───────────────┘      └───────────────┘
```

> **Key Rule:** You do **NOT** need to install `jupyterlab` or `notebook` in every project environment! Each virtual environment only needs **`ipykernel`**.

---

## Step 0: Modern Python Installation & Verification

### Linux (Python Installation)

Modern Linux distributions (Ubuntu 22.04+, Ubuntu 24.04, Debian 12+, Fedora 39+, Arch) come with Python 3, but developer packages like `venv` and `pip` are often separated into distinct packages.

#### Ubuntu / Debian / Linux Mint
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
```

#### Fedora / RHEL
```bash
sudo dnf install -y python3 python3-pip
```

#### Arch Linux / Manjaro
```bash
sudo pacman -S --needed python python-pip
```

#### Verify Installation:
```bash
python3 --version
pip3 --version
```

---

### Windows (Python Installation)

On Windows, path errors and launcher mismatches cause 90% of beginner issues. Follow either method below:

#### Option A: Windows Package Manager (Fastest & Recommended)
Open **PowerShell** as Administrator and run:
```powershell
winget install Python.Python.3.12
```
Restart your terminal after installation.

#### Option B: Official Installer (python.org)
1. Download the latest 64-bit installer from [python.org](https://www.python.org/downloads/).
2. Run the `.exe` installer.
3. **CRITICAL STEP:** At the bottom of the very first setup screen, check the box:
   - ☑ **"Add python.exe to PATH"**
   - ☑ **"Use admin privileges when installing py.exe"**
4. Click **Install Now**.
5. On the final screen, click **"Disable path length limit"** if prompted.

#### Verify Installation:
Open a **new** Command Prompt or PowerShell window:
```cmd
python --version
py --version
```

---

## Step 1: Installing JupyterLab & Jupyter Notebook

### The Golden Rule: Install Jupyter ONCE

Instead of polluting system files or reinstalling Jupyter inside every project, install JupyterLab and Notebook in a **dedicated tools environment** or globally via user packages.

### Linux Jupyter Installation

Because modern Linux strictly enforces PEP 668 (`externally-managed-environment`), the recommended modern approach is creating a dedicated central environment for Jupyter:

```bash
# 1. Create a dedicated home for your Jupyter server
python3 -m venv ~/.jupyter_env

# 2. Upgrade pip inside this environment
~/.jupyter_env/bin/pip install --upgrade pip

# 3. Install JupyterLab and Jupyter Notebook
~/.jupyter_env/bin/pip install jupyterlab notebook

# 4. Create convenient symlinks so 'jupyter' is available in your shell
mkdir -p ~/.local/bin
ln -sf ~/.jupyter_env/bin/jupyter ~/.local/bin/jupyter
ln -sf ~/.jupyter_env/bin/jupyter-lab ~/.local/bin/jupyter-lab
ln -sf ~/.jupyter_env/bin/jupyter-notebook ~/.local/bin/jupyter-notebook
```

> Ensure `~/.local/bin` is in your `PATH`. If `jupyter --version` says "command not found", add `export PATH="$HOME/.local/bin:$PATH"` to your `~/.bashrc` or `~/.zshrc`.

---

### Windows Jupyter Installation

You can create a central tools environment or install Jupyter in your user space:

#### In Command Prompt (CMD):
```cmd
python -m venv %USERPROFILE%\.jupyter_env
%USERPROFILE%\.jupyter_env\Scripts\python.exe -m pip install --upgrade pip
%USERPROFILE%\.jupyter_env\Scripts\pip.exe install jupyterlab notebook
```

#### In PowerShell:
```powershell
python -m venv "$HOME\.jupyter_env"
& "$HOME\.jupyter_env\Scripts\python.exe" -m pip install --upgrade pip
& "$HOME\.jupyter_env\Scripts\pip.exe" install jupyterlab notebook
```

To create quick launch shortcuts on Windows:
- Create a batch file `jupyter-lab.bat` in a folder on your PATH (such as `C:\Windows` or user script folder) containing:
  ```cmd
  @"%USERPROFILE%\.jupyter_env\Scripts\jupyter-lab.exe" %*
  ```

---

## Step 2: Creating a Project Virtual Environment & Custom Kernel

Now for each of your projects (e.g., `data`, `machine_learning`, `deeplearning`), follow these exact steps.

### Linux Setup Walkthrough

#### 1. Create the project virtual environment
We store project venvs in a clean `~/venvs/` folder:
```bash
mkdir -p ~/venvs
python3 -m venv ~/venvs/data
```

#### 2. Activate the virtual environment
```bash
source ~/venvs/data/bin/activate
```
Your shell prompt will now display `(data)`.

#### 3. Install `ipykernel` and your project dependencies
> Remember: You only need `ipykernel` here—do **NOT** install `jupyter` again!
```bash
pip install --upgrade pip
pip install ipykernel pandas numpy matplotlib scipy
```

#### 4. Register the virtual environment as a Jupyter Kernel
```bash
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

This creates a registration file at:
```
~/.local/share/jupyter/kernels/data/kernel.json
```

---

### Windows Setup Walkthrough (CMD & PowerShell)

Choose either Command Prompt or PowerShell:

#### Option 1: Using Command Prompt (`cmd.exe`)

```cmd
:: 1. Create the venv
python -m venv %USERPROFILE%\venvs\data

:: 2. Activate the venv
call %USERPROFILE%\venvs\data\Scripts\activate.bat

:: 3. Install ipykernel and packages
python -m pip install --upgrade pip
pip install ipykernel pandas numpy matplotlib scipy

:: 4. Register the kernel
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

#### Option 2: Using PowerShell (`pwsh` / `powershell.exe`)

> **Note on PowerShell:** `%USERPROFILE%` does not expand in PowerShell. Always use `$HOME` or `$env:USERPROFILE`.

```powershell
# 1. Create the venv
python -m venv "$HOME\venvs\data"

# 2. Activate the venv
& "$HOME\venvs\data\Scripts\Activate.ps1"

# If you get a script execution policy error, see Fix 3 in Troubleshooting!

# 3. Install ipykernel and packages
python -m pip install --upgrade pip
pip install ipykernel pandas numpy matplotlib scipy

# 4. Register the kernel
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

This creates a registration file at:
```
%APPDATA%\jupyter\kernels\data\kernel.json
```

---

## Step 3: Launching Jupyter and Using Your Kernel

Launch JupyterLab from any terminal or folder:

**Linux:**
```bash
jupyter lab
# or: jupyter notebook
```

**Windows:**
```cmd
%USERPROFILE%\.jupyter_env\Scripts\jupyter-lab.exe
```

### In JupyterLab / Jupyter Notebook:
1. When opening or creating a `.ipynb` notebook, look at the **top right corner** (or menu bar).
2. Click on the current kernel name (e.g. `Python 3 (ipykernel)`).
3. In the dropdown selector, choose your new custom kernel: **`Python (Data)`**.
4. Test it in a cell:
   ```python
   import pandas as pd
   import sys

   print("Python Executable:", sys.executable)
   print("Pandas Version:", pd.__version__)
   ```
5. `sys.executable` will verify that code is running directly inside your `~/venvs/data` or `C:\Users\...\venvs\data` environment!

---

## How It Works Under the Hood (`kernel.json`)

When you run `python -m ipykernel install`, Jupyter writes a small configuration file named `kernel.json`.

### Linux Location:
`~/.local/share/jupyter/kernels/data/kernel.json`

```json
{
 "argv": [
  "/home/radwan/venvs/data/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python (Data)",
 "language": "python",
 "metadata": {
  "debugger": true
 }
}
```

### Windows Location:
`C:\Users\YourName\AppData\Roaming\jupyter\kernels\data\kernel.json`

```json
{
 "argv": [
  "C:\\Users\\YourName\\venvs\\data\\Scripts\\python.exe",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python (Data)",
 "language": "python",
 "metadata": {
  "debugger": true
 }
}
```

Whenever you select **"Python (Data)"**, Jupyter launches the specific `python` binary listed in the `"argv"` array. Because that binary belongs to your virtual environment, it automatically loads all libraries installed in that environment.

---

## Adding Libraries to an Existing Kernel

Need a new library (like `seaborn` or `scikit-learn`) after creating your kernel?

### Method 1: Terminal Activation (Recommended)

**Linux:**
```bash
source ~/venvs/data/bin/activate
pip install seaborn scikit-learn
```

**Windows (CMD):**
```cmd
call %USERPROFILE%\venvs\data\Scripts\activate.bat
pip install seaborn scikit-learn
```

**Windows (PowerShell):**
```powershell
& "$HOME\venvs\data\Scripts\Activate.ps1"
pip install seaborn scikit-learn
```

---

### Method 2: Direct Pip Call Without Activating

You can install packages into the kernel environment directly without activating it:

**Linux:**
```bash
~/venvs/data/bin/pip install seaborn
```

**Windows:**
```cmd
"%USERPROFILE%\venvs\data\Scripts\pip.exe" install seaborn
```

---

### Method 3: Inside a Notebook Using `%pip`

If you are already inside your notebook and need to install a library without switching to a terminal:

```python
# ✅ MODERN STANDARD: Uses the active kernel's Python environment
%pip install seaborn
```

> **Important Difference: `%pip` vs `!pip`**
> - `!pip` spawns a subshell and executes whatever `pip` is in the system PATH. It often installs into the wrong environment!
> - `%pip` is an official IPython magic command that resolves to `{sys.executable} -m pip`. It is **guaranteed** to install into the environment running the current kernel.

After running `%pip install`, you can immediately run `import seaborn` in the next cell without restarting the kernel.

---

## Managing Multiple Kernels

Organize separate environments for different tech stacks to avoid package conflicts (e.g. PyTorch vs TensorFlow, or conflicting CUDA wheels):

| Kernel Name | Display Name | Purpose | Example Packages |
| :--- | :--- | :--- | :--- |
| `data` | `Python (Data Science)` | Tabular analysis & viz | `pandas`, `polars`, `seaborn` |
| `ml` | `Python (Machine Learning)` | Deep learning & models | `torch`, `torchvision`, `scikit-learn` |
| `nlp` | `Python (LLMs & NLP)` | Text & transformer models | `transformers`, `accelerate`, `spacy` |
| `scraping`| `Python (Web Scraping)` | Web automation | `playwright`, `beautifulsoup4`, `httpx` |

### Create another kernel in seconds:
```bash
# Example on Linux:
python3 -m venv ~/venvs/ml
source ~/venvs/ml/bin/activate
pip install ipykernel torch torchvision
python -m ipykernel install --user --name=ml --display-name="Python (Machine Learning)"
```

---

## Listing & Removing Kernels

### List all registered kernels:
**Linux & Windows (same command):**
```bash
jupyter kernelspec list
```
*Output:*
```
Available kernels:
  data       /home/radwan/.local/share/jupyter/kernels/data
  ml         /home/radwan/.local/share/jupyter/kernels/ml
  python3    /home/radwan/.jupyter_env/share/jupyter/kernels/python3
```

### Remove an unwanted kernel:
If you delete a virtual environment, remove its kernel registration:
```bash
jupyter kernelspec remove <kernel-name>
```

*Example:*
```bash
jupyter kernelspec remove data
```
*(Type `y` when prompted to confirm.)*

---

## Troubleshooting & Platform Error Fixes

### Fix 1: Linux `error: externally-managed-environment` (PEP 668)

**The Error:**
```
error: externally-managed-environment
× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

**Why it happens:** Modern distributions (Debian 12+, Ubuntu 23.04+, Fedora 38+) prevent `pip install` in the global system Python to protect OS utilities from breaking.

**The Fix:**
Do not run `pip` on system Python. Always use a virtual environment:
```bash
# Create and use a venv:
python3 -m venv ~/my_project_env
source ~/my_project_env/bin/activate
pip install <package>
```

---

### Fix 2: Linux `ensurepip is not available` / missing `python3-venv`

**The Error:**
```
The virtual environment was not created successfully because ensurepip is not available.
On Debian/Ubuntu systems, you need to install the python3-venv package...
```

**The Fix:**
Install the missing package via APT:
```bash
sudo apt update
sudo apt install -y python3-venv python3-full
```

---

### Fix 3: Windows PowerShell `PSSecurityException` (Script execution disabled)

**The Error:**
```
File C:\Users\...\Activate.ps1 cannot be loaded because running scripts is disabled on this system.
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

**Why it happens:** Windows PowerShell restricts `.ps1` script execution by default.

**The Fix:**
Open PowerShell and run this one-time command (only affects your user account, does not require admin rights):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Now you can activate virtual environments with:
```powershell
& "$HOME\venvs\data\Scripts\Activate.ps1"
```

---

### Fix 4: Windows PowerShell `%USERPROFILE%` does not expand

**The Error:**
When running:
```powershell
python -m venv %USERPROFILE%\venvs\data
```
A folder literally named `%USERPROFILE%` is created inside your current folder.

**Why it happens:** `%VARIABLE%` syntax only works in Command Prompt (`cmd.exe`). PowerShell requires `$HOME` or `$env:USERPROFILE`.

**The Fix:**
In PowerShell, use:
```powershell
python -m venv "$HOME\venvs\data"
```

---

### Fix 5: Windows `'python'` or `'jupyter'` not recognized (PATH Issue)

**The Error:**
```
'python' is not recognized as an internal or external command, operable program or batch file.
```

**The Fix:**
1. Try the Python Launcher command:
   ```cmd
   py -m venv venv
   ```
2. If `py` is also missing, add Python to your PATH:
   - Press `Win + R`, type `sysdm.cpl`, press Enter.
   - Go to **Advanced** tab > **Environment Variables**.
   - Under **User variables**, select `Path` > **Edit** > **New**.
   - Add:
     - `C:\Users\<YourUsername>\AppData\Local\Programs\Python\Python312`
     - `C:\Users\<YourUsername>\AppData\Local\Programs\Python\Python312\Scripts`
   - Click **OK** and restart your terminal.

---

### Fix 6: Kernel Dead / Kernel Restarting / Failed to Start

**Symptoms:** Jupyter keeps popping up `"Kernel Restarting"` or `"Kernel Failed to Start"`.

**Common Causes & Fixes:**
1. **`ipykernel` missing:** Verify `ipykernel` is installed in that specific venv:
   ```bash
   # Linux:
   ~/venvs/data/bin/pip install ipykernel
   # Windows:
   "%USERPROFILE%\venvs\data\Scripts\pip.exe" install ipykernel
   ```
2. **Broken Python path:** If you moved or renamed the venv directory, the path in `kernel.json` is invalid. Check `kernel.json` and update the `"argv"` path.

---

### Fix 7: Kernel does not appear in Jupyter dropdown

**The Fix:**
1. Run `jupyter kernelspec list` to check if your kernel is registered.
2. If it is listed in the terminal but not in the browser:
   - Hard refresh your browser (`Ctrl + Shift + R` or `Cmd + Shift + R`).
   - Check file permissions on Linux:
     ```bash
     chmod -R u+rw ~/.local/share/jupyter/kernels/
     ```

---

## One-Click Automation Scripts

Save time by using automated scripts to create and register custom kernels in one command.

### Linux / macOS (`setup_kernel.sh`)

Create a script named `setup_kernel.sh`:

```bash
#!/usr/bin/env bash
# ==============================================================================
# Script: setup_kernel.sh
# Purpose: Automatically create a venv, install ipykernel, and register with Jupyter
# Usage: ./setup_kernel.sh <kernel_name> ["Display Name"]
# ==============================================================================

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <kernel_name> [\"Display Name\"]"
    echo "Example: $0 data \"Python (Data Science)\""
    exit 1
fi

NAME="$1"
DISPLAY="${2:-Python ($NAME)}"
VENV_DIR="$HOME/venvs/$NAME"

echo "==> [1/4] Creating virtual environment at '$VENV_DIR'..."
mkdir -p "$HOME/venvs"
python3 -m venv "$VENV_DIR"

echo "==> [2/4] Upgrading pip and installing ipykernel..."
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install ipykernel

echo "==> [3/4] Registering Jupyter kernel..."
"$VENV_DIR/bin/python" -m ipykernel install --user --name="$NAME" --display-name="$DISPLAY"

echo "==> [4/4] Done!"
echo "Kernel '$DISPLAY' successfully registered."
echo "Activate anytime with: source $VENV_DIR/bin/activate"
```

**Make it executable and run:**
```bash
chmod +x setup_kernel.sh
./setup_kernel.sh data "Python (Data)"
```

---

### Windows Command Prompt (`setup_kernel.bat`)

Create a script named `setup_kernel.bat`:

```batch
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
```

**Usage:**
```cmd
setup_kernel.bat data "Python (Data)"
```

---

### Windows PowerShell (`setup_kernel.ps1`)

Create a script named `setup_kernel.ps1`:

```powershell
<#
================================================================================
Script: setup_kernel.ps1
Purpose: Automatically create a venv and register kernel in Windows PowerShell
Usage: .\setup_kernel.ps1 -KernelName data -DisplayName "Python (Data)"
================================================================================
#>

param (
    [Parameter(Mandatory=$true)][string]$KernelName,
    [Parameter(Mandatory=$false)][string]$DisplayName = "Python ($KernelName)"
)

$ErrorActionPreference = "Stop"

$VenvsParent = Join-Path $HOME "venvs"
$VenvDir = Join-Path $VenvsParent $KernelName

if (-not (Test-Path $VenvsParent)) {
    New-Item -ItemType Directory -Path $VenvsParent | Out-Null
}

Write-Host "==> [1/4] Creating virtual environment at $VenvDir..." -ForegroundColor Cyan
python -m venv $VenvDir

$PipPath = Join-Path $VenvDir "Scripts\pip.exe"
$PythonPath = Join-Path $VenvDir "Scripts\python.exe"

Write-Host "==> [2/4] Upgrading pip and installing ipykernel..." -ForegroundColor Cyan
& $PythonPath -m pip install --upgrade pip
& $PipPath install ipykernel

Write-Host "==> [3/4] Registering kernel with Jupyter..." -ForegroundColor Cyan
& $PythonPath -m ipykernel install --user --name=$KernelName --display-name="$DisplayName"

Write-Host "`n[4/4] Success! Kernel '$DisplayName' is ready in Jupyter." -ForegroundColor Green
Write-Host "Activate anytime with: & `"$VenvDir\Scripts\Activate.ps1`"" -ForegroundColor Yellow
```

**Usage:**
```powershell
.\setup_kernel.ps1 -KernelName data -DisplayName "Python (Data)"
```
