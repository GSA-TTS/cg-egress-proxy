GOOS?=linux
GOARCH?=amd64
# Build the caddy binary and copy it into the proxy subdirectory
caddy-v2-with-forwardproxy: Dockerfile proxy/Caddyfile
	docker compose build --build-arg GOOS=$(GOOS) --build-arg GOARCH=$(GOARCH)
	docker compose up -d
	- docker compose cp caddy:/usr/bin/caddy proxy/caddy
	docker compose down

validate:
	echo "test.gov" > allow.acl
	echo "test.com" > deny.acl
	PORT=9999 PROXY_USERNAME=admin PROXY_PASSWORD=pass PROXY_PORTS=443 ./proxy/caddy validate --config proxy/Caddyfile
	rm allow.acl deny.acl

build-caddy-apple-silicon: export GOOS=darwin
build-caddy-apple-silicon: export GOARCH=arm64
build-caddy-apple-silicon: caddy-v2-with-forwardproxy

validate-apple-silicon: | build-caddy-apple-silicon validate
	# rebuild binary for linux to ensure we dont accidentally commit the macOS version
	make caddy-v2-with-forwardproxy
