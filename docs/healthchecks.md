# Docker Healthchecks

## Objectif

Surveiller automatiquement l'état de santé des trois services de l'architecture.

## Configuration

| Service | Contrôle | Intervalle | Timeout | Retries |
|---|---|---:|---:|---:|
| Apache 1 | HTTP localhost:80 | 10 s | 3 s | 3 |
| Apache 2 | HTTP localhost:80 | 10 s | 3 s | 3 |
| Nginx | HTTPS localhost:443/health | 10 s | 3 s | 3 |

## Résultats

Les trois conteneurs ont affiché l'état `healthy`.

Les contrôles Apache vérifient que chaque serveur HTTP répond localement.

Le contrôle Nginx vérifie que le reverse proxy HTTPS répond sur son endpoint `/health`.

## Conclusion

Les Healthchecks permettent de distinguer un conteneur simplement démarré d'un service qui répond correctement à son contrôle de santé.
