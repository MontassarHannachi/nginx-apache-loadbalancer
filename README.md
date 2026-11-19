# Docker Nginx Load Balancer

A containerized web infrastructure using **Nginx as an HTTPS reverse proxy and load balancer**, distributing traffic between two Apache backend servers.

## Architecture

```text
                    Client
                      |
                 HTTPS :8443
                      |
                Nginx Reverse Proxy
                HTTP :8088 / HTTPS
                      |
              Load Balancing Layer
                 /          \
                /            \
          Apache 1          Apache 2
          Backend 1         Backend 2
          HTTP :80          HTTP :80
```

## Features

- Nginx reverse proxy.
- HTTPS using TLS 1.2 and TLS 1.3.
- HTTP to HTTPS redirection.
- Two Apache backend servers.
- Three load balancing algorithms:
  - Round Robin
  - Least Connections
  - IP Hash
- Passive backend failure handling.
- Docker Healthchecks.
- Docker Compose orchestration.
- Automated algorithm selection script.

## Technologies

| Technology | Role |
|---|---|
| Docker | Containerization |
| Docker Compose | Service orchestration |
| Nginx | Reverse proxy and load balancing |
| Apache HTTP Server | Backend web servers |
| OpenSSL | TLS certificate generation |
| ApacheBench | Load testing |
| Bash | Algorithm selection automation |

## Project Structure

```text
nginx-apache-loadbalancer/
├── apache/
│   ├── apache1/
│   └── apache2/
├── nginx/
│   ├── conf.d/
│   ├── ssl/
│   ├── nginx.conf
│   ├── round-robin.conf
│   ├── least-connections.conf
│   └── ip-hash.conf
├── scripts/
│   └── switch-algorithm.sh
├── docs/
│   ├── healthchecks.md
│   ├── algorithm-tests.md
│   └── tests/
├── screenshots/
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Requirements

- Docker Engine
- Docker Compose plugin
- OpenSSL
- curl

## Installation

Clone the repository:

```bash
git clone https://github.com/MontassarHannachi/nginx-apache-loadbalancer.git
cd nginx-apache-loadbalancer
```

Generate a self-signed TLS certificate:

```bash
mkdir -p nginx/ssl

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=TN/ST=Tozeur/O=Lab/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

Start the infrastructure:

```bash
docker compose up -d
```

Check containers:

```bash
docker compose ps
```

## Access

| Service | URL |
|---|---|
| HTTP | http://localhost:8088 |
| HTTPS | https://localhost:8443 |
| Health endpoint | https://localhost:8443/health |

The TLS certificate is self-signed. Use `-k` with curl for local testing or install a trusted certificate for production.

## Switching Load Balancing Algorithms

Round Robin:

```bash
./scripts/switch-algorithm.sh round-robin
```

Least Connections:

```bash
./scripts/switch-algorithm.sh least-connections
```

IP Hash:

```bash
./scripts/switch-algorithm.sh ip-hash
```

## Testing

Test HTTPS:

```bash
curl -k https://localhost:8443/
```

Test HTTP redirection:

```bash
curl -I http://localhost:8088/
```

Test health endpoint:

```bash
curl -k https://localhost:8443/health
```

Load testing:

```bash
ab -k -n 1000 -c 50 https://localhost:8443/
```

## Documentation

- [Healthchecks](docs/healthchecks.md)
- [Algorithm comparison and tests](docs/algorithm-tests.md)
- [Backend failover tests](docs/tests/failover-test.md)

## Security Notes

- TLS certificate and private key are excluded from Git.
- HTTPS uses a self-signed certificate for laboratory purposes.
- Backend services are accessible through the internal Docker network.
- This project is a technical demonstration, not a production-hardened deployment.

## Author

**Montassar Hannachi**

Docker | Linux | Nginx | Networking | System Administration
