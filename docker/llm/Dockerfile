# Use an Ubuntu-based CUDA image with cuDNN for deep learning
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0

# Install system packages (including libgl1 for OpenCV)
RUN apt-get update && \
    apt-get install -y \
        python3 python3-pip \
        git curl ca-certificates openssh-client \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch + Transformers (optional: pin versions if needed)
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Generate SSH key for Ollama
RUN mkdir -p /root/.ollama && \
    ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519 && \
    chmod 700 /root/.ollama && chmod 600 /root/.ollama/id_ed25519

# Copy your application code
WORKDIR /app
COPY . /app

# Expose default Ollama port
EXPOSE 11434

# Start Ollama server by default
CMD ["ollama", "serve"]