#!/bin/bash
# Логирование для отладки
exec > >(tee -a /var/log/deploy-seats-booking.log) 2>&1

echo "[$(date)] Starting Seats-Booking deployment"

cd /root

# Создаем директорию для k8s манифестов
echo "[$(date)] Creating k8s manifests directory"
mkdir -p k8s

# Создаем namespace.yaml
echo "[$(date)] Creating namespace manifest"
cat > k8s/namespace.yaml << 'EOL'
apiVersion: v1
kind: Namespace
metadata:
  name: seats-booking
EOL

# Создаем backend-deployment.yaml с фиксированным NodePort и образом из реджистри
echo "[$(date)] Creating backend deployment manifest"
cat > k8s/backend-deployment.yaml << 'EOL'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: seats-booking
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/icerzack/seats-booking:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: seats-booking
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30008
  type: NodePort
EOL

# Создаем frontend-deployment.yaml с фиксированным NodePort и образом из реджистри
echo "[$(date)] Creating frontend deployment manifest"
cat > k8s/frontend-deployment.yaml << 'EOL'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: seats-booking
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: default.conf
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: seats-booking
data:
  default.conf: |
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
      }
      
      location /api {
        proxy_pass http://backend-service:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: seats-booking
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOL

# Создаем backend-hpa.yaml
echo "[$(date)] Creating HPA manifest"
cat > k8s/backend-hpa.yaml << 'EOL'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: seats-booking
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 15
EOL

# Установка metrics-server
echo "[$(date)] Installing metrics-server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Failed to install metrics-server"
  # Продолжаем, т.к. это не критическая ошибка
fi

# Патчим metrics-server, чтобы работал без TLS (для тестового окружения)
echo "[$(date)] Patching metrics-server for insecure TLS"
kubectl patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Failed to patch metrics-server"
  # Продолжаем, т.к. это не критическая ошибка
fi

# Создаем пространство имен
echo "[$(date)] Creating namespace"
kubectl apply -f k8s/namespace.yaml
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to create namespace"
  exit 1
fi

# Применяем Kubernetes манифесты
echo "[$(date)] Applying backend deployment"
kubectl apply -f k8s/backend-deployment.yaml
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to apply backend deployment"
  exit 1
fi

echo "[$(date)] Applying frontend deployment"
kubectl apply -f k8s/frontend-deployment.yaml
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to apply frontend deployment"
  exit 1
fi

echo "[$(date)] Applying HPA"
kubectl apply -f k8s/backend-hpa.yaml
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Failed to apply HPA"
  # Продолжаем, т.к. это не критическая ошибка
fi

# Ожидание запуска всех подов
echo "[$(date)] Waiting for backend deployment"
kubectl wait --for=condition=available --timeout=300s deployment/backend -n seats-booking
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Timeout waiting for backend deployment"
  # Продолжаем, т.к. хотим получить статус
fi

echo "[$(date)] Waiting for frontend deployment"
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n seats-booking
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Timeout waiting for frontend deployment"
  # Продолжаем, т.к. хотим получить статус
fi

# Получаем порты и IP
echo "[$(date)] Getting node IP"
NODE_IP=$(hostname -I | awk '{print $1}')

# Создаем файл с информацией о доступе
echo "[$(date)] Creating app-info.txt"
cat > /root/app-info.txt << EOL
========================================
Seats Booking Application URLs:
========================================
Frontend: http://$NODE_IP:30080
Backend API: http://$NODE_IP:30008

To monitor HPA and scaling:
kubectl -n seats-booking get hpa backend-hpa -w

To run load test:
ab -c 50 -n 10000 -k http://$NODE_IP:30008/api/bookings
========================================
EOL

# Выводим информацию о доступе
echo "[$(date)] Application deployed with the following endpoints:"
echo "Frontend: http://$NODE_IP:30080"
echo "Backend API: http://$NODE_IP:30008"

# Выводим статус деплоймента
echo "[$(date)] Deployment status:"
kubectl get pods -n seats-booking
kubectl get svc -n seats-booking
kubectl get hpa -n seats-booking

# Проверяем загрузку образов
echo "[$(date)] Docker images:"
docker images

# Выводим информацию
cat /root/app-info.txt
echo "[$(date)] Deployment completed!" 