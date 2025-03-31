# 1. Backend
FROM maven:3.8.6-openjdk-17-slim AS build-backend

WORKDIR /app/backend
COPY backend/pom.xml .

RUN mvn dependency:go-offline -B
COPY backend/src ./src

RUN mvn package -DskipTests

# 2. Frontend
FROM node:16-alpine AS build-frontend

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install

COPY frontend ./
RUN npm run build

# 3. Final image with nginx
FROM nginx:1.23-alpine

RUN apk add --no-cache openjdk17-jre

COPY --from=build-backend /app/backend/target/*.jar /app/app.jar

COPY --from=build-frontend /app/frontend/build /usr/share/nginx/html

COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

COPY <<EOF /docker-entrypoint.sh
#!/bin/sh
java -jar /app/app.jar &

nginx -g 'daemon off;'
EOF

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]