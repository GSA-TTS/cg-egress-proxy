# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.4.6-builder AS builder

RUN xcaddy build \
    --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0 \
    --with github.com/caddyserver/forwardproxy@caddy2

FROM caddy:2.4.6-alpine

RUN apk update
RUN apk add nss-tools

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
