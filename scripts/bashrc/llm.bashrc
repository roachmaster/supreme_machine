# llm.bashrc
# Functions for daily LLM and Stable Diffusion Docker tasks (no docker-compose)

# Load configuration values from llm-values.bashrc
if [ -f "${BASH_SOURCE%/*}/llm-values.bashrc" ]; then
    source "${BASH_SOURCE%/*}/llm-values.bashrc"
    echo "✅ Loaded llm-values.bashrc from ${BASH_SOURCE%/*}/llm-values.bashrc"
else
    echo "⚠️  llm-values.bashrc not found in ${BASH_SOURCE%/*}. Using defaults."
fi

# Load GHCR token from token file and export as env var
read-ghcr-token() {
    if [ -f "$GHCR_TOKEN_FILE" ]; then
        export GHCR_TOKEN=$(< "$GHCR_TOKEN_FILE")
        echo "✅ GHCR token loaded and exported as GHCR_TOKEN."
    else
        echo "❌ Token file $GHCR_TOKEN_FILE not found."
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
    docker stop "$OLLAMA_CONTAINER" 2>/dev/null || true
    docker rm "$OLLAMA_CONTAINER" 2>/dev/null || true
}

# Tail the logs for the LLM container
llm-logs() {
    docker logs -f "$OLLAMA_CONTAINER"
}

# Build (or rebuild) the LLM image
llm-rebuild() {
    docker build -t "$OLLAMA_IMAGE" .
}

# Show the status of the LLM container
llm-status() {
    docker ps -f "name=$OLLAMA_CONTAINER"
}

# Pull the latest version of the LLM image
llm-pull() {
    docker pull "$OLLAMA_IMAGE"
}

# Run the LLM container
llm-image-run(){
    llm-stop
    docker run -d \
      --name "$OLLAMA_CONTAINER" \
      $DOCKER_GPU_FLAG \
      -v "$OLLAMA_DATA_DIR:/root/.ollama" \
      -p "$OLLAMA_PORT:$OLLAMA_PORT" \
      "$OLLAMA_IMAGE"
}

# Stop (and remove) Open WebUI container
open-webui-stop(){
    docker stop "$OPEN_WEBUI_CONTAINER" 2>/dev/null || true
    docker rm "$OPEN_WEBUI_CONTAINER" 2>/dev/null || true
}

# Run the Open WebUI container
open-webui-run(){
    open-webui-stop
    docker run -d \
    -e PORT="$OPEN_WEBUI_PORT" \
    -p "0.0.0.0:$OPEN_WEBUI_PORT:$OPEN_WEBUI_PORT" \
    $DOCKER_GPU_FLAG \
    --add-host=host.docker.internal:host-gateway \
    -v "$OPEN_WEBUI_DATA_DIR:/app/backend/data" \
    --name "$OPEN_WEBUI_CONTAINER" \
    --restart always \
    -e OLLAMA_BASE_URL="http://127.0.0.1:$OLLAMA_PORT" \
    "$OPEN_WEBUI_IMAGE"
}

# Stop (and remove) Stable Diffusion container
sd-stop() {
    docker stop "$SD_CONTAINER" 2>/dev/null || true
    docker rm "$SD_CONTAINER" 2>/dev/null || true
}

# Tail logs for Stable Diffusion
sd-logs() {
    docker logs -f "$SD_CONTAINER"
}

# Pull latest image for Stable Diffusion
sd-pull() {
    read-ghcr-token
    docker-ghcr-login || return 1
    docker pull "$SD_IMAGE"
}

# Run Stable Diffusion container
sd-run() {
    read-ghcr-token
    docker-ghcr-login || return 1
    sd-stop
    docker run -d \
        $DOCKER_GPU_FLAG \
        --name "$SD_CONTAINER" \
        -p "$SD_PORT:$SD_PORT" \
        -v "$SD_MODELS_DIR:/models" \
        -v "$SD_OUTPUT_DIR:/output" \
        "$SD_IMAGE"
}

# Check Stable Diffusion status
sd-status() {
    docker ps -f "name=$SD_CONTAINER"
}

# Auto-load token on source
read-ghcr-token