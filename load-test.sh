#!/bin/bash

# Получаем IP узла
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Получаем порт NodePort для бэкенда
NODE_PORT=$(kubectl -n seats-booking get svc backend-service -o jsonpath='{.spec.ports[0].nodePort}')

# Проверяем, указан ли порт, если нет, используем порт 8080
if [ -z "$NODE_PORT" ]; then
  echo "NodePort not found, using default backend port 8080"
  NODE_PORT=8080
fi

# Параметры нагрузочного тестирования
CONCURRENCY=50        # Количество одновременных соединений
NUM_REQUESTS=10000    # Общее количество запросов
URL="http://${NODE_IP}:${NODE_PORT}/bookings"

echo "Starting load test against $URL"
echo "Concurrency: $CONCURRENCY, Total requests: $NUM_REQUESTS"

# Запускаем Apache Bench для нагрузочного тестирования
ab -c $CONCURRENCY -n $NUM_REQUESTS -k $URL

echo "Load test completed" 