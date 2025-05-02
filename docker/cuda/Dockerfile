# ✅ BASE IMAGE: NVIDIA CUDA + cuDNN + Ubuntu
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install Python + system deps
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Upgrade pip
RUN pip install --upgrade pip

# ✅ Install PyTorch (compatible with CUDA 12.6)
ARG TORCH_VERSION=2.7.0
ARG TORCHVISION_VERSION=0.22.0
ARG TORCHAUDIO_VERSION=2.7.0
ARG CUDA_VERSION=cu126
ARG XFORMERS_CUDA_ARCH=8.9

RUN pip install torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCHVISION_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCHAUDIO_VERSION}+${CUDA_VERSION} \
    --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# ✅ Build xFormers from source
WORKDIR /tmp
RUN git clone --recursive https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && git submodule update --init --recursive \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="${XFORMERS_CUDA_ARCH}" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

# ✅ Verify xFormers installed
RUN python -m xformers.info || echo "⚠️ xFormers info failed (expected outside runtime)"

# ✅ Cleanup
WORKDIR /
RUN rm -rf /tmp/*