# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.11-builder@sha256:403d237d0bb16d2e62b1f93ca9ebb4953ecbb78aee5986765713a39f9263a5b4 AS builder

ARG GOARCH=amd64
ARG GOOS=linux
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy

FROM caddy:2.11-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648

RUN apk add --no-cache jq curl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY export_http_proxy.sh /srv/
COPY run.sh /srv/

EXPOSE 8080

ENTRYPOINT [ "/srv/run.sh" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--watch"]
