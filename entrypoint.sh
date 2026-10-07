#!/bin/sh
set -eu
umask 077
if [ -z "${ADMIN_API_KEY:-}" ]; then
    mkdir -p /state
    chmod 700 /state
    if [ ! -s /state/admin_api_key ]; then
        temporary_key=$(mktemp /state/admin_api_key.XXXXXX)
        trap 'rm -f "$temporary_key"' EXIT HUP INT TERM
        openssl rand -hex 32 > "$temporary_key"
        mv "$temporary_key" /state/admin_api_key
        trap - EXIT HUP INT TERM
    fi
    chmod 600 /state/admin_api_key
    ADMIN_API_KEY=$(cat /state/admin_api_key)
fi
export ADMIN_API_KEY

# Match the mounted file owner, including rootless Docker's UID mapping.
if [ "$(id -u)" = 0 ] && [ -f /data/auth.json ]; then
    owner=$(stat -c '%u:%g' /data/auth.json)
    case "$owner" in
        0:*) ;;
        *) exec su-exec "$owner" /bin/sh /usr/local/bin/entrypoint.sh "$@" ;;
    esac
fi
if [ ! -r /data/auth.json ] || [ ! -w /data/auth.json ]; then
    printf '%s\n' 'CODEX_AUTH_PATH must point to a readable, writable auth.json file.' >&2
    exit 1
fi
if ! jq -e '
    .tokens | (type == "object") and
    (.access_token | type == "string" and length > 0) and
    (.refresh_token | type == "string" and length > 0) and
    (.account_id | type == "string" and length > 0)
' /data/auth.json >/dev/null; then
    printf '%s\n' 'Expected Codex OAuth access_token, refresh_token, and account_id in auth.json.' >&2
    exit 1
fi
printf 'Proxy URL: http://127.0.0.1:9879/v1\nADMIN_API_KEY=%s\n' "$ADMIN_API_KEY"
exec codex-oauth-proxy "$@"
