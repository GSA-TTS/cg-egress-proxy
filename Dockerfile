# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.11-builder@sha256:401121e61853cb9c7df83cba43e532e49a68e30f32921c7bdcb7a4912168c067 AS builder

ARG GOARCH=amd64
ARG GOOS=linux
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy

FROM caddy:2.11-alpine@sha256:6aeddd44c3078b0f9a35206472a11420648a79c184603ef95957d0a20044cb2b

RUN apk add --no-cache jq curl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY export_http_proxy.sh /srv/
COPY run.sh /srv/

EXPOSE 8080

ENTRYPOINT [ "/srv/run.sh" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--watch"]
