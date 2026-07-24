#!/bin/bash
# Usage: bash setup_kernel.sh <name> <display-name>
# Example: bash setup_kernel.sh econ "Python (Econ)"

NAME=$1
DISPLAY=$2
VENV_DIR=~/venvs/$NAME

if [ -z "$NAME" ] || [ -z "$DISPLAY" ]; then
    echo "Usage: bash setup_kernel.sh <name> <display-name>"
    echo "Example: bash setup_kernel.sh econ 'Python (Econ)'"
    exit 1
fi

echo "Creating virtual environment at $VENV_DIR ..."
python3 -m venv $VENV_DIR

echo "Installing jupyter and ipykernel ..."
source $VENV_DIR/bin/activate
pip install --quiet jupyter ipykernel

echo "Registering kernel '$NAME' with display name '$DISPLAY' ..."
python -m ipykernel install --user --name=$NAME --display-name="$DISPLAY"

echo "Done! Kernel '$NAME' created."
echo "To install packages: source $VENV_DIR/bin/activate && pip install <package>"
