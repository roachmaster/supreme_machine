FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python and build tools
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch
RUN pip install --upgrade pip
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# Clone Stable Diffusion WebUI
WORKDIR /app
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# Install xFormers from source
RUN pip install ninja
RUN git clone https://github.com/facebookresearch/xformers.git /tmp/xformers \
    && cd /tmp/xformers \
    && pip install . \
    && cd /app \
    && rm -rf /tmp/xformers

# Install WebUI dependencies
RUN pip install -r requirements_versions.txt

EXPOSE 7860

CMD ["python", "launch.py", "--listen", "--xformers"]