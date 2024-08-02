#!/bin/sh

# Start Docker daemon
dockerd &

# Wait for Docker daemon to be ready
until docker info >/dev/null 2>&1; do
    sleep 1
done

# Start the cron service
crond

# Navigate to the directory containing the Docker Compose file
cd /network-node

# Ensure TS_HOSTNAME is provided
if [ -z "$TS_HOSTNAME" ]; then
    echo "TS_HOSTNAME is not set. Exiting."
    exit 1
fi

# Ensure TS_AUTHKEY is provided
if [ -z "$TS_AUTHKEY" ]; then
    echo "TS_AUTHKEY is not set. Exiting."
    exit 1
fi

# Start Docker Compose
docker-compose up &

# Keep the container running
while true; do
    sleep 3600
done
