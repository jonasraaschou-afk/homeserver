#!/bin/bash

# Homeserver Auto-Update Script
# Dette script checker GitHub for ændringer og opdaterer automatisk

set -e

# Konfiguration
REPO_DIR="/Users/$(whoami)/homeserver"  # Juster hvis nødvendigt
BRANCH=$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)  # Brug nuværende branch
LOG_FILE="$REPO_DIR/auto-update.log"
MAX_LOG_SIZE=10485760  # 10MB

# Farver til output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Roter log hvis den er for stor
rotate_log() {
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
        log "Log fil roteret"
    fi
}

# Gå til repo directory
cd "$REPO_DIR" || {
    log "ERROR: Kunne ikke finde directory: $REPO_DIR"
    exit 1
}

rotate_log
log "Starter auto-update check..."

# Tjek om Docker kører
if ! docker info > /dev/null 2>&1; then
    log "WARNING: Docker kører ikke - springer over"
    exit 0
fi

# Fetch seneste ændringer fra GitHub
log "Fetcher fra GitHub..."
git fetch origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE"

# Tjek om der er nye commits
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/"$BRANCH")

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Ingen nye opdateringer fundet"
    exit 0
fi

log "Nye opdateringer fundet! Opdaterer..."

# Gem lokale ændringer hvis nogen (f.eks. .env fil)
if ! git diff-index --quiet HEAD --; then
    log "Gemmer lokale ændringer..."
    git stash push -m "Auto-stash før update $(date)" 2>&1 | tee -a "$LOG_FILE"
    STASHED=true
else
    STASHED=false
fi

# Pull nye ændringer
log "Puller ændringer fra GitHub..."
git pull origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE"

# Gendan lokale ændringer
if [ "$STASHED" = true ]; then
    log "Gendanner lokale ændringer..."
    git stash pop 2>&1 | tee -a "$LOG_FILE" || {
        log "WARNING: Kunne ikke auto-merge .env - tjek manuelt"
        log "Kør: git stash list && git stash show"
    }
fi

# Tjek hvilke filer der er ændret
CHANGED_FILES=$(git diff HEAD@{1} --name-only)

# Tjek om docker-compose.yml er ændret
if echo "$CHANGED_FILES" | grep -q "docker-compose.yml\|.env.example"; then
    log "Docker konfiguration ændret - opdaterer alle containers..."

    # Pull nye images
    log "Henter nye Docker images..."
    docker-compose pull 2>&1 | tee -a "$LOG_FILE"

    # Genstart services
    log "Genstarter services..."
    docker-compose down 2>&1 | tee -a "$LOG_FILE"
    docker-compose up -d 2>&1 | tee -a "$LOG_FILE"

    # Vent på at services starter
    sleep 10

    # Tjek status
    log "Service status:"
    docker-compose ps 2>&1 | tee -a "$LOG_FILE"

    log "✅ Opdatering gennemført med fuld container restart!"
elif echo "$CHANGED_FILES" | grep -q "dashboard/"; then
    log "Dashboard filer ændret - genstarter kun dashboard..."

    docker-compose restart dashboard 2>&1 | tee -a "$LOG_FILE"

    log "✅ Dashboard opdateret og genstartet!"
else
    log "Kun dokumentation ændret - ingen container restart nødvendig"
    log "✅ Opdatering gennemført!"
fi

# Send notifikation (valgfrit - kræver osascript på macOS)
if command -v osascript &> /dev/null; then
    osascript -e 'display notification "Homeserver opdateret fra GitHub" with title "Docker Homeserver"' 2>/dev/null || true
fi

log "Auto-update færdig"
