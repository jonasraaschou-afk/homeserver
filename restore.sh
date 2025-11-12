#!/bin/bash

# Homeserver Restore Script
# Gendanner backup af Docker volumes

set -e

if [ -z "$1" ]; then
    echo "❌ Brug: ./restore.sh <backup-fil>"
    echo "Tilgængelige backups:"
    ls -lh backups/homeserver_backup_*.tar.gz 2>/dev/null || echo "  Ingen backups fundet"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup fil ikke fundet: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  ADVARSEL: Dette vil overskrive alle eksisterende data!"
read -p "Er du sikker? (skriv 'ja' for at fortsætte): " confirm

if [ "$confirm" != "ja" ]; then
    echo "❌ Restore annulleret"
    exit 1
fi

echo "💾 Starter restore fra $BACKUP_FILE..."

# Stop containers
echo "🛑 Stopper containers..."
docker-compose down

# Restore volumes
echo "📦 Gendanner data..."
docker run --rm \
  -v homeserver_postgres_data:/data/postgres_data \
  -v homeserver_n8n_data:/data/n8n_data \
  -v homeserver_nocodb_data:/data/nocodb_data \
  -v homeserver_nextcloud_data:/data/nextcloud_data \
  -v homeserver_nextcloud_apps:/data/nextcloud_apps \
  -v homeserver_nextcloud_config:/data/nextcloud_config \
  -v homeserver_nextcloud_data_files:/data/nextcloud_data_files \
  -v "$(pwd)":/backup \
  alpine sh -c "cd / && tar xzf /backup/$BACKUP_FILE"

# Start containers
echo "▶️  Starter containers..."
docker-compose up -d

echo "✅ Restore gennemført!"
echo "💡 Tjek at alt virker med: docker-compose ps"
