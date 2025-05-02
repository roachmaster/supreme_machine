# llm.bashrc
# Functions for daily LLM and Stable Diffusion Docker tasks (no docker-compose)

# Load configuration values
if [ -f "${BASH_SOURCE%/*}/llm-values.bashrc" ]; then
    source "${BASH_SOURCE%/*}/llm-values.bashrc"
    echo "✅ Loaded llm-values.bashrc from ${BASH_SOURCE%/*}/llm-values.bashrc"
else
    echo "⚠️  llm-values.bashrc not found in ${BASH_SOURCE%/*}. Using defaults."
fi

read-ghcr-token() { if [ -f "$GHCR_TOKEN_FILE" ]; then export GHCR_TOKEN=$(< "$GHCR_TOKEN_FILE"); echo "✅ GHCR token loaded."; else echo "❌ Token file $GHCR_TOKEN_FILE not found."; fi; }
docker-ghcr-login() { if [ -z "$GHCR_TOKEN" ]; then echo "❌ GHCR_TOKEN not set. Run 'read-ghcr-token' first."; return 1; fi; echo "$GHCR_TOKEN" | docker login ghcr.io -u $USER --password-stdin; }

llm-stop() { docker stop "$OLLAMA_CONTAINER" 2>/dev/null || true; docker rm "$OLLAMA_CONTAINER" 2>/dev/null || true; }
llm-logs() { docker logs -f "$OLLAMA_CONTAINER"; }
llm-rebuild() { docker build -t "$OLLAMA_IMAGE" .; }
llm-status() { docker ps -f "name=$OLLAMA_CONTAINER"; }
llm-pull() { docker pull "$OLLAMA_IMAGE"; }
llm-image-run() { llm-stop; docker run -d --name "$OLLAMA_CONTAINER" $DOCKER_GPU_FLAG -v "$OLLAMA_DATA_DIR:/root/.ollama" -p "$OLLAMA_PORT:$OLLAMA_PORT" "$OLLAMA_IMAGE"; }

open-webui-stop() { docker stop "$OPEN_WEBUI_CONTAINER" 2>/dev/null || true; docker rm "$OPEN_WEBUI_CONTAINER" 2>/dev/null || true; }
open-webui-run() {
    open-webui-stop
    docker run -d -e PORT="$OPEN_WEBUI_PORT" -p "0.0.0.0:$OPEN_WEBUI_PORT:$OPEN_WEBUI_PORT" $DOCKER_GPU_FLAG \
      --add-host=host.docker.internal:host-gateway \
      -v "$OPEN_WEBUI_DATA_DIR:/app/backend/data" \
      --name "$OPEN_WEBUI_CONTAINER" --restart always \
      -e OLLAMA_BASE_URL="http://127.0.0.1:$OLLAMA_PORT" "$OPEN_WEBUI_IMAGE"
}

sd-stop() { docker stop "$SD_CONTAINER" 2>/dev/null || true; docker rm "$SD_CONTAINER" 2>/dev/null || true; }
sd-logs() { docker logs -f "$SD_CONTAINER"; }
sd-pull() { read-ghcr-token; docker-ghcr-login || return 1; docker pull "$SD_IMAGE"; }
sd-run() {
    read-ghcr-token
    docker-ghcr-login || return 1
    sd-stop
    docker run -d $DOCKER_GPU_FLAG --name "$SD_CONTAINER" -p "$SD_PORT:$SD_PORT" \
      -v "$SD_MODELS_DIR:/models" -v "$SD_OUTPUT_DIR:/output" "$SD_IMAGE"
}
sd-status() { docker ps -f "name=$SD_CONTAINER"; }

# 🆕 FOOLPROOF AUTOMATED BUILD FUNCTION
sd-build() {
    TMP_DIR="/tmp/stable-diffusion-webui"
    SCRIPT_DIR="$(realpath "${BASH_SOURCE%/*}")"
    DOCKERFILE_PATH="$SCRIPT_DIR/../docker/sd/Dockerfile"

    echo "🔄 Ensuring temporary build directory $TMP_DIR..."
    rm -rf "$TMP_DIR" || { echo "❌ Failed to clean $TMP_DIR"; return 1; }
    mkdir -p "$TMP_DIR" || { echo "❌ Failed to create $TMP_DIR"; return 1; }

    echo "📥 Cloning AUTOMATIC1111/stable-diffusion-webui into $TMP_DIR..."
    if ! git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$TMP_DIR"; then
        echo "❌ Git clone failed."
        return 1
    fi

    if [ ! -f "$DOCKERFILE_PATH" ]; then
        echo "❌ Dockerfile not found at expected path: $DOCKERFILE_PATH"
        echo "Please ensure docker/sd/Dockerfile exists."
        return 1
    fi

    echo "📄 Copying Dockerfile from $DOCKERFILE_PATH to $TMP_DIR..."
    cp "$DOCKERFILE_PATH" "$TMP_DIR/Dockerfile" || { echo "❌ Failed to copy Dockerfile."; return 1; }

    echo "⚙️  Building Docker image: $SD_IMAGE..."
    cd "$TMP_DIR" || { echo "❌ Failed to cd into $TMP_DIR"; return 1; }
    if ! docker build -t "$SD_IMAGE" .; then
        echo "❌ Docker build failed."
        cd - > /dev/null
        return 1
    fi

    echo "✅ Docker build complete: $SD_IMAGE"
    cd - > /dev/null
    # Optional clean-up toggle (uncomment to auto-clean):
    # echo "🧹 Cleaning up $TMP_DIR..."
    # rm -rf "$TMP_DIR"
}