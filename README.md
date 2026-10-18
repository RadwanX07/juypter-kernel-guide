# Kernel Setup for Data Science

# Linux

# 1. Create the project virtual environment

```bash
mkdir -p ~/venvs
python3 -m venv ~/venvs/data
```

# 2. Activate the virtual environment

```bash
source ~/venvs/data/bin/activate
```

# 3. Install ipykernel and your project dependencies

```bash
pip install --upgrade pip
pip install ipykernel pandas numpy matplotlib scipy scikit-learn
```

# 4. Register the virtual environment as a Jupyter Kernel

```bash
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

# Windows 10/11 (using cmd)

# 1. Create the venv

```cmd
python -m venv %USERPROFILE%\venvs\data
```

# 2. Activate the venv

```cmd
call %USERPROFILE%\venvs\data\Scripts\activate.bat
```

# 3. Install ipykernel and packages

```cmd
python -m pip install --upgrade pip
pip install ipykernel pandas numpy matplotlib scipy scikit-learn
```

# 4. Register the kernel

```cmd
python -m ipykernel install --user --name=data --display-name="Python (Data)"
```

# Then Use Just VS Code

# Adding Libraries to an Existing Kernel

Linux:

```bash
source ~/venvs/data/bin/activate
pip install seaborn scikit-learn
```

Windows (CMD):

```cmd
call %USERPROFILE%\venvs\data\Scripts\activate.bat
pip install seaborn scikit-learn
```

# Inside a Notebook Using %pip

```python
# MODERN STANDARD: Uses the active kernel's Python environment
%pip install seaborn
```

# Managing Multiple Kernels

Organize separate environments for different tech stacks to avoid package conflicts (e.g. PyTorch vs TensorFlow, or conflicting CUDA wheels):

| Kernel Name | Display Name | Purpose | Example Packages |
|---|---|---|---|
| `data` | Python (Data Science) | Tabular analysis & viz | `pandas`, `polars`, `seaborn` |
| `ml` | Python (Machine Learning) | Deep learning & models | `torch`, `torchvision`, `scikit-learn` |
| `nlp` | Python (LLMs & NLP) | Text & transformer models | `transformers`, `accelerate`, `spacy` |
| `scraping` | Python (Web Scraping) | Web automation | `playwright`, `beautifulsoup4`, `httpx` |

# Create another kernel in seconds:

# Example on Linux:

```bash
python3 -m venv ~/venvs/ml
source ~/venvs/ml/bin/activate
pip install ipykernel torch torchvision
python -m ipykernel install --user --name=ml --display-name="Python (Machine Learning)"
```

# Listing & Removing Kernels

# List all registered kernels

```bash
jupyter kernelspec list
```

# Remove an unwanted kernel:

```bash
jupyter kernelspec remove <kernel-name>
```

# Example

```bash
jupyter kernelspec remove data
```
