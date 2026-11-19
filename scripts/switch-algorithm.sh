
#!/usr/bin/env bash
set -Eeuo pipefail

# Racine du projet
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

ACTIVE="nginx/conf.d/default.conf"

# Vérification de l'argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 {round-robin|least-connections|ip-hash}"
    exit 1
fi

case "$1" in
    round-robin)
        SOURCE="nginx/round-robin.conf"
        ;;
    least-connections)
        SOURCE="nginx/least-connections.conf"
        ;;
    ip-hash)
        SOURCE="nginx/ip-hash.conf"
        ;;
    *)
        echo "Erreur : algorithme inconnu : $1"
        echo "Valeurs acceptées : round-robin, least-connections, ip-hash"
        exit 1
        ;;
esac

# Vérifier les fichiers
if [[ ! -f "$SOURCE" || ! -f "$ACTIVE" ]]; then
    echo "Erreur : configuration source ou active introuvable."
    exit 1
fi

# Sauvegarder la configuration active
BACKUP="$(mktemp)"
cp "$ACTIVE" "$BACKUP"

restore_config() {
    echo "Restauration de l'ancienne configuration..."
    cp "$BACKUP" "$ACTIVE"
    docker compose exec -T nginx nginx -t &&
        docker compose exec -T nginx nginx -s reload || true
    rm -f "$BACKUP"
}

echo "Sélection de l'algorithme : $1"

# Installer la nouvelle configuration
cp "$SOURCE" "$ACTIVE"

# Vérifier la syntaxe Nginx
if ! docker compose exec -T nginx nginx -t; then
    echo "Erreur : configuration invalide."
    restore_config
    exit 1
fi

# Recharger Nginx
if ! docker compose exec -T nginx nginx -s reload; then
    echo "Erreur : rechargement impossible."
    restore_config
    exit 1
fi

rm -f "$BACKUP"

echo "Succès : algorithme $1 activé."
