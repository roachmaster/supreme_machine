# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# ✅ Non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install system deps
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Upgrade pip
RUN pip install --upgrade pip

# ✅ Force reinstall torch globally
RUN pip install --force-reinstall torch==2.7.0+cu126 torchvision==0.16.2+cu126 torchaudio==2.7.0+cu126 --extra-index-url https://download.pytorch.org/whl/cu126

# ✅ Build xFormers from source
WORKDIR /tmp
RUN git clone https://github.com/facebookresearch/xformers.git && \
    cd xformers && \
    pip install -r requirements.txt && \
    TORCH_CUDA_ARCH_LIST="8.9" FORCE_CUDA=1 python setup.py bdist_wheel && \
    pip install dist/*.whl

# ✅ Cleanup build files
RUN rm -rf /tmp/xformers

# ✅ Set working directory for downstream apps
WORKDIR /app

# ✅ Labels for clarity
LABEL maintainer="you@example.com" \
      description="Base CUDA + PyTorch + xFormers image for Ada/SD"

# ✅ Final message
RUN echo "🎉 CUDA + PyTorch 2.7.0 + xFormers built for sm_89 ready!"

# ✅ Image is ready to extend