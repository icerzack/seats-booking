#!/bin/bash
# Логирование для отладки
exec > >(tee -a /var/log/load-test.log) 2>&1

echo "[$(date)] Starting load test preparation"

# Получаем IP узла
echo "[$(date)] Getting node IP"
NODE_IP=$(hostname -I | awk '{print $1}')
BACKEND_PORT=30008

# Параметры нагрузочного тестирования
CONCURRENCY=50        # Количество одновременных соединений
NUM_REQUESTS=10000    # Общее количество запросов
URL="http://${NODE_IP}:${BACKEND_PORT}/api/bookings"

echo "[$(date)] Load test configuration:"
echo "Target URL: $URL"
echo "Concurrency: $CONCURRENCY"
echo "Number of requests: $NUM_REQUESTS"

# Проверяем доступность сервиса перед тестированием
echo "[$(date)] Checking if backend is accessible"
curl -s -o /dev/null -w "%{http_code}" $URL
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Backend service may not be accessible"
  # Продолжаем, возможно URL просто не отвечает на GET
fi

# Запускаем Apache Bench для нагрузочного тестирования
echo "[$(date)] Starting load test"
ab -c $CONCURRENCY -n $NUM_REQUESTS -k $URL
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Load test failed"
  exit 1
fi

echo "[$(date)] Load test completed successfully" 