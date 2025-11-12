#!/bin/bash

# Homeserver Deployment Script
# Dette script opdaterer din homeserver fra GitHub

set -e  # Stop ved fejl

echo "🚀 Starter deployment af homeserver..."

# Farver til output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Tjek om Docker kører
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker kører ikke. Start Docker Desktop og prøv igen.${NC}"
    exit 1
fi

# Pull seneste ændringer fra GitHub
echo -e "${YELLOW}📥 Henter seneste ændringer fra GitHub...${NC}"
git pull origin main || {
    echo -e "${RED}❌ Kunne ikke hente fra GitHub. Tjek din internetforbindelse.${NC}"
    exit 1
}

# Tjek om .env fil eksisterer
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env fil ikke fundet. Kopierer fra .env.example...${NC}"
    cp .env.example .env
    echo -e "${RED}⚠️  VIGTIGT: Rediger .env filen med dine egne værdier!${NC}"
    echo -e "${RED}Kør: nano .env${NC}"
    exit 1
fi

# Pull nye Docker images
echo -e "${YELLOW}📦 Henter seneste Docker images...${NC}"
docker-compose pull

# Stop eksisterende containers
echo -e "${YELLOW}🛑 Stopper eksisterende containers...${NC}"
docker-compose down

# Start nye containers
echo -e "${YELLOW}▶️  Starter containers...${NC}"
docker-compose up -d

# Vent på at services er klar
echo -e "${YELLOW}⏳ Venter på at services starter...${NC}"
sleep 10

# Vis status
echo -e "${GREEN}✅ Deployment gennemført!${NC}"
echo ""
echo -e "${GREEN}📊 Status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}🌐 Adgang til services:${NC}"
echo -e "   n8n:       http://localhost:5678"
echo -e "   NocoDB:    http://localhost:8080"
echo -e "   Nextcloud: http://localhost:8081"
echo ""
echo -e "${YELLOW}💡 Se logs med: docker-compose logs -f${NC}"
