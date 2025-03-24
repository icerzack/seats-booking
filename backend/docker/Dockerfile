FROM maven:3.9.9-amazoncorretto-17-debian AS build
WORKDIR /app
COPY ../pom.xml .
COPY ../src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/seats-booking-backend-lastest.jar app.jar
EXPOSE 10101
ENTRYPOINT ["java", "-jar", "app.jar"]