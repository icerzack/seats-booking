#!/bin/bash

echo "Deploying Seats Booking app to Kubernetes"

# 1. Создаем образы Docker для фронтенда и бэкенда
echo "Building Docker images..."
docker build -t seats-booking-backend:latest ./backend
docker build -t seats-booking-frontend:latest ./frontend

# 2. Создаем пространство имен
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# 3. Проверка наличия метрик-сервера
echo "Checking if metrics-server is installed..."
kubectl get deployment metrics-server -n kube-system > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Installing metrics-server..."
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  
  # Ожидание запуска metrics-server
  echo "Waiting for metrics-server to start..."
  kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
else
  echo "Metrics-server is already installed"
fi

# 4. Применяем манифесты Kubernetes
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-hpa.yaml
kubectl apply -f k8s/ingress.yaml

# 5. Настройка сервисов как NodePort для доступа извне
echo "Configuring services as NodePort..."
kubectl patch svc backend-service -n seats-booking -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc frontend-service -n seats-booking -p '{"spec": {"type": "NodePort"}}'

# 6. Ожидание запуска всех подов
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n seats-booking
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n seats-booking

# 7. Вывод информации о доступе к приложению
echo "Deployment completed!"

FRONTEND_URL=$(kubectl -n seats-booking get svc frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
BACKEND_URL=$(kubectl -n seats-booking get svc backend-service -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "Application URLs:"
echo "Frontend: http://$NODE_IP:$FRONTEND_URL"
echo "Backend API: http://$NODE_IP:$BACKEND_URL"
echo ""
echo "To monitor HPA and scaling:"
echo "kubectl -n seats-booking get hpa backend-hpa -w"
echo ""
echo "To run load test:"
echo "chmod +x load-test.sh && ./load-test.sh" 