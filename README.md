# Nessus Docker

Docker Compose setup for running Tenable Nessus behind an Nginx reverse proxy.

## What Runs

- `nessus`: official Tenable image, pinned to `tenable/nessus:10.12.0-ubuntu`.
- `nginx`: local reverse proxy that exposes Nessus on `https://localhost:9934`.

Nessus itself only listens on the internal Docker network. The only published port is Nginx on `127.0.0.1:9934`.

## Run

```bash
docker-compose -f docker-compose.yaml up -d --build
```

Then open:

```text
https://localhost:9934
```

The Nginx container generates a local self-signed TLS certificate at startup, so your browser will show a certificate warning.

## Check Status

```bash
docker-compose -f docker-compose.yaml ps
docker-compose -f docker-compose.yaml logs -f
```

## Notes

- Tenable currently lists Nessus `10.12.0` as the current download release.
- Tenable provides official Docker images such as `tenable/nessus:<version>-ubuntu` and `latest-ubuntu`.
- The old bundled `.deb` installer and Ubuntu 16.04 build have been removed.
- Tenable's Docker documentation notes that Nessus Docker images do not support persistent storage volumes. Plan to use Nessus backup/export workflows before replacing a configured container.
- `shm_size: 1g`, healthchecks, and Docker log rotation are enabled for more predictable runtime behavior.
