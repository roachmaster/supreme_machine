FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    git curl ca-certificates \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Clone Stable Diffusion WebUI repo inside container
WORKDIR /app
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Optional: install xformers (comment if not using)
RUN pip install xformers==0.0.20 triton==2.0.0

# Expose Web UI port
EXPOSE 7860

# Run Stable Diffusion WebUI
CMD ["python3", "launch.py", "--listen", "--xformers"]