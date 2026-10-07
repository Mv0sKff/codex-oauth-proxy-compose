# Codex OAuth Proxy Compose deployment

Runs [dvcrn/codex-oauth-proxy](https://github.com/dvcrn/codex-oauth-proxy) locally. Requires Docker Compose and an existing Codex OAuth `auth.json` file.

## Start

```sh
cp .env.example .env
# Edit .env and set CODEX_AUTH_PATH to your existing auth.json file.
docker compose up --build
```

Configure `.env` once. Leave `ADMIN_API_KEY` empty to generate and save a key automatically, or set your own. The key is printed at startup.

## Example Compose file

```yaml
services:
  codex-oauth-proxy:
    build:
      context: .
      no_cache: true
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

Rebuild to update: `docker compose up -d --build`.
