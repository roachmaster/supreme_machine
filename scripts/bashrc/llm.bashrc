# llm.bashrc
# Functions for daily LLM Docker tasks (no docker-compose)

# Stop (and remove) the LLM container
llm-stop() {
    docker stop ollama 2>/dev/null || true
    docker rm ollama 2>/dev/null || true
}

# Tail the logs for the LLM container
llm-logs() {
    docker logs -f ollama
}

# Build (or rebuild) the LLM image from a Dockerfile (assuming local Dockerfile)
llm-rebuild() {
    # Adjust the Docker build context and Dockerfile path as needed.
    docker build -t my-ollama-llm .
}

# Show the status of the LLM container
llm-status() {
    docker ps -f name=ollama
}

# Pull the latest version of the LLM image from a registry
llm-pull() {
    docker pull my-ollama-llm
}

# Run the LLM container
llm-image-run(){
    # Stop any running container named ollama first
    llm-stop

    docker run -d \
      --name ollama \
      --gpus all \
      -v /home/lrocha/data/ollama_data:/root/.ollama \
      -p 11434:11434 \
      my-ollama-llm
}

open-webui-stop(){
    # Stop any existing container named open-webui
    docker stop open-webui 2>/dev/null || true
    docker rm open-webui 2>/dev/null || true
}

# Run the Open WebUI container
open-webui-run(){
    # Stop any existing container named open-webui
    docker stop open-webui 2>/dev/null || true
    docker rm open-webui 2>/dev/null || true

    docker run -d \
    -e PORT=3000 \
    -p 0.0.0.0:3000:3000 \
    --gpus all \
    --add-host=host.docker.internal:host-gateway \
    -v /home/lrocha/data/open-webui:/app/backend/data \
    --name open-webui \
    --restart always \
    -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
    ghcr.io/open-webui/open-webui:ollama
}