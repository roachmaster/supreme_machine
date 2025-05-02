#!/bin/bash
# install_nvidia_docker.sh
# This script installs the NVIDIA Container Toolkit (Step 4).

set -e

echo "----------------------------"
echo "Installing NVIDIA Container Toolkit..."
echo "----------------------------"

# Manually override distribution value to a supported version.
# Change "ubuntu20.04" to the supported version for your system if needed.
distribution="ubuntu20.04"

# Download and install the NVIDIA GPG key into a keyring file.
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-docker.gpg

# Add the NVIDIA Docker repository using the overridden distribution.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/nvidia-docker.gpg] https://nvidia.github.io/nvidia-docker/$distribution/$(dpkg --print-architecture) /" | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt update
sudo apt install -y nvidia-docker2
sudo systemctl restart docker

echo "Testing NVIDIA Docker support..."
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

echo "NVIDIA Container Toolkit installation complete."
