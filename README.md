# Jupyter Custom Kernel Guide

## Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution-one-virtual-environment--one-kernel)
- Setup
  - [Linux Setup](#step-by-step-setup-linux)
  - [Windows Setup](#step-by-step-setup-windows)
- [How It Works](#how-it-works)
- [Adding Libraries to Existing Kernel](#how-to-add-new-libraries-to-an-existing-kernel)
- [Managing Multiple Kernels](#managing-multiple-kernels)
- [List / Remove Kernels](#list--remove-kernels)
- [Check Kernel's Python](#bonus-check-kernels-python)
- Quick Scripts
  - [Linux Script](#linux-setup_kernelsh)
  - [Windows Script](#windows-setup_kernelbat)

---

## The Problem

When you use Jupyter Notebook/Lab, the default `python3` kernel uses the Python that comes with Jupyter. If you `pip install pandas` in your terminal, it does NOT go into that kernel's Python. So every time you open a notebook, you find your libraries missing.

You end up doing things like:

```python
import sys
!pip install pandas   # inside notebook — slow and messy
```

## The Solution: One Virtual Environment = One Kernel

Create a dedicated virtual environment for each project. Install your libraries once inside it. Register it as a Jupyter kernel. Now every notebook that uses that kernel has **all libraries ready** — no repeated installs, no manual activation.

---

## Step-by-Step Setup (Linux)

### Step 1: Create a virtual environment

```bash
python3 -m venv ~/venvs/data
```

This creates a folder `~/venvs/data` with its own Python and pip.

### Step 2: Activate and install libraries

```bash
source ~/venvs/data/bin/activate
pip install pandas numpy matplotlib scipy jupyter
```

Install once. Everything stays inside this venv.

### Step 3: Register as a Jupyter kernel

```bash
source ~/venvs/data/bin/activate
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

This creates a kernel folder at:

```
~/.local/share/jupyter/kernels/data/
```

Inside it, a `kernel.json` file tells Jupyter which Python to launch.

### Step 4: Use it

Open Jupyter, click **Kernel > Change Kernel**, and select **"Python (Data)"**. All installed libraries are available immediately.

---

## Step-by-Step Setup (Windows)

Same steps, but commands differ slightly.

### Step 1: Create a virtual environment

Open **Command Prompt** or **PowerShell** and run:

```cmd
python -m venv %USERPROFILE%\venvs\data
```

This creates a folder `C:\Users\YourName\venvs\data` with its own Python and pip.

> **Note:** Use `python` (not `python3`) on Windows. If `python` is not found, try `py`.

### Step 2: Activate and install libraries

```cmd
%USERPROFILE%\venvs\data\Scripts\activate
pip install pandas numpy matplotlib scipy jupyter
```

You should see `(data)` appear in your prompt, meaning the venv is active.

### Step 3: Register as a Jupyter kernel

```cmd
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

This creates a kernel folder at:

```
%USERPROFILE%\AppData\Roaming\jupyter\kernels\data\
```

Inside it, a `kernel.json` file tells Jupyter which Python to launch.

### Step 4: Use it

Open Jupyter, click **Kernel > Change Kernel**, and select **"Python (Data)"**. All installed libraries are available immediately.

---

## How It Works

A kernel is just a `kernel.json` file.

**Linux example:**

```json
{
 "argv": [
  "/home/username/venvs/data/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python (Data)",
 "language": "python"
}
```

**Windows example:**

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
 "language": "python"
}
```

Jupyter reads this file, launches the specified Python, and connects to it. The Python it launches uses the libraries installed in that venv — not the system Python, not the Jupyter pipx Python.

---

## How to Add New Libraries to an Existing Kernel

Already have a kernel but need a new library? **Do NOT `!pip install` inside the notebook.** Instead, install it in the kernel's virtual environment once, and it stays forever.

### Method 1: Activate the venv and install (recommended)

**Linux:**
```bash
source ~/venvs/data/bin/activate    # activate the kernel's venv
pip install statsmodels             # install new library
```

**Windows:**
```cmd
%USERPROFILE%\venvs\data\Scripts\activate
pip install statsmodels
```

That's it. The next time you use the **"Python (Data)"** kernel, `import statsmodels` will work.

### Method 2: Find the venv path from kernel.json

If you forgot which venv a kernel uses:

**Linux:**
```bash
cat ~/.local/share/jupyter/kernels/data/kernel.json
```

**Windows:**
```cmd
type %USERPROFILE%\AppData\Roaming\jupyter\kernels\data\kernel.json
```

Look at the `argv` line — it shows the full path to the Python executable.

**Linux example:** if argv shows `/home/radwan/venvs/data/bin/python`, the venv is `/home/radwan/venvs/data`.

```bash
source /home/radwan/venvs/data/bin/activate
pip install seaborn
```

**Windows example:** if argv shows `C:\Users\YourName\venvs\data\Scripts\python.exe`, the venv is `C:\Users\YourName\venvs\data`.

```cmd
%USERPROFILE%\venvs\data\Scripts\activate
pip install seaborn
```

### Method 3: Install from inside a notebook (if you must)

Run this in a notebook cell **using the correct kernel** (works on both Linux and Windows):

```python
import sys
!{sys.executable} -m pip install seaborn
```

This uses the kernel's own pip, not the system pip. But Method 1 is cleaner.

---

## Managing Multiple Kernels

| Kernel Name | Display Name | Venv Path | Libraries |
|-------------|-------------|-----------|-----------|
| `data` | Python (Data) | `~/venvs/data` | numpy, pandas, matplotlib, scipy |
| `ml` | Python (ML) | `~/venvs/ml` | torch, sklearn, transformers |
| `econ` | Python (Econ) | `~/venvs/econ` | statsmodels, linearmodels |

**Linux / Windows (same command):**
```bash
python -m ipykernel install --user --name=ml --display-name="Python (ML)"
python -m ipykernel install --user --name=econ --display-name="Python (Econ)"
```

---

## List / Remove Kernels

**Linux / Windows (same commands):**
```bash
# List all kernels
jupyter kernelspec list

# Remove a kernel
jupyter kernelspec remove data
```

---

## Bonus: Check Kernel's Python

In any notebook cell, run:

```python
import sys
print(sys.executable)
```

This shows which Python the kernel is actually using. It should point to your venv path, not the system Python.

---

## Quick Setup Scripts

### Linux (`setup_kernel.sh`)

```bash
#!/bin/bash
NAME=$1
DISPLAY=$2
VENV_DIR=~/venvs/$NAME

python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate
pip install jupyter ipykernel
python -m ipykernel install --user --name=$NAME --display-name="$DISPLAY"
echo "Kernel '$NAME' created. Activate with: source $VENV_DIR/bin/activate"
```

Usage:
```bash
bash setup_kernel.sh data "Python (Data)"
```

### Windows (`setup_kernel.bat`)

```batch
@echo off
SET NAME=%1
SET DISPLAY=%2
SET VENV_DIR=%USERPROFILE%\venvs\%NAME%

python -m venv %VENV_DIR%
call %VENV_DIR%\Scripts\activate
pip install jupyter ipykernel
python -m ipykernel install --user --name=%NAME% --display-name="%DISPLAY%"
echo Kernel '%NAME%' created.
```

Usage:
```cmd
setup_kernel.bat data "Python (Data)"
```
