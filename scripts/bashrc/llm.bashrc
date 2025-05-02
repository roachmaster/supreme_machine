# llm.bashrc
# Functions for daily LLM and Stable Diffusion Docker tasks (no docker-compose)

# Load configuration values
if [ -f "${BASH_SOURCE%/*}/llm-values.bashrc" ]; then
    source "${BASH_SOURCE%/*}/llm-values.bashrc"
    echo "✅ Loaded llm-values.bashrc from ${BASH_SOURCE%/*}/llm-values.bashrc"
else
    echo "⚠️  llm-values.bashrc not found in ${BASH_SOURCE%/*}. Using defaults."
fi

# Ensure shared Docker network exists
ensure-docker-network() {
    if [ -z "$DOCKER_NETWORK" ]; then
        export DOCKER_NETWORK="llm-network"
    fi
    if ! docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
        echo "🔧 Creating Docker network: $DOCKER_NETWORK"
        docker network create "$DOCKER_NETWORK"
    fi
}

# ✅ Universal Docker run wrapper with validation
run-container() {
    local name="$1"
    local image="$2"
    local ports="$3"
    local volumes="$4"
    local envs="${5:-}"
    local extras="${6:-}"

    # Validate required args
    if [ -z "$name" ]; then echo "❌ ERROR: container name not provided"; return 1; fi
    if [ -z "$image" ]; then echo "❌ ERROR: image name not provided"; return 1; fi
    if [ -z "$ports" ]; then echo "❌ ERROR: port mapping not provided"; return 1; fi
    if [ -z "$volumes" ]; then echo "❌ ERROR: volume mapping not provided"; return 1; fi

    echo "🚀 Running container:"
    echo "   Name:   $name"
    echo "   Image:  $image"
    echo "   Ports:  $ports"
    echo "   Volumes:$volumes"
    [ -n "$envs" ] && echo "   Envs:   $envs"
    [ -n "$extras" ] && echo "   Extras: $extras"

    ensure-docker-network

    docker stop "$name" 2>/dev/null || true
    docker rm "$name" 2>/dev/null || true

    docker run -d \
      --name "$name" \
      --network "$DOCKER_NETWORK" \
      $DOCKER_GPU_FLAG \
      $ports \
      $volumes \
      $envs \
      $extras \
      "$image"
}

# Auth helpers
read-ghcr-token() {
    if [ -f "$GHCR_TOKEN_FILE" ]; then
        export GHCR_TOKEN=$(< "$GHCR_TOKEN_FILE")
        echo "✅ GHCR token loaded."
    else
        echo "❌ Token file $GHCR_TOKEN_FILE not found."
    fi
}

docker-ghcr-login() {
    if [ -z "$GHCR_TOKEN" ]; then
        echo "❌ GHCR_TOKEN not set. Run 'read-ghcr-token' first."
        return 1
    fi
    echo "$GHCR_TOKEN" | docker login ghcr.io -u $USER --password-stdin
}

# Logs & status
llm-logs() { docker logs -f "$OLLAMA_CONTAINER"; }
llm-status() { docker ps -f "name=$OLLAMA_CONTAINER"; }
open-webui-logs() { docker logs -f "$OPEN_WEBUI_CONTAINER"; }
open-webui-status() { docker ps -f "name=$OPEN_WEBUI_CONTAINER"; }
sd-logs() { docker logs -f "$SD_CONTAINER"; }
sd-status() { docker ps -f "name=$SD_CONTAINER"; }

# Image pull
llm-pull() { docker pull "$OLLAMA_IMAGE"; }
sd-pull() { read-ghcr-token; docker-ghcr-login || return 1; docker pull "$SD_IMAGE"; }

# ✅ Container runners (clean calls)
llm-image-run() {
    run-container "$OLLAMA_CONTAINER" "$OLLAMA_IMAGE" \
      "-p $OLLAMA_PORT:$OLLAMA_PORT" \
      "-v $OLLAMA_DATA_DIR:/root/.ollama"
}

open-webui-run() {
    run-container "$OPEN_WEBUI_CONTAINER" "$OPEN_WEBUI_IMAGE" \
      "-p 0.0.0.0:$OPEN_WEBUI_PORT:$OPEN_WEBUI_PORT" \
      "-v $OPEN_WEBUI_DATA_DIR:/app/backend/data" \
      "-e OLLAMA_BASE_URL=http://$OLLAMA_CONTAINER:$OLLAMA_PORT -e PORT=$OPEN_WEBUI_PORT" \
      "--add-host=host.docker.internal:host-gateway --restart always"
}

sd-run() {
    read-ghcr-token
    docker-ghcr-login || return 1
    run-container "$SD_CONTAINER" "$SD_IMAGE" \
      "-p $SD_PORT:$SD_PORT" \
      "-v $SD_MODELS_DIR:/models -v $SD_OUTPUT_DIR:/output"
}

# ✅ Build Stable Diffusion image
sd-build() {
    TMP_DIR="$SD_TMP_DIR"
    DOCKERFILE_PATH="$SD_DOCKERFILE_PATH"

    echo "🔄 Using ROOT_DIR: $ROOT_DIR"
    echo "🔄 Build directory: $TMP_DIR"
    echo "🔄 Dockerfile path: $DOCKERFILE_PATH"

    rm -rf "$TMP_DIR" || { echo "❌ Failed to clean $TMP_DIR"; return 1; }
    mkdir -p "$TMP_DIR" || { echo "❌ Failed to create $TMP_DIR"; return 1; }

    echo "📥 Cloning AUTOMATIC1111/stable-diffusion-webui into $TMP_DIR..."
    if ! git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$TMP_DIR"; then
        echo "❌ Git clone failed."
        return 1
    fi

    if [ ! -f "$DOCKERFILE_PATH" ]; then
        echo "❌ Dockerfile not found at: $DOCKERFILE_PATH"
        echo "💡 Expected path inside ROOT_DIR: $ROOT_DIR/docker/sd/Dockerfile"
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
    # Optional cleanup
    # echo "🧹 Cleaning up $TMP_DIR..."
    # rm -rf "$TMP_DIR"
}