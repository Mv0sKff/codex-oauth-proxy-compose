# Codex OAuth Proxy Compose deployment

Runs [dvcrn/codex-oauth-proxy](https://github.com/dvcrn/codex-oauth-proxy) locally. Requires Docker Compose and an existing Codex OAuth `auth.json` file.

## Build locally

```sh
cp .env.example .env
# Edit .env and set CODEX_AUTH_PATH to your existing auth.json file.
docker compose up --build
```

Configure `.env` once. Leave `ADMIN_API_KEY` empty to generate and save a key automatically, or set your own. The key is printed at startup.

## Example Compose file

Save this as `compose.yaml` to use the prebuilt image from GitHub Container Registry. Set `CODEX_AUTH_PATH` in `.env` to your existing OAuth `auth.json` file, and optionally set `ADMIN_API_KEY`.

```yaml
services:
  codex-oauth-proxy:
    image: ghcr.io/mv0skff/codex-oauth-proxy-compose:latest
    environment:
      ADMIN_API_KEY: "${ADMIN_API_KEY:-}"
    ports:
      - "127.0.0.1:9879:9879"
    volumes:
      - proxy-state:/state
      - type: bind
        source: "${CODEX_AUTH_PATH:?Set CODEX_AUTH_PATH}"
        target: /data/auth.json
        bind:
          create_host_path: false
    restart: unless-stopped

volumes:
  proxy-state:
```

**Base URL:** `http://127.0.0.1:9879/v1`. **API key:** the value printed in `docker compose logs`.

Start or update the prebuilt image:

```sh
docker compose pull
docker compose up -d
```
