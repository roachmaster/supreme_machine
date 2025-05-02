# llm.bashrc
# ✅ Functions for LLM, Open WebUI, Stable Diffusion, and CUDA Base Docker tasks

# Load configuration values
if [ -f "${BASH_SOURCE%/*}/llm-values.bashrc" ]; then
    source "${BASH_SOURCE%/*}/llm-values.bashrc"
    echo "✅ Loaded llm-values.bashrc from ${BASH_SOURCE%/*}/llm-values.bashrc"
else
    echo "⚠️  llm-values.bashrc not found in ${BASH_SOURCE%/*}. Using defaults."
fi

# ✅ Ensure shared Docker network
ensure-docker-network() {
    if [ -z "$DOCKER_NETWORK" ]; then export DOCKER_NETWORK="llm-network"; fi
    if ! docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
        echo "🔧 Creating Docker network: $DOCKER_NETWORK"
        docker network create "$DOCKER_NETWORK"
    fi
}

# ✅ Universal Docker run wrapper
run-container() {
    local name="$1" image="$2" ports="$3" volumes="$4" envs="${5:-}" extras="${6:-}"

    [[ -z "$name" || -z "$image" || -z "$ports" || -z "$volumes" ]] && {
        echo "❌ Missing required docker run args"; return 1; }

    echo "🚀 Running container: $name → $image"
    ensure-docker-network
    docker stop "$name" 2>/dev/null || true
    docker rm "$name" 2>/dev/null || true
    docker run -d --name "$name" --network "$DOCKER_NETWORK" \
      $DOCKER_GPU_FLAG $ports $volumes $envs $extras "$image"
}

# ✅ Authentication helpers
read-ghcr-token() {
    [[ -f "$GHCR_TOKEN_FILE" ]] && { export GHCR_TOKEN=$(< "$GHCR_TOKEN_FILE"); echo "✅ GHCR token loaded."; } || echo "❌ Token file not found."
}

docker-ghcr-login() {
    [[ -z "$GHCR_TOKEN" ]] && { echo "❌ GHCR_TOKEN not set."; return 1; }
    echo "$GHCR_TOKEN" | docker login ghcr.io -u $USER --password-stdin
}

# ✅ Logs/status
llm-logs() { docker logs -f "$OLLAMA_CONTAINER"; }
llm-status() { docker ps -f "name=$OLLAMA_CONTAINER"; }
open-webui-logs() { docker logs -f "$OPEN_WEBUI_CONTAINER"; }
open-webui-status() { docker ps -f "name=$OPEN_WEBUI_CONTAINER"; }
sd-logs() { docker logs -f "$SD_CONTAINER"; }
sd-status() { docker ps -f "name=$SD_CONTAINER"; }

logs-all() {
    echo "📜 Streaming logs for all containers..."
    docker logs -f "$OLLAMA_CONTAINER" &
    docker logs -f "$OPEN_WEBUI_CONTAINER" &
    docker logs -f "$SD_CONTAINER" &
    wait
}

# ✅ Image pulls
llm-pull() { docker pull "$OLLAMA_IMAGE"; }
sd-pull() { read-ghcr-token; docker-ghcr-login || return 1; docker pull "$SD_IMAGE"; }

# ✅ Run containers
llm-image-run() {
    run-container "$OLLAMA_CONTAINER" "$OLLAMA_IMAGE" "-p $OLLAMA_PORT:$OLLAMA_PORT" "-v $OLLAMA_DATA_DIR:/root/.ollama"
}

open-webui-run() {
    run-container "$OPEN_WEBUI_CONTAINER" "$OPEN_WEBUI_IMAGE" "-p 0.0.0.0:$OPEN_WEBUI_PORT:$OPEN_WEBUI_PORT" "-v $OPEN_WEBUI_DATA_DIR:/app/backend/data" \
        "-e OLLAMA_BASE_URL=http://$OLLAMA_CONTAINER:$OLLAMA_PORT -e PORT=$OPEN_WEBUI_PORT" \
        "--add-host=host.docker.internal:host-gateway --restart always"
}

