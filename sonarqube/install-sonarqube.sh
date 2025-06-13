#!/bin/bash

# Скрипт для установки SonarQube на облачный сервер
# Запускать с правами sudo

set -e

echo "🚀 Установка SonarQube на сервер..."

# Обновляем систему
echo "📦 Обновление системы..."
apt-get update && apt-get upgrade -y

# Устанавливаем Docker и Docker Compose
echo "🐳 Установка Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Установка Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Настройка системных параметров для SonarQube
echo "⚙️ Настройка системных параметров..."
echo 'vm.max_map_count=524288' >> /etc/sysctl.conf
echo 'fs.file-max=131072' >> /etc/sysctl.conf
sysctl -p

echo 'sonarqube   -   nofile   131072' >> /etc/security/limits.conf
echo 'sonarqube   -   nproc    8192' >> /etc/security/limits.conf

# Создаем директорию для SonarQube
echo "📁 Создание директории для SonarQube..."
mkdir -p /opt/sonarqube
cd /opt/sonarqube

# Создаем docker-compose.yml
echo "📋 Настройка Docker Compose..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  sonarqube-db:
    image: postgres:13
    container_name: sonarqube-db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar_pass
      POSTGRES_DB: sonar
    volumes:
      - sonarqube_db:/var/lib/postgresql/data
    networks:
      - sonarqube-network
    restart: unless-stopped

  sonarqube:
    image: sonarqube:10.8.0-community
    container_name: sonarqube
    depends_on:
      - sonarqube-db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://sonarqube-db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar_pass
    ports:
      - "9000:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    networks:
      - sonarqube-network
    restart: unless-stopped
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nproc: 65536
      nofile:
        soft: 65536
        hard: 65536

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  sonarqube_db:

networks:
  sonarqube-network:
    driver: bridge
EOF

# Запускаем SonarQube
echo "🚀 Запуск SonarQube..."
docker-compose up -d

# Ожидаем запуска
echo "⏳ Ожидаем запуска SonarQube (это может занять несколько минут)..."
sleep 30

# Проверяем статус
echo "📊 Проверка статуса..."
docker-compose ps

echo "✅ SonarQube установлен и запущен!"
echo "🌐 Доступ по адресу: http://$(curl -s ifconfig.me):9000"
echo "👤 Логин: admin"
echo "🔑 Пароль: admin (смените при первом входе)"
echo ""
echo "🔧 Для остановки: docker-compose down"
echo "🔄 Для перезапуска: docker-compose restart" 