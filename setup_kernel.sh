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
