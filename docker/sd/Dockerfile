FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git python3 python3-pip wget curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . /app
RUN pip3 install -r requirements.txt
EXPOSE 7860
CMD ["python3", "launch.py", "--listen", "--xformers"]