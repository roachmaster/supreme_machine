# llm.bashrc
# Functions for daily LLM and Stable Diffusion Docker tasks (no docker-compose)

# Load GHCR token from ~/.ghcr_token and export as env var
read-ghcr-token() {
    if [ -f ~/.ghcr_token ]; then
        export GHCR_TOKEN=$(< ~/.ghcr_token)
        echo "✅ GHCR token loaded and exported as GHCR_TOKEN."
    else
        echo "❌ Token file ~/.ghcr_token not found."
    fi
}

# Login to GitHub Container Registry using exported token
docker-ghcr-login() {
    if [ -z "$GHCR_TOKEN" ]; then
        echo "❌ GHCR_TOKEN is not set. Run 'read-ghcr-token' first."
        return 1
    fi
    echo "$GHCR_TOKEN" | docker login ghcr.io -u $USER --password-stdin
}

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
    llm-stop
    docker run -d \
      --name ollama \
      --gpus all \
      -v /home/lrocha/data/ollama_data:/root/.ollama \
      -p 11434:11434 \
      my-ollama-llm
}

open-webui-stop(){
    docker stop open-webui 2>/dev/null || true
    docker rm open-webui 2>/dev/null || true
}

# Run the Open WebUI container
open-webui-run(){
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

# Stop (and remove) the Stable Diffusion container
sd-stop() {
    docker stop stable-diffusion 2>/dev/null || true
    docker rm stable-diffusion 2>/dev/null || true
}

# Tail logs for Stable Diffusion
sd-logs() {
    docker logs -f stable-diffusion
}

# Pull latest image for Automatic1111
sd-pull() {
    read-ghcr-token
    docker-ghcr-login || return 1
    docker pull ghcr.io/abdbarho/stable-diffusion-webui:automatic
}

# Run Stable Diffusion container
sd-run() {
    read-ghcr-token
    docker-ghcr-login || return 1
    sd-stop
    docker run -d \
        --gpus all \
        --name stable-diffusion \
        -p 7860:7860 \
        -v /home/lrocha/data/stable-diffusion/models:/data/models \
        -v /home/lrocha/data/stable-diffusion/output:/data/output \
        ghcr.io/abdbarho/stable-diffusion-webui:automatic
}

# Check status
sd-status() {
    docker ps -f name=stable-diffusion
}

read-ghcr-token