# syntax=docker/dockerfile:1.4
FROM eclipse-temurin:21-jre-jammy AS builder

ARG MODPACK_ZIP=ServerFiles-6.6.zip
ARG MODPACK_URL=https://mediafilez.forgecdn.net/files/7892/979/ServerFiles-6.6.zip

WORKDIR /server

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L "${MODPACK_URL}" -o /tmp/${MODPACK_ZIP}

RUN unzip /tmp/${MODPACK_ZIP} -d /server && rm /tmp/${MODPACK_ZIP}

RUN chmod +x /server/startserver.sh

FROM eclipse-temurin:21-jre-jammy

WORKDIR /server

COPY --from=builder /server /server

EXPOSE 25565

CMD ["./startserver.sh"]
