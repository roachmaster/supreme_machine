# Use an Ubuntu-based CUDA image with cuDNN for deep learning
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages (including curl and ca-certificates)
RUN apt-get update && \
    apt-get install -y python3 python3-pip git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch + Transformers (for example)
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy your LLM scripts into the container (if you have them locally)
WORKDIR /app
COPY . /app

# By default, open a Bash shell
CMD ["/bin/bash"]
