# Jupyter Custom Kernel Guide

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

## Step-by-Step Setup

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

## How It Works

A kernel is just a `kernel.json` file. Example:

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

Jupyter reads this file, launches the specified Python, and connects to it. The Python it launches uses the libraries installed in that venv — not the system Python, not the Jupyter pipx Python.

---

## How to Add New Libraries to an Existing Kernel

Already have a kernel but need a new library? **Do NOT `!pip install` inside the notebook.** Instead, install it in the kernel's virtual environment once, and it stays forever.

### Method 1: Activate the venv and install (recommended)

```bash
source ~/venvs/data/bin/activate    # activate the kernel's venv
pip install statsmodels             # install new library
```

That's it. The next time you use the **"Python (Data)"** kernel, `import statsmodels` will work.

### Method 2: Find the venv path from kernel.json

If you forgot which venv a kernel uses:

```bash
cat ~/.local/share/jupyter/kernels/data/kernel.json
```

Look at the `argv` line — it shows the full path to the Python executable. The venv folder is two levels up from `bin/python`.

Example: if argv shows `/home/radwan/venvs/data/bin/python`, the venv is `/home/radwan/venvs/data`.

Then activate and install:

```bash
source /home/radwan/venvs/data/bin/activate
pip install seaborn
```

### Method 3: Install from inside a notebook (if you must)

Run this in a notebook cell **using the correct kernel**:

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

```bash
python -m ipykernel install --user --name=ml --display-name="Python (ML)"
python -m ipykernel install --user --name=econ --display-name="Python (Econ)"
```

---

## List / Remove Kernels

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

## Quick Setup Script

Save this as `setup_kernel.sh`:

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
