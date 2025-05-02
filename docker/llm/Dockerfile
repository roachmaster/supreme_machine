# Use an Ubuntu-based CUDA image with cuDNN for deep learning
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0

# Install system packages
RUN apt-get update && \
    apt-get install -y \
        python3 python3-pip \
        git curl ca-certificates openssh-client \
        libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch (you can pin versions here if needed)
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Prepare SSH key for Ollama
RUN mkdir -p /root/.ollama && \
    ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519 && \
    chmod 700 /root/.ollama && chmod 600 /root/.ollama/id_ed25519

# Optional: expose Ollama default port (use if serving externally)
EXPOSE 11434

# Copy your local app code into /app (if applicable)
WORKDIR /app
COPY . /app

# By default, start Ollama server
CMD ["ollama", "serve"]