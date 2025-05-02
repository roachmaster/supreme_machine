FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    pkg-config libjpeg-dev zlib1g-dev \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

# Core AI/ML/LLM libraries
RUN pip install \
    torch==2.7.0+cu126 torchvision==0.22.0+cu126 torchaudio==2.7.0+cu126 \
    --extra-index-url https://download.pytorch.org/whl/cu126 \
    transformers diffusers \
    scikit-learn pandas matplotlib seaborn tqdm \
    opencv-python-headless pillow \
    jupyterlab ipython \
    onnxruntime-gpu tensorrt \
    tritonclient[all]

# Optional: Build xFormers from source (already in your image!)
WORKDIR /tmp
RUN git clone --recursive https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && git submodule update --init --recursive \
    && pip install -r requirements.txt \
    && TORCH_CUDA_ARCH_LIST="8.9" FORCE_CUDA=1 python setup.py bdist_wheel \
    && pip install dist/*.whl

RUN python -m xformers.info || echo "⚠️ xFormers info failed"

WORKDIR /
RUN rm -rf /tmp/*