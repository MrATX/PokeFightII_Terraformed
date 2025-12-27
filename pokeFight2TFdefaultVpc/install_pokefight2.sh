#!/bin/bash
# Set to exit on error
set -e

# Update apt
echo "=== Updating apt ==="
sudo apt update

# Install Git
echo "=== Installing Git ==="
sudo apt install -y git

# Clone Docker install repo and PokeFightIIDockerized repo
echo "=== Cloning Repos ==="
cd /
sudo mkdir repos
cd /repos
sudo git clone https://github.com/MrATX/MrATXDockerScripts.git
sudo git clone https://github.com/MrATX/PokeFightII_Dockerized.git

# Install Docker
echo "=== Installing Docker ==="
cd /repos/MrATXDockerScripts/
sudo chmod +x install-docker.sh ./install-docker.sh
./install-docker.sh

# Run Poke Fight II
echo "=== Running Poke Fight II ==="
cd /repos/PokeFightII_Dockerized/
sudo docker-compose up -d