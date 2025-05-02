# Use an Ubuntu-based CUDA image
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

# Suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0

# Install required system packages (OpenCV fix: libgl1-mesa-glx + libglib2.0-0)
RUN apt-get update && \
    apt-get install -y \
        python3 python3-pip \
        git curl ca-certificates openssh-client \
        libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch + Transformers
RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Generate SSH key for Ollama
RUN mkdir -p /root/.ollama && \
    ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519 && \
    chmod 700 /root/.ollama && chmod 600 /root/.ollama/id_ed25519

# Copy your app code
WORKDIR /app
COPY . /app

# Expose default Ollama port
EXPOSE 11434

# Start Ollama server
CMD ["ollama", "serve"]