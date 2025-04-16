#!/bin/bash
# Логирование для отладки
exec > >(tee -a /var/log/install-docker.log) 2>&1

echo "[$(date)] Starting Docker installation"

# Установка Docker
echo "[$(date)] Adding Docker repository GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to add Docker GPG key"
  exit 1
fi

echo "[$(date)] Adding Docker repository to APT sources"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to add Docker repository"
  exit 1
fi

echo "[$(date)] Updating apt repository"
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to update apt repositories"
  exit 1
fi

echo "[$(date)] Installing Docker packages"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to install Docker"
  exit 1
fi

echo "[$(date)] Enabling Docker service"
sudo systemctl enable docker
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to enable Docker service"
  exit 1
fi

echo "[$(date)] Starting Docker service"
sudo systemctl start docker
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to start Docker service"
  exit 1
fi

echo "[$(date)] Adding ubuntu user to docker group"
sudo usermod -aG docker ubuntu
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Failed to add ubuntu user to docker group"
  # Not exiting here as it's not critical
fi

echo "[$(date)] Docker installation completed successfully"
# Проверяем, что Docker действительно работает
sudo docker --version
sudo docker info 