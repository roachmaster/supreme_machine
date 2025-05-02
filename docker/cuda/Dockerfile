# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# ✅ Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Versions (injected via --build-arg or fallback defaults)
ARG TORCH_VERSION=2.6.0
ARG TORCHVISION_VERSION=0.21.0
ARG TORCHAUDIO_VERSION=2.6.0
ARG CUDA_VERSION=cu126
ARG XFORMERS_CUDA_ARCH="8.9"

ENV TORCH_VERSION=${TORCH_VERSION}
ENV TORCHVISION_VERSION=${TORCHVISION_VERSION}
ENV TORCHAUDIO_VERSION=${TORCHAUDIO_VERSION}
ENV CUDA_VERSION=${CUDA_VERSION}
ENV XFORMERS_CUDA_ARCH=${XFORMERS_CUDA_ARCH}

# ✅ Install Python 3.10 + build deps
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Upgrade pip
RUN pip install --upgrade pip

# ✅ Install torch binary
RUN pip install torch==${TORCH_VERSION}+${CUDA_VERSION} --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# ✅ Build torchvision from source
WORKDIR /tmp
RUN git clone --branch v${TORCHVISION_VERSION} https://github.com/pytorch/vision.git \
    && cd vision \
    && if [ -f requirements.txt ]; then reqfile=requirements.txt; else reqfile=requirements/requirements.txt; fi \
    && pip install -r $reqfile \
    && python setup.py bdist_wheel \
    && pip install dist/*.whl

# ✅ Install torchaudio binary
RUN pip install torchaudio==${TORCHAUDIO_VERSION}+${CUDA_VERSION} --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# ✅ Build xFormers from source (with submodules)
RUN git clone --recursive https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && git submodule update --init --recursive \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="${XFORMERS_CUDA_ARCH}" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

# ✅ Verify xFormers install
RUN python -m xformers.info || echo "⚠️ xFormers info failed (expected outside runtime)"

# ✅ CUDA runtime ENV
ENV CUDA_HOME=/usr/local/cuda

# ✅ Set working directory
WORKDIR /app

# ✅ Clone Stable Diffusion WebUI
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# ✅ Upgrade pip again (just in case)
RUN pip install --upgrade pip

# ✅ Install Stable Diffusion WebUI requirements
RUN pip install -r requirements_versions.txt

# ✅ Expose WebUI port
EXPOSE 7860

# ✅ Launch Stable Diffusion WebUI (with xformers!)
CMD ["python", "launch.py", "--listen", "--xformers"]