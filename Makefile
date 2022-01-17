# Build the caddy binary and copy it into the proxy subdirectory
caddy-v2-with-forwardproxy: Dockerfile proxy/Caddyfile
	docker compose build
	docker compose up -d 
	docker compose cp caddy:/usr/bin/caddy proxy/caddy
	docker compose down
