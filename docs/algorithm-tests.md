# Tests comparatifs des algorithmes de Load Balancing

## 1. Environnement de test

- Reverse proxy : Nginx 1.28.3
- Backends : Apache 2.4 Alpine
- Transport : HTTPS / TLS 1.3
- Outil de benchmark : ApacheBench 2.3

## 2. Round Robin

Commande :

```bash
./scripts/switch-algorithm.sh round-robin
```

Test :

```bash
for i in $(seq 1 20); do
    curl -ks https://localhost:8443/ |
    grep -o 'Apache Backend [12]'
done | sort | uniq -c
```

Résultats observés :

| Backend | Requêtes | Pourcentage |
|---|---:|---:|
| Apache 1 | 12 | 60 % |
| Apache 2 | 8 | 40 % |

Conclusion : les deux backends ont reçu des requêtes. La répartition observée est relativement équilibrée sur cet échantillon de 20 requêtes, sans être exactement égale.

## 3. IP Hash

Commande :

```bash
./scripts/switch-algorithm.sh ip-hash
```

Résultat : les 10 requêtes successives provenant du même client ont toutes atteint Apache 1.

Conclusion : le mécanisme IP Hash conserve l'affinité du client avec le même backend dans ce scénario.

## 4. Least Connections

Commande :

```bash
./scripts/switch-algorithm.sh least-connections
```

Benchmark :

```bash
ab -k -n 1000 -c 50 https://localhost:8443/
```

Résultats :

| Indicateur | Valeur |
|---|---:|
| Requêtes complétées | 1000 |
| Requêtes échouées | 0 |
| Concurrence | 50 |
| Débit | 9200,31 req/s |
| Temps moyen | 5,435 ms |
| P95 | 15 ms |

Comptage observé dans les logs :

| Backend | Requêtes comptées |
|---|---:|
| Apache 1 | 527 |
| Apache 2 | 475 |

Remarque : le comptage des logs peut inclure des requêtes extérieures au benchmark, car la date de début utilisée pour filtrer les logs a une précision à la seconde. Ces chiffres ne constituent donc pas une mesure exacte de la répartition du benchmark.

Conclusion : le test confirme que le système a traité 1000 requêtes concurrentes sans échec. Il ne permet pas de démontrer une supériorité de Least Connections sur Round Robin.

## 5. Analyse comparative

| Algorithme | Principe | Observation |
|---|---|---|
| Round Robin | Distribution successive des requêtes | Les deux backends sont sollicités |
| Least Connections | Sélection du backend ayant le moins de connexions actives | Adapté aux charges et durées de requêtes variables |
| IP Hash | Sélection basée sur l'adresse IP cliente | Affinité du client avec un backend |

## 6. Conclusion générale

Les trois algorithmes ont été configurés et activés avec succès à l'aide du script de sélection.

Les tests ont permis de vérifier leurs comportements fondamentaux et la disponibilité du service HTTPS.

Un test complémentaire avec des requêtes de durées différentes serait nécessaire pour comparer rig
