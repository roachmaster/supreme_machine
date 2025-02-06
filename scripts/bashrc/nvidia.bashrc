# nvidia.bashrc
# Functions for common NVIDIA and system monitoring tasks

# Display current GPU status
gpu-status() {
    nvidia-smi
}

# Continuously monitor GPU usage every 2 seconds
gpu-watch() {
    watch -n 2 nvidia-smi
}

# Open an interactive system monitor (htop)
sys-monitor() {
    htop
}

# List Docker containers that use the NVIDIA CUDA image
docker-gpu() {
    docker ps --filter "ancestor=nvidia/cuda"
}

# Tail logs for a specified Docker container (pass container ID/name as parameter)
nvidia-docker-logs() {
    if [ -z "$1" ]; then
        echo "Usage: nvidia-docker-logs <container_id_or_name>"
    else
        docker logs "$1"
    fi
}
