#!/bin/bash

# Quick Fix Script for Nextcloud og Cloudflare Tunnel
# Dette script finder og fikser de mest almindelige problemer

set -e

echo "========================================"
echo "Nextcloud & Cloudflare Tunnel Fix Script"
echo "========================================"
echo ""

cd ~/homeserver

# 1. Tjek .env fil
echo "🔍 [1/7] Tjekker .env fil..."
if [ ! -f .env ]; then
    echo "❌ .env mangler! Kopierer fra .env.example..."
    cp .env.example .env
    echo ""
    echo "⚠️  VIGTIGT: Du skal nu udfylde .env med dine rigtige værdier!"
    echo ""
    echo "   Åbn filen: nano .env"
    echo ""
    echo "   Udfyld disse KRITISKE værdier:"
    echo "   - POSTGRES_PASSWORD"
    echo "   - NEXTCLOUD_ADMIN_PASSWORD"
    echo "   - NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost"
    echo "   - NEXTCLOUD_PROTOCOL=https"
    echo "   - CLOUDFLARE_TUNNEL_TOKEN (fra Cloudflare Dashboard)"
    echo ""
    exit 1
else
    echo "✅ .env fil findes"
fi

# 2. Tjek om CLOUDFLARE_TUNNEL_TOKEN er sat
echo ""
echo "🔍 [2/7] Tjekker Cloudflare Tunnel Token..."
TUNNEL_TOKEN=$(grep CLOUDFLARE_TUNNEL_TOKEN .env | cut -d '=' -f2)
if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "din-cloudflare-tunnel-token-her" ]; then
    echo "⚠️  ADVARSEL: CLOUDFLARE_TUNNEL_TOKEN er ikke sat!"
    echo ""
    echo "   For at Cloudflare Tunnel skal virke, skal du:"
    echo "   1. Gå til https://dash.cloudflare.com"
    echo "   2. Zero Trust → Networks → Tunnels"
    echo "   3. Create a tunnel → Kopier tokenet"
    echo "   4. Tilføj det til .env filen"
    echo ""
else
    echo "✅ Cloudflare Tunnel Token er sat"
fi

# 3. Tjek NEXTCLOUD_TRUSTED_DOMAINS
echo ""
echo "🔍 [3/7] Tjekker Nextcloud Trusted Domains..."
TRUSTED_DOMAINS=$(grep NEXTCLOUD_TRUSTED_DOMAINS .env | cut -d '=' -f2)
if [[ ! "$TRUSTED_DOMAINS" =~ "cloud.kobber.me" ]]; then
    echo "⚠️  ADVARSEL: cloud.kobber.me mangler i NEXTCLOUD_TRUSTED_DOMAINS"
    echo "   Tilføj denne linje til .env:"
    echo "   NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost"
else
    echo "✅ Nextcloud Trusted Domains ser korrekt ud"
fi

# 4. Tjek om Docker containers kører
echo ""
echo "🔍 [4/7] Tjekker Docker containers..."
if ! docker compose ps | grep -q "Up"; then
    echo "⚠️  Ingen containers kører. Starter dem nu..."
    docker compose up -d
    echo "⏳ Venter 10 sekunder på at services starter..."
    sleep 10
else
    echo "✅ Containers kører"
fi

# 5. Tjek PostgreSQL og nextcloud database
echo ""
echo "🔍 [5/7] Tjekker Nextcloud database..."
if docker exec homeserver-postgres psql -U postgres -c "\l" 2>/dev/null | grep -q "nextcloud"; then
    echo "✅ Nextcloud database eksisterer"
else
    echo "❌ Nextcloud database mangler! Opretter den..."
    docker exec homeserver-postgres psql -U postgres -c "CREATE DATABASE nextcloud;" 2>/dev/null || true
    docker exec homeserver-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE nextcloud TO postgres;" 2>/dev/null || true
    echo "✅ Database oprettet"
fi

# 6. Genstart Nextcloud og Cloudflare Tunnel
echo ""
echo "🔄 [6/7] Genstarter Nextcloud og Cloudflare Tunnel..."
docker compose restart nextcloud cloudflared
echo "⏳ Venter 5 sekunder..."
sleep 5

# 7. Vis logs og status
echo ""
echo "📊 [7/7] Statusrapport:"
echo ""

echo "--- Nextcloud Status ---"
docker compose ps nextcloud

echo ""
echo "--- Nextcloud Logs (sidste 10 linjer) ---"
docker compose logs nextcloud --tail=10

echo ""
echo "--- Cloudflare Tunnel Status ---"
docker compose ps cloudflared

echo ""
echo "--- Cloudflare Tunnel Logs (sidste 10 linjer) ---"
docker compose logs cloudflared --tail=10

echo ""
echo "========================================"
echo "✅ Script færdigt!"
echo "========================================"
echo ""
echo "📝 Næste skridt:"
echo ""
echo "1. Test lokal adgang:"
echo "   curl http://localhost:8081"
echo ""
echo "2. Hvis Cloudflare Tunnel viser 'Connection established', test:"
echo "   https://cloud.kobber.me"
echo ""
echo "3. Hvis du ser fejl i logs, læs:"
echo "   cat NEXTCLOUD_CLOUDFLARE_FIX.md"
echo ""
echo "4. For Cloudflare setup, se:"
echo "   cat CLOUDFLARE_KOBBER_ME.md"
echo ""
