#!/bin/bash
set -e

##############################
# Main function that calls all steps
##############################
main() {
    update_system_and_upgrade
    check_nvidia_gpu_status
    verify_or_install_docker
    configure_ufw_firewall_rules
}

##############################
# Step 1: System Update & Upgrade
##############################
update_system_and_upgrade() {
    echo "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    echo "System update complete."
}

##############################
# Step 2: Check NVIDIA GPU Status
##############################
check_nvidia_gpu_status() {
    echo "Checking NVIDIA GPU status..."
    if command -v nvidia-smi >/dev/null; then
        nvidia-smi
    else
        echo "nvidia-smi not found; verify NVIDIA driver installation."
    fi
}

##############################
# Step 3: Verify or Install Docker
##############################
verify_or_install_docker() {
    echo "Verifying Docker installation..."
    if command -v docker >/dev/null; then
        echo "Docker is installed."
    else
        install_docker
    fi
}

# Sub-function for installing Docker (5 lines maximum)
install_docker() {
    echo "Installing Docker..."
    install_docker_prerequisites
    add_docker_repository
    sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y
    echo "Docker installed. Please log out and back in for group changes to take effect."
}

# Install prerequisites for Docker (1 line)
install_docker_prerequisites() { sudo apt install apt-transport-https ca-certificates curl software-properties-common -y; }

# Add Docker repository (2 lines)
add_docker_repository() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

##############################
# Step 5: Verify or Install Docker Compose
##############################
verify_or_install_docker_compose() {
    echo "Verifying Docker Compose installation..."
    if command -v docker-compose >/dev/null; then
        echo "Docker Compose is installed."
    else
        install_docker_compose
    fi
}

##############################
# Step 8: Configure UFW Firewall Rules
##############################
configure_ufw_firewall_rules() {
    if command -v ufw >/dev/null; then
        sudo ufw allow 8000/tcp
        echo "UFW configured: port 8000 allowed."
    else
        echo "UFW not installed. To secure the server, consider installing ufw."
    fi
}

# Call main function
main "$@"