sd-run() {
    read-ghcr-token; docker-ghcr-login || return 1
    run-container "$SD_CONTAINER" "$SD_IMAGE" "-p $SD_PORT:$SD_PORT" "-v $SD_MODELS_DIR:/models -v $SD_OUTPUT_DIR:/output" \
        "-e XFORMERS_DISABLE=1"
}

# ✅ Restart all containers
restart-all() {
    echo "🔄 Restarting all containers..."
    docker stop "$SD_CONTAINER" "$OPEN_WEBUI_CONTAINER" "$OLLAMA_CONTAINER" 2>/dev/null || true
    docker rm "$SD_CONTAINER" "$OPEN_WEBUI_CONTAINER" "$OLLAMA_CONTAINER" 2>/dev/null || true

    llm-image-run
    open-webui-run
    sd-run

    echo "✅ All containers restarted and reconnected to $DOCKER_NETWORK"
}

# ✅ Stop all containers
stop-all() {
    echo "🛑 Stopping all containers..."
    docker stop "$SD_CONTAINER" "$OPEN_WEBUI_CONTAINER" "$OLLAMA_CONTAINER" 2>/dev/null || true
}

# ✅ Remove all containers
remove-all() {
    stop-all
    echo "🗑️  Removing all containers..."
    docker rm "$SD_CONTAINER" "$OPEN_WEBUI_CONTAINER" "$OLLAMA_CONTAINER" 2>/dev/null || true
}

# ✅ Exec into a container
exec-into() {
    local name="$1"
    [[ -z "$name" ]] && { echo "❌ Missing container name"; return 1; }
    echo "🖥️  Entering bash shell in container: $name"
    docker exec -it "$name" bash
}

# ✅ Clean dangling images
clean-dangling-images() {
    echo "🧹 Cleaning dangling docker images..."
    docker image prune -f
}

# ✅ Docker build + clean function
docker-build-clean() {
    local image_name="$1" context_dir="$2" dockerfile_path="$3"
    [[ -z "$image_name" || -z "$context_dir" || -z "$dockerfile_path" ]] && {
        echo "❌ docker-build-clean missing args"; return 1; }

    echo "⚙️  Building docker image: $image_name"
    docker build --rm --force-rm -t "$image_name" -f "$dockerfile_path" "$context_dir" || {
        echo "❌ Docker build failed."; return 1; }

    clean-dangling-images

    local whitelisted="${WHITELISTED_IMAGES[*]}"
    docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | while read -r entry; do
        local repo_tag=$(echo "$entry" | awk '{print $1}')
        local img_id=$(echo "$entry" | awk '{print $2}')
        if [[ ! " ${whitelisted[@]} " =~ " ${repo_tag} " ]]; then
            echo "🗑️  Removing unlisted image: $repo_tag ($img_id)"
            docker rmi "$img_id" || echo "⚠️  Failed to remove $repo_tag"
        fi
    done
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
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$TMP_DIR" || { echo "❌ Git clone failed."; return 1; }

    [[ ! -f "$DOCKERFILE_PATH" ]] && { echo "❌ Dockerfile missing at $DOCKERFILE_PATH"; return 1; }
    cp "$DOCKERFILE_PATH" "$TMP_DIR/Dockerfile" || { echo "❌ Failed to copy Dockerfile."; return 1; }

    docker-build-clean "$SD_IMAGE" "$TMP_DIR" "$TMP_DIR/Dockerfile"
}

# ✅ Build CUDA base image
cuda-base-build() {
    local base_dockerfile="$ROOT_DIR/docker/cuda/Dockerfile"
    [[ ! -f "$base_dockerfile" ]] && { echo "❌ CUDA Dockerfile missing at $base_dockerfile"; return 1; }

    echo "⚙️  Building CUDA base image: $CUDA_BASE_IMAGE"
    docker-build-clean "$CUDA_BASE_IMAGE" "$ROOT_DIR/docker/cuda" "$base_dockerfile"
}