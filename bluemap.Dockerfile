FROM eclipse-temurin:21-jre

ARG JAR_FILE=bluemap-5.15-cli.jar
WORKDIR /app

COPY ./bluemap-5.15-cli.jar /app/app.jar

COPY ./data/postgresql-42.7.9.jar /init/data/postgresql-42.7.9.jar
COPY ./config /init/config
COPY ./web /init/web

COPY ./data/bluemap-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/bluemap-entrypoint.sh

EXPOSE 8100
ENTRYPOINT ["bluemap-entrypoint.sh", "java", "-jar", "/app/app.jar"]
