#!/bin/bash

# Stop the current cloudflare container
echo "Stopping cloudflare container..."
docker stop cloudflare

# Remove the container
echo "Removing cloudflare container..."
docker rm cloudflare

# Execute run.sh to restart
echo "Starting cloudflare container..."
bash run.sh

echo "Cloudflare container restarted successfully!"
