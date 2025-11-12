#!/bin/bash

# Homeserver Backup Script
# Laver backup af alle Docker volumes

set -e

echo "💾 Starter backup af homeserver..."

# Opret backup mappe
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

# Generer timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/homeserver_backup_$TIMESTAMP.tar.gz"

# Stop containers for konsistent backup
echo "🛑 Stopper containers..."
docker-compose down

# Backup volumes
echo "📦 Laver backup af volumes..."
docker run --rm \
  -v homeserver_postgres_data:/data/postgres_data \
  -v homeserver_n8n_data:/data/n8n_data \
  -v homeserver_nocodb_data:/data/nocodb_data \
  -v homeserver_nextcloud_data:/data/nextcloud_data \
  -v homeserver_nextcloud_apps:/data/nextcloud_apps \
  -v homeserver_nextcloud_config:/data/nextcloud_config \
  -v homeserver_nextcloud_data_files:/data/nextcloud_data_files \
  -v "$(pwd)/backups":/backup \
  alpine tar czf "/backup/homeserver_backup_$TIMESTAMP.tar.gz" /data

# Genstart containers
echo "▶️  Genstarter containers..."
docker-compose up -d

echo "✅ Backup gennemført: $BACKUP_FILE"
echo "📊 Størrelse: $(du -h "$BACKUP_FILE" | cut -f1)"

# Ryd gamle backups (behold kun de seneste 7)
echo "🧹 Rydder gamle backups..."
cd "$BACKUP_DIR"
ls -t homeserver_backup_*.tar.gz | tail -n +8 | xargs -r rm
echo "✅ Backup klar!"
