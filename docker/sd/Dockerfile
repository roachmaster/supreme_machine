FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git python3 python3-pip wget curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . /appFROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu20.04

           ENV DEBIAN_FRONTEND=noninteractive
           ENV OLLAMA_HOST=0.0.0.0

           RUN apt-get update && apt-get install -y \
               python3 python3-pip \
               git curl ca-certificates openssh-client \
               libgl1-mesa-glx libgl1-mesa-dev libglib2.0-0 \
               && rm -rf /var/lib/apt/lists/*

           RUN pip3 install --no-cache-dir torch torchvision torchaudio transformers

           RUN curl -fsSL https://ollama.com/install.sh | sh

           RUN mkdir -p /root/.ollama && \
               ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519 && \
               chmod 700 /root/.ollama && chmod 600 /root/.ollama/id_ed25519

           WORKDIR /app
           COPY . /app

           EXPOSE 11434

           CMD ["ollama", "serve"]
RUN pip3 install -r requirements.txt
EXPOSE 7860
CMD ["python3", "launch.py", "--listen", "--xformers"]