# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.8-builder AS builder

ARG GOARCH=amd64
ARG GOOS=linux
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy@caddy2

FROM caddy:2.8-alpine

RUN apk add --no-cache jq curl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY .profile /srv/.profile
COPY --chmod=0755 docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/docker-entrypoint.sh" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
