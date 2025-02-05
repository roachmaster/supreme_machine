# llm.bashrc
# Functions for daily LLM Docker utility tasks

# Start the LLM service using docker-compose
llm-start() {
    docker-compose -f docker-compose.llm.yml up -d
}

# Stop the LLM service
llm-stop() {
    docker-compose -f docker-compose.llm.yml down
}

# Tail the logs for the LLM service
llm-logs() {
    docker-compose -f docker-compose.llm.yml logs -f
}

# Rebuild and restart the LLM service
llm-rebuild() {
    docker-compose -f docker-compose.llm.yml up -d --build
}

# Show the status of the LLM service containers
llm-status() {
    docker-compose -f docker-compose.llm.yml ps
}

# Pull the latest image for the LLM service
llm-pull() {
    docker-compose -f docker-compose.llm.yml pull
}

llm-image-run(){
    docker run -it --rm \
    --gpus all \
    -v /home/lrocha/data/ollama_data:/root/.ollama \
    -p 11434:11434 \
    my-ollama-llm \
    ollama serve --host=0.0.0.0:11434
}