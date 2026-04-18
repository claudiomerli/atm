# ATM 10 Minecraft Server Container

This project builds a Docker image containing the **All the Mods 10** server files and runs a Minecraft server based on **NeoForge**.

## What the container does

The `Dockerfile`:

- uses a two-stage build based on `eclipse-temurin:21-jre-jammy`
- downloads `ServerFiles-6.6.zip` during the builder stage
- extracts the modpack files into `/server`
- makes `startserver.sh` executable
- exposes port `25565`

At startup, the container runs `/server/startserver.sh`, which:

- installs NeoForge if the `libraries` directory does not exist yet
- creates `server.properties` with default values if the file does not exist
- starts the Minecraft server in `nogui` mode
- automatically restarts the server after it stops or crashes, unless disabled through an environment variable

## Build

```bash
docker build -t claudiomerli/atm:latest .
```

You can also override the downloaded archive name and URL at build time:

```bash
docker build \
  -t claudiomerli/atm:latest \
  --build-arg MODPACK_ZIP=ServerFiles-6.6.zip \
  --build-arg MODPACK_URL=https://mediafilez.forgecdn.net/files/7892/979/ServerFiles-6.6.zip \
  .
```

## Run

You can expose the standard Minecraft port `25565` with `-p 25565:25565`.

To keep data persistent, you should mount at least these paths:

- `/server/world`
- `/server/local`
- `/server/journeymap`
- `/server/eula.txt`

Example:

```bash
mkdir -p data/world data/local data/journeymap
printf 'eula=true\n' > data/eula.txt

docker run -d \
  --name atm10-server \
  -p 25565:25565 \
  -v "$(pwd)/data/world:/server/world" \
  -v "$(pwd)/data/local:/server/local" \
  -v "$(pwd)/data/journeymap:/server/journeymap" \
  -v "$(pwd)/data/eula.txt:/server/eula.txt" \
  claudiomerli/atm:latest
```

## Docker Compose

Example `docker-compose.yml`:

```yaml
services:
  atm10-server:
    image: claudiomerli/atm:latest
    container_name: atm10-server
    ports:
      - "25565:25565"
    volumes:
      - ./data/world:/server/world
      - ./data/local:/server/local
      - ./data/journeymap:/server/journeymap
      - ./data/eula.txt:/server/eula.txt
```

Before starting the stack:

```bash
mkdir -p data/world data/local data/journeymap
printf 'eula=true\n' > data/eula.txt
docker compose up -d
```

## Operational notes

- If you do not mount `server.properties`, the container will generate it automatically on first startup.
- If you want to customize `server.properties`, add a bind mount for `/server/server.properties` and make sure the host file exists first.
- `eula.txt` is expected from the host in the examples above; it must contain `eula=true` or Minecraft will refuse to start.
- World data and some runtime configuration are written under `/server`, so they will be lost if the container is recreated without mounts.

## Useful environment variables

The startup script supports these variables:

- `ATM10_JAVA`: path to the Java binary to use
- `ATM10_RESTART=false`: disables automatic restart
- `ATM10_INSTALL_ONLY=true`: installs NeoForge and exits without starting the server
