#!/bin/bash
# install_nvidia_docker.sh
# This script installs the NVIDIA Container Toolkit (Step 4).

set -e

echo "----------------------------"
echo "Installing NVIDIA Container Toolkit..."
echo "----------------------------"

distribution=$(. /etc/os-release; echo "$ID""$VERSION_ID")
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/"$distribution"/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update
sudo apt install -y nvidia-docker2
sudo systemctl restart docker

echo "Testing NVIDIA Docker support..."
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

echo "NVIDIA Container Toolkit installation complete."
