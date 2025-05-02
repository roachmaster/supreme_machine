# ✅ BASE IMAGE
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# ✅ Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install Python 3.10 + build dependencies
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    build-essential cmake ninja-build \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ WORKDIR
WORKDIR /app

# ✅ Clone Stable Diffusion WebUI
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# ✅ Upgrade pip and install python dependencies (except xformers)
RUN pip install --upgrade pip \
    && pip install -r requirements_versions.txt --extra-index-url https://download.pytorch.org/whl/cu121

# ✅ Install xFormers from source (compiles inside Docker)
RUN pip install ninja \
    && pip install git+https://github.com/facebookresearch/xformers.git

# ✅ EXPOSE port
EXPOSE 7860

# ✅ Run WebUI
CMD ["python", "launch.py", "--listen", "--xformers"]