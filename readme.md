# Doubeltap

Doubeltap is a Docker-in-Docker (DinD) container that runs a Debian Bullseye environment with Docker Compose.

## Features

- Docker-in-Docker setup


## Requirements

- Docker

## Usage


### Pulling the Docker Image

To pull the Docker image from GitHub Container Registry, use the following command:

```sh
docker pull ghcr.io/saahirlol/doubeltap:main
```

### Running the Docker Container

To run the Docker container with the necessary privileges  use the following command:

```sh
docker run --privileged --name doubeltap -v ./data:/compose --restart always ghcr.io/saahirlol/doubeltap:main
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
      - ./data:/compose
    restart: always
```

### Files

- `Dockerfile`: Defines the Docker image setup.

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Please feel free to submit issues, fork the repository, and send pull requests!

---

Feel free to customize this README further based on your specific needs and additional information you might want to include.
