# Doubeltap

Doubeltap is a Docker-in-Docker (DinD) container that runs a Debian Bullseye environment with Docker Compose. It includes a Tailscale service configured via Docker Compose, where the hostname and authentication key can be set from the host, and the login server configuration and extra arguments are optional.

## Features

- Docker-in-Docker setup
- Optional login server for Tailscale
- Optional extra arguments for Tailscale

## Requirements

- Docker

## Usage

### Environment Variables

- `TS_HOSTNAME`: The hostname for the Tailscale service (mandatory).
- `TS_AUTHKEY`: Your Tailscale authentication key (mandatory).
- `HS`: Headscale Login Server (optional).

### Pulling the Docker Image

To pull the Docker image from GitHub Container Registry, use the following command:

```sh
docker pull ghcr.io/saahirlol/doubeltap:main
```

### Running the Docker Container

To run the Docker container with the necessary privileges and environment variables, use the following command:

```sh
docker run --privileged --name doubeltap -v ./tailscale/state:/tailscale/state -v ./caddy:/caddy -e TS_HOSTNAME=${TS_HOSTNAME} -e TS_AUTHKEY=${TS_AUTHKEY} -e TS_EXTRA_ARGS=${TS_EXTRA_ARGS} --restart unless-stopped ghcr.io/saahirlol/doubeltap:main
```

If you do not want to specify extra arguments, you can omit the `TS_EXTRA_ARGS` environment variable:

```sh
docker run --privileged --name doubeltap -v ./tailscale/state:/tailscale/state -v ./caddy:/caddy -e TS_HOSTNAME=${TS_HOSTNAME} -e TS_AUTHKEY=${TS_AUTHKEY} -e --restart unless-stopped ghcr.io/saahirlol/doubeltap:main
```

### Example Docker Compose File

Here is an example `docker-compose.yml` file that you can use:

```yaml
version: '3.8'

services:
  doubeltap:
    privileged: true
    image: ghcr.io/saahirlol/doubeltap:main
    container_name: doubeltap
    volumes:
      - ./tailscale/state:/tailscale/state
      - ./caddy:/caddy
    environment:
      - TS_HOSTNAME=${TS_HOSTNAME}
      - TS_AUTHKEY=${TS_AUTHKEY}
      - TS_EXTRA_ARGS=${TS_EXTRA_ARGS} # Optional
    restart: unless-stopped
```

### Files

- `Dockerfile`: Defines the Docker image setup.
- `docker-compose.yml`: Docker Compose configuration for the Tailscale service.
- `entrypoint.sh`: Entrypoint script to start the Docker daemon and Tailscale service.

## Explanation of `entrypoint.sh`

The `entrypoint.sh` script performs the following tasks:

1. Starts the Docker daemon.
2. Waits until the Docker daemon is ready.
3. Ensures `TS_HOSTNAME` and `TS_AUTHKEY` are provided.
5. Navigates to the `/network-node` directory.
6. Runs `docker-compose up -d` to start the Tailscale service.
7. Keeps the container running indefinitely.

## Example Environment File (`tailscale.env`)

Here is an example of the environment file that can be used to provide the Tailscale configurations:

```env
TS_HOSTNAME=test
TS_AUTHKEY=your_authkey_here
TS_EXTRA_ARGS=--advertise-tags=tag:container --login-server=https://yourserver.here # Optional
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Please feel free to submit issues, fork the repository, and send pull requests!

---

Feel free to customize this README further based on your specific needs and additional information you might want to include.
