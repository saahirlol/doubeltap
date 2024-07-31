#!/bin/sh

# Start Docker daemon
dockerd &

# Wait for Docker daemon to be ready
until docker info >/dev/null 2>&1; do
    sleep 1
done

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

# Add login server to TS_EXTRA_ARGS if provided
if [ -n "$TS_LOGIN_SERVER" ]; then
    TS_EXTRA_ARGS="$TS_EXTRA_ARGS --login-server=$TS_LOGIN_SERVER"
fi

# Start Docker Compose
docker-compose up -d

# Keep the container running
while true; do
    sleep 3600
done
