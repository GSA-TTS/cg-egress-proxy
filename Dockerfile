# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.11-builder@sha256:369218c81ca6d6af249981221b3a5c764d886dd5b058f51d144066de13f2418d AS builder

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
