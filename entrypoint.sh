#!/bin/sh

# Start Docker daemon
dockerd &

# Wait for Docker daemon to be ready
until docker info >/dev/null 2>&1; do
    sleep 1
done

# Navigate to the directory containing the Docker Compose file
cd /compose



# Start Docker Compose
docker-compose up -d

# Keep the container running
while true; do
    sleep 3600
done
