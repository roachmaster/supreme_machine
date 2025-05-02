# Use an Ubuntu-based CUDA image with cuDNN
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0

# Install required system packages (fix OpenCV libGL.so.1 error)
RUN apt-get update && \
    apt-get install -y \
        python3 python3-pip \
        git curl ca-certificates openssh-client \
        libgl1-mesa-glx libgl1-mesa-dev libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch + Transformers
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Generate SSH key for Ollama
RUN mkdir -p /root/.ollama && \
    ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519 && \
    chmod 700 /root/.ollama && chmod 600 /root/.ollama/id_ed25519

# Set working directory
WORKDIR /app

# Copy local application code (optional; remove if not needed)
COPY . /app

# Expose Ollama default port
EXPOSE 11434

# Start Ollama server
CMD ["ollama", "serve"]