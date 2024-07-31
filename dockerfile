# Use the Docker official Docker-in-Docker image
FROM docker:20.10.24-dind

# Install necessary packages for Debian Bullseye
RUN apk add --no-cache \
    bash \
    curl \
    gnupg \
    lsb-release

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Copy the Docker Compose file into the image
COPY docker-compose.yml /network-node/docker-compose.yml

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["sh"]
