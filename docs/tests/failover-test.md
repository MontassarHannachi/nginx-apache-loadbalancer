# Tests de tolérance aux pannes (Backend Failover)

## 1. Objectif

Vérifier que le reverse proxy Nginx continue à fournir le service HTTPS lorsqu'un des deux serveurs Apache devient indisponible.

## 2. Environnement

- Nginx : Reverse Proxy et Load Balancer
- Apache 1 : Backend 1
- Apache 2 : Backend 2
- Algorithme actif : Least Connections (`least_conn`)
- Protocole : HTTPS
- Port externe : 8443

## 3. Scénario 1 : Arrêt d'Apache 1

### Procédure
1. Arrêt du conteneur Apache 1.
2. Vérification de l'état des conteneurs.
3. Envoi de 10 requêtes HTTPS vers Nginx.
4. Analyse des logs Nginx.

### Résultats
- Apache 1 : arrêté.
- Apache 2 : opérationnel.
- Requêtes envoyées : 10.
- Réponses HTTP 200 : 10.
- Backend utilisé : Apache 2.

Les logs Nginx ont signalé des erreurs de connexion vers Apache 1, puis sa désactivation temporaire.

## 4. Scénario 2 : Arrêt d'Apache 2

### Procédure
1. Redémarrage d'Apache 1.
2. Arrêt du conteneur Apache 2.
3. Envoi de 10 requêtes HTTPS vers Nginx.
4. Vérification des réponses.

### Résultats
- Apache 1 : opérationnel.
- Apache 2 : arrêté.
- Requêtes envoyées : 10.
- Réponses HTTP 200 : 10.
- Backend utilisé : Apache 1.

## 5. Rétablissement

Les deux conteneurs Apache ont été redémarrés avec succès. Les trois conteneurs sont opérationnels.

## 6. Conclusion

Les deux scénarios ont été validés. Nginx a continué à distribuer les requêtes vers le backend disponible lorsqu'un serveur Apache était arrêté.

Le mécanisme repose sur la détection passive des erreurs, les paramètres `max_fails` et `fail_timeout`, ainsi que la directive `proxy_next_upstream`.

Ces tests démontrent la tolérance à la panne d'un backend, mais ne garantissent pas la haute disponibilité de l'ensemble de l'infrastructure.
