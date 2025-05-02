#!/bin/bash

echo "🔄 Cloning stable-diffusion-webui-docker repository..."
git clone https://github.com/AbdBarho/stable-diffusion-webui-docker.git
cd stable-diffusion-webui-docker

echo "✅ Repository cloned. Fetching all tags..."
git fetch --all --tags

echo "🔍 Finding latest stable tag..."
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "👉 Latest tag found: $latest_tag"

echo "🔄 Checking out latest tag..."
git checkout $latest_tag

echo "⚙️  Building and starting Docker containers (this may take a while)..."
docker compose up --build

echo "🚀 Done! Access the WebUI at http://localhost:7860"