# Filename: install_stable_diffusion_webui_docker.sh

#!/bin/bash

echo "🔒 Checking UFW status..."
if sudo ufw status | grep -q inactive; then
    echo "⚠️  UFW is inactive. Skipping firewall configuration."
else
    echo "🛡️  Allowing port 7860 through UFW..."
    sudo ufw allow 7860/tcp
    echo "✅ Port 7860 allowed."
fi

echo "🔄 Cloning stable-diffusion-webui-docker repository..."
if [ -d "stable-diffusion-webui-docker" ]; then
    echo "📁 Directory 'stable-diffusion-webui-docker' already exists. Skipping clone."
else
    git clone https://github.com/AbdBarho/stable-diffusion-webui-docker.git
fi
cd stable-diffusion-webui-docker

echo "✅ Repository ready. Fetching all tags..."
git fetch --all --tags

echo "🔍 Finding latest stable tag..."
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "👉 Latest tag found: $latest_tag"

echo "🔄 Checking out latest tag..."
git checkout $latest_tag

echo "⚙️  Building and starting Docker containers with 'automatic' profile (this may take a while)..."
docker compose --profile automatic up --build

echo "🚀 Done! Access the WebUI at http://localhost:7860"