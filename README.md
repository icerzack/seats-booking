# Seats Booking System

Приложение для бронирования переговорных комнат и рабочих мест в офисе.

## Структура проекта

- `backend/` - Spring Boot приложение для бэкенда
- `frontend/` - React приложение для фронтенда
- `terraform/` - Terraform конфигурация для развёртывания в облаке Selectel

## Локальный запуск

### Предварительные требования

- Docker и Docker Compose

### Запуск через Docker Compose

```bash
docker-compose up -d
```

Приложение будет доступно по адресу: http://localhost:80

## Развертывание в облаке Selectel с использованием Terraform

### Предварительные требования

- Terraform
- Make (для запуска команд через Makefile)

### Шаги по развертыванию

1. Скопируйте пример файла с переменными и заполните его своими данными:

```bash
cp terraform/vars.example.tfvars terraform/vars.tfvars
```

2. Отредактируйте файл `terraform/vars.tfvars`, указав свои учетные данные и параметры для Selectel.

3. Инициализируйте Terraform:

```bash
make init
```

4. Создайте план развертывания:

```bash
make plan
```

5. Примените план для создания:

```bash
make apply
```

6. После успешного развертывания можно посмотреть IP-адрес виртуальной машины:

```bash
make output
```

Приложение будет доступно по адресу: 

```
http://{vm_floating_ip}
```

### Команды Makefile

- `make init` - Инициализация модулей Terraform
- `make plan` - Создание плана изменений
- `make apply` - Применение изменений и создание инфраструктуры
- `make destroy` - Удаление всей созданной инфраструктуры
- `make output` - Вывод текущих выходных данных (включая IP-адрес VM)

## Разработка

### Backend (Spring Boot)

```bash
cd backend
./mvnw spring-boot:run
```

### Frontend (React)

```bash
cd frontend
npm install
npm start
```

## Тестирование

### Backend

```bash
cd backend
./mvnw test
```

### Frontend

```bash
cd frontend
npm test
```
