# Use an Ubuntu-based CUDA image with cuDNN for deep learning
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages (including curl, ca-certificates, and ssh-keygen)
RUN apt-get update && \
    apt-get install -y python3 python3-pip git curl ca-certificates openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch + Transformers (if needed)
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Pre-generate an Ed25519 SSH key for Ollama
RUN mkdir -p /root/.ollama && \
    ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519

# Pull the deepseek-r1:7b model in advance
# (This will download the model so it's available in the image)
RUN ollama pull deepseek-r1:7b

# Copy your LLM scripts into the container (if you have them locally)
WORKDIR /app
COPY . /app

# By default, start the Ollama server
CMD ["ollama", "serve"]
