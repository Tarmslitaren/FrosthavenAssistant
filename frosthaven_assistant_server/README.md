Library and simple standalone dart server for X-Haven Assistant
Container builds are automatically pushed the GitHub Container registry here:
https://github.com/Tarmslitaren/FrosthavenAssistant/pkgs/container/x-haven-server

The pull command:
```bash
docker pull ghcr.io/tarmslitaren/x-haven-server:latest
```

Running the container:
```bash
docker run -p 4567:4567 ghcr.io/tarmslitaren/x-haven-server
```

Docker docker-compose.yml example:
```yaml
version: "3.9"

services:
  x-haven-server:
    image: ghcr.io/tarmslitaren/x-haven-server:latest
    container_name: x-haven-server
    ports:
      - "4567:4567"
    restart: unless-stopped
```

Usage:
```bash
docker compose up -d
```
