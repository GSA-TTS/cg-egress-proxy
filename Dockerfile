# See "Adding custom Caddy modules" here:
# https://hub.docker.com/_/caddy

FROM caddy:2.11-builder@sha256:ccd8bdb5d7b25c78962bac46b7daaabfb0a354d0decf7d752e1b69caf46d9b85 AS builder

ARG GOARCH=amd64
ARG GOOS=linux
RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy

FROM caddy:2.11-alpine@sha256:78bd35025c7ba85961dd149ae670315129954e77abe2383ac47c89106b35ade9

RUN apk add --no-cache jq curl

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY export_http_proxy.sh /srv/
COPY run.sh /srv/

EXPOSE 8080

ENTRYPOINT [ "/srv/run.sh" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--watch"]
