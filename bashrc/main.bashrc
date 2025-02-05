#!/bin/bash
# main.bashrc
# Dynamically determine the absolute directory path for this file
# and then source llm.bashrc and nvidia.bashrc from that directory.

# Get the absolute path to this file's directory
BASHRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "main.bashrc directory: $BASHRC_DIR"

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
