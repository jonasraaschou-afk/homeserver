#!/bin/bash

echo "🔍 Verificerer og opretter manglende databaser..."

# Tjek om postgres container kører
if ! docker ps | grep -q homeserver-postgres; then
    echo "❌ PostgreSQL container kører ikke!"
    echo "Start den først med: docker compose up -d postgres"
    exit 1
fi

# Vent på at postgres er klar
echo "⏳ Venter på at PostgreSQL er klar..."
sleep 5

# Liste over databaser der skal eksistere
databases=("n8n" "nocodb" "nextcloud" "docmost" "strapi")

# Tjek og opret hver database
for db in "${databases[@]}"; do
    echo "📋 Tjekker database: $db"

    # Tjek om database eksisterer
    exists=$(docker exec homeserver-postgres psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db'")

    if [ "$exists" = "1" ]; then
        echo "✅ Database '$db' eksisterer allerede"
    else
        echo "⚠️  Database '$db' mangler - opretter nu..."
        docker exec homeserver-postgres psql -U postgres -c "CREATE DATABASE $db;"
        docker exec homeserver-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db TO postgres;"
        echo "✅ Database '$db' oprettet"
    fi
done

echo ""
echo "🎉 Alle databaser er nu oprettet!"
echo ""
echo "Næste skridt:"
echo "1. Genstart Docmost: docker compose restart docmost"
echo "2. Genstart Strapi: docker compose restart strapi"
echo "3. Tjek logs: docker compose logs -f docmost strapi"
