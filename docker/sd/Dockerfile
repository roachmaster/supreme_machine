# ✅ BASE IMAGE
FROM my-cuda-base:torch2.7-cu126-xformers

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# ✅ Clone Stable Diffusion WebUI
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git .

# ✅ Install WebUI requirements
RUN pip install --upgrade pip
RUN pip install -r requirements_versions.txt

# ✅ Install ControlNet extension
RUN git clone https://github.com/Mikubill/sd-webui-controlnet.git /app/extensions/sd-webui-controlnet
RUN pip install -r /app/extensions/sd-webui-controlnet/requirements.txt

# ✅ Install AnimateDiff extension
RUN git clone https://github.com/continue-revolution/sd-webui-animatediff.git /app/extensions/sd-webui-animatediff
RUN pip install -r /app/extensions/sd-webui-animatediff/requirements.txt

# ✅ (Optional) You can pre-download models here if needed:
# COPY controlnet-models/*.pth /app/extensions/sd-webui-controlnet/models/
# COPY animatediff-models/*.ckpt /app/extensions/sd-webui-animatediff/models/

EXPOSE 7860

CMD ["python", "launch.py", "--listen", "--xformers"]