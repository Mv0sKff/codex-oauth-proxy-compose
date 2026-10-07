FROM golang:1.26-alpine AS build
ARG CODEX_PROXY_VERSION=latest
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOTELEMETRY=off
RUN go install -trimpath github.com/dvcrn/codex-oauth-proxy/cmd/codex-oauth-proxy@${CODEX_PROXY_VERSION}

FROM alpine:3.23
ENV ENV=production
RUN apk add --no-cache ca-certificates jq su-exec openssl
COPY --from=build /go/bin/codex-oauth-proxy /usr/local/bin/codex-oauth-proxy
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
EXPOSE 9879
ENTRYPOINT ["/bin/sh", "/usr/local/bin/entrypoint.sh"]
CMD ["--creds-store=xdg", "--creds-path=/data/auth.json"]
