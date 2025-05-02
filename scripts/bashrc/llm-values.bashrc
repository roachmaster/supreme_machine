# llm-values.bashrc
# Configuration values for LLM, Open WebUI, and Stable Diffusion containers

###########################
# Root project directory
###########################
ROOT_DIR="/home/lrocha/repos/supreme_machine"

###########################
# General Docker options
###########################
DOCKER_GPU_FLAG="--gpus all"
DOCKER_NETWORK="llm-network"  # shared network for all containers

###########################
# Ollama container config
###########################
OLLAMA_CONTAINER="ollama"
OLLAMA_IMAGE="my-ollama-llm"
OLLAMA_PORT="11434"
OLLAMA_DATA_DIR="/home/lrocha/data/ollama_data"

###########################
# Open WebUI container config
###########################
OPEN_WEBUI_CONTAINER="open-webui"
OPEN_WEBUI_IMAGE="ghcr.io/open-webui/open-webui:ollama"
OPEN_WEBUI_PORT="3000"
OPEN_WEBUI_DATA_DIR="/home/lrocha/data/open-webui"

###########################
# Stable Diffusion container config
###########################
SD_CONTAINER="stable-diffusion"
SD_IMAGE="my-stable-diffusion-webui"  # 📝 local built image name
SD_PORT="7860"
SD_MODELS_DIR="/home/lrocha/data/stable-diffusion/models"
SD_OUTPUT_DIR="/home/lrocha/data/stable-diffusion/output"

###########################
# Stable Diffusion build paths
###########################
SD_TMP_DIR="/tmp/stable-diffusion-webui"
SD_DOCKERFILE_PATH="$ROOT_DIR/docker/sd/Dockerfile"

###########################
# GitHub Container Registry token
###########################
GHCR_TOKEN_FILE="$HOME/.ghcr_token"