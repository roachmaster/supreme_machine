#!/bin/zsh
# run-mustache.zsh
# This script dynamically gets the current script directory,
# sets SUPREME_MACHINE_DIR to one level up, and runs Mustache CLI
# against the specified template and data files.

# Get the directory where this script resides
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Set SUPREME_MACHINE_DIR to the parent directory of SCRIPT_DIR
SUPREME_MACHINE_DIR="$(dirname "$SCRIPT_DIR")"

# Define the paths to the template and data files
TEMPLATE_FILE="${SUPREME_MACHINE_DIR}/templates/docker-compose.mustache"
DATA_FILE="${SUPREME_MACHINE_DIR}/template_data/docker-compose-data.json"

# Check that the template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file not found at $TEMPLATE_FILE"
  exit 1
fi

# Check that the data file exists
if [ ! -f "$DATA_FILE" ]; then
  echo "Error: Data file not found at $DATA_FILE"
  exit 1
fi

# Run the Mustache CLI to process the template with the data
mustache "$DATA_FILE" "$TEMPLATE_FILE" "$SUPREME_MACHINE_DIR/yaml/docker-compose.yaml"
