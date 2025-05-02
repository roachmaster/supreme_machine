# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install Python + build tools
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Install PyTorch for CUDA 12.1 (or match your CUDA version)
RUN pip install --upgrade pip \
    && pip install torch==2.1.2+cu121 torchvision==0.16.2+cu121 torchaudio==2.1.2 --extra-index-url https://download.pytorch.org/whl/cu121

# ✅ Clone and build xformers
WORKDIR /tmp
RUN git clone https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && git submodule update --init --recursive \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="8.9" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

# ✅ Move to app directory
WORKDIR /app

# ✅ Clone Stable Diffusion WebUI into a clean directory
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /tmp/sdwebui && \
    rm -rf /app/* && \
    cp -r /tmp/sdwebui/* /app/ && \
    cp -r /tmp/sdwebui/.* /app/ || true

# ✅ Install WebUI deps
RUN pip install -r requirements_versions.txt

# ✅ Debug xformers info
RUN python -m xformers.info || echo "⚠️ xFormers info failed (expected outside runtime)"

EXPOSE 7860

CMD ["python", "launch.py", "--listen", "--xformers"]