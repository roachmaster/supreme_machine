FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XFORMERS_DISABLE=1  # 🔥 disables xformers globally

# 🟢 Install Python 3.10 and system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    git curl ca-certificates \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python -m ensurepip --upgrade \
    && rm -rf /var/lib/apt/lists/*

# 🟢 Set working directory
WORKDIR /app

# 🟢 Clone Stable Diffusion WebUI
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# 🟢 Upgrade pip explicitly for Python 3.10
RUN python -m pip install --upgrade pip

# 🟢 Install Python dependencies
RUN python -m pip install -r requirements_versions.txt

# 🟢 Expose WebUI port
EXPOSE 7860

# 🟢 Run without --xformers to avoid CUDA build mismatch
CMD ["python", "launch.py", "--listen"]