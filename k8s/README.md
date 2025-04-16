# Развертывание Seats Booking в Kubernetes

Этот каталог содержит конфигурационные файлы для развертывания приложения Seats Booking в кластере Kubernetes.

## Предварительные требования

- Установленный и настроенный Kubernetes кластер (Minikube или другой)
- kubectl
- Docker

## Структура файлов

- `namespace.yaml` - определение пространства имен
- `backend-deployment.yaml` - деплоймент и сервис для бэкенда
- `frontend-deployment.yaml` - деплоймент и сервис для фронтенда
- `backend-hpa.yaml` - настройки горизонтального автомасштабирования для бэкенда
- `ingress.yaml` - конфигурация Ingress для внешнего доступа

## Быстрое развертывание

Используйте скрипт в корне проекта для автоматического развертывания:

```bash
chmod +x deploy-to-k8s.sh
./deploy-to-k8s.sh
```

## Ручное развертывание

1. Создайте пространство имен:

```bash
kubectl apply -f namespace.yaml
```

2. Разверните бэкенд и фронтенд:

```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
```

3. Настройте горизонтальное автомасштабирование:

```bash
# Убедитесь, что metrics-server установлен
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Примените конфигурацию HPA
kubectl apply -f backend-hpa.yaml
```

4. Настройте Ingress:

```bash
kubectl apply -f ingress.yaml
```

## Тестирование автомасштабирования

1. Используйте скрипт нагрузочного тестирования:

```bash
chmod +x load-test.sh
./load-test.sh
```

2. Наблюдайте за автомасштабированием:

```bash
kubectl -n seats-booking get hpa backend-hpa -w
```

Вы должны увидеть как количество реплик увеличивается при достижении утилизации CPU выше 15%.

## Удаление ресурсов

```bash
kubectl delete namespace seats-booking
``` 