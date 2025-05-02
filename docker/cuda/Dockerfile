# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# ✅ Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install Python 3.10 + build tools
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Upgrade pip
RUN pip install --upgrade pip

# ✅ Force reinstall PyTorch + compatible torchvision + torchaudio for CUDA 12.6
RUN pip install --force-reinstall \
    torch==2.7.0+cu126 \
    torchvision==0.21.0+cu126 \
    torchaudio==2.7.0+cu126 \
    --extra-index-url https://download.pytorch.org/whl/cu126

# ✅ Build xFormers from source
WORKDIR /tmp
RUN git clone https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="8.9" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

# ✅ Debug xFormers install info
RUN python -m xformers.info || echo "⚠️ xFormers info failed (expected outside runtime)"

# ✅ Set working directory for apps depending on this base
WORKDIR /app

# ✅ DONE: use this image as a base for other Dockerfiles