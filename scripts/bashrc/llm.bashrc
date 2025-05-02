# Define the shared Docker network name
DOCKER_NETWORK="ai-network"

# Ensure the Docker network exists (create if not)
ensure-docker-network() {
    if ! docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
        echo "🔧 Creating Docker network: $DOCKER_NETWORK"
        docker network create "$DOCKER_NETWORK"
    fi
}

# Updated llm-image-run to use shared network
llm-image-run() {
    ensure-docker-network
    llm-stop
    docker run -d \
      --name "$OLLAMA_CONTAINER" \
      --network "$DOCKER_NETWORK" \
      $DOCKER_GPU_FLAG \
      -v "$OLLAMA_DATA_DIR:/root/.ollama" \
      -p "$OLLAMA_PORT:$OLLAMA_PORT" \
      "$OLLAMA_IMAGE"
}

open-webui-run() {
    ensure-docker-network
    open-webui-stop
    docker run -d \
      --name "$OPEN_WEBUI_CONTAINER" \
      --network "$DOCKER_NETWORK" \
      -e PORT="$OPEN_WEBUI_PORT" \
      -p "0.0.0.0:$OPEN_WEBUI_PORT:$OPEN_WEBUI_PORT" \
      $DOCKER_GPU_FLAG \
      --add-host=host.docker.internal:host-gateway \
      -v "$OPEN_WEBUI_DATA_DIR:/app/backend/data" \
      --restart always \
      -e OLLAMA_BASE_URL="http://ollama:$OLLAMA_PORT" \
      "$OPEN_WEBUI_IMAGE"
}

sd-run() {
    ensure-docker-network
    read-ghcr-token
    docker-ghcr-login || return 1
    sd-stop
    docker run -d \
      --name "$SD_CONTAINER" \
      --network "$DOCKER_NETWORK" \
      $DOCKER_GPU_FLAG \
      -p "$SD_PORT:$SD_PORT" \
      -v "$SD_MODELS_DIR:/models" \
      -v "$SD_OUTPUT_DIR:/output" \
      "$SD_IMAGE"
}