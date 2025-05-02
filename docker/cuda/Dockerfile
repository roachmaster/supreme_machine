# docker/cuda/Dockerfile

# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# ✅ Build args
ARG TORCH_VERSION
ARG CUDA_VERSION
ARG TORCHVISION_VERSION
ARG TORCHAUDIO_VERSION
ARG XFORMERS_CUDA_ARCH

# ✅ Debug
RUN echo "Building with torch ${TORCH_VERSION}+${CUDA_VERSION}, torchvision ${TORCHVISION_VERSION}+${CUDA_VERSION}"

# ✅ Install Python + build deps
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

# ✅ Install torch/vision/audio dynamically
RUN pip install --force-reinstall \
    torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCHVISION_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCHAUDIO_VERSION}+${CUDA_VERSION} \
    --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# ✅ Build xformers from source
WORKDIR /tmp
RUN git clone https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="${XFORMERS_CUDA_ARCH}" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

RUN python -m xformers.info || echo "⚠️ xFormers info debug output"

# ✅ Final working directory
WORKDIR /app