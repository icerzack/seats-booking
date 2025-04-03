# 1. Backend
FROM maven:3.9.9-amazoncorretto-17-debian AS build-backend

WORKDIR /app/backend

COPY backend/pom.xml .

COPY backend/src ./src

RUN mvn clean package -DskipTests

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

COPY build/nginx.conf /etc/nginx/conf.d/default.conf

COPY <<EOF /docker-entrypoint.sh
#!/bin/sh
java -jar /app/app.jar &

nginx -g 'daemon off;'
EOF

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]