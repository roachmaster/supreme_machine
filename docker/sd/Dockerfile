# ✅ BASE IMAGE (use prebuilt CUDA + Torch + xFormers base image)
FROM my-cuda-base:torch2.7-cu126-xformers

# ✅ Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Switch to /app working directory
WORKDIR /app

# ✅ Clone Stable Diffusion WebUI repo (clean directory before clone)
RUN rm -rf /app/* && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# ✅ Upgrade pip again just in case
RUN pip install --upgrade pip

# ✅ Install WebUI-specific dependencies
RUN pip install -r requirements_versions.txt

# ✅ Optional debug xformers install
RUN python -m xformers.info || echo "⚠️ xFormers info failed (expected outside runtime)"

# ✅ Expose default WebUI port
EXPOSE 7860

# ✅ Launch Stable Diffusion WebUI
CMD ["python", "launch.py", "--listen", "--xformers"]