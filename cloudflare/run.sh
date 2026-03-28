docker \
    run \
    -d --restart unless-stopped \
    --name cloudflare \
    --env-file .env \
    --add-host="host.docker.internal:host-gateway" \
    cloudflare/cloudflared:latest \
    tunnel \
    --no-autoupdate run