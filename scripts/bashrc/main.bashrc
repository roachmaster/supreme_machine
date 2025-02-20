#!/bin/bash
# main.bashrc
# Dynamically determine the absolute directory path for this file,
# navigate two levels up, perform a git pull, and then source llm.bashrc and nvidia.bashrc.

# Get the absolute path to this file's directory
BASHRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "main.bashrc directory: $BASHRC_DIR"

# Navigate two levels up
cd "$BASHRC_DIR/../.."

# Perform git pull
if [[ -d .git ]]; then
    echo "Performing git pull in $(pwd)..."
    git pull --rebase
else
    echo "Warning: .git directory not found. Skipping git pull."
fi

# Return to BASHRC_DIR
cd "$BASHRC_DIR"

# Source the llm bash functions file
if [[ -f "$BASHRC_DIR/llm.bashrc" ]]; then
    source "$BASHRC_DIR/llm.bashrc"
    echo "Sourced llm.bashrc successfully."
else
    echo "Warning: llm.bashrc not found in $BASHRC_DIR"
fi

# Source the nvidia bash functions file
if [[ -f "$BASHRC_DIR/nvidia.bashrc" ]]; then
    source "$BASHRC_DIR/nvidia.bashrc"
    echo "Sourced nvidia.bashrc successfully."
else
    echo "Warning: nvidia.bashrc not found in $BASHRC_DIR"
fi
