# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.9-builder AS builder

ARG GOARCH=amd64
ARG GOOS=linux
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy

FROM caddy:2.9-alpine

RUN apk add --no-cache jq curl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY export_http_proxy.sh /srv/
COPY run.sh /srv/

EXPOSE 8080

ENTRYPOINT [ "/srv/run.sh" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--watch"]
