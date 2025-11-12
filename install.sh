#!/bin/bash

# Homeserver Installation Script
# Dette script guider dig gennem installationen

set -e

# Farver
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║   Mac Mini Homeserver - Installation     ║
║   n8n | NocoDB | Nextcloud | PostgreSQL  ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Tjek 1: Docker
echo -e "${YELLOW}[1/6] Tjekker Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker ikke fundet!${NC}"
    echo "Installer Docker Desktop fra: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker kører ikke!${NC}"
    echo "Start Docker Desktop og prøv igen."
    exit 1
fi

echo -e "${GREEN}✅ Docker version: $(docker --version)${NC}"
echo -e "${GREEN}✅ Docker Compose version: $(docker-compose --version)${NC}"

# Tjek 2: .env fil
echo -e "\n${YELLOW}[2/6] Tjekker .env fil...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env fil ikke fundet. Kopierer fra template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env fil oprettet${NC}"
    echo ""
    echo -e "${RED}═══════════════════════════════════════════${NC}"
    echo -e "${RED}⚠️  VIGTIGT: Du skal redigere .env filen!${NC}"
    echo -e "${RED}═══════════════════════════════════════════${NC}"
    echo ""
    echo "Skift følgende værdier i .env filen:"
    echo "  • POSTGRES_PASSWORD"
    echo "  • N8N_BASIC_AUTH_USER"
    echo "  • N8N_BASIC_AUTH_PASSWORD"
    echo "  • NOCODB_JWT_SECRET"
    echo "  • NEXTCLOUD_ADMIN_USER"
    echo "  • NEXTCLOUD_ADMIN_PASSWORD"
    echo "  • CLOUDFLARE_TUNNEL_TOKEN (valgfrit)"
    echo ""
    read -p "Vil du åbne .env filen nu? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nano .env
    else
        echo -e "${YELLOW}Husk at redigere .env før produktion!${NC}"
        echo "Kør: nano .env"
    fi
else
    echo -e "${GREEN}✅ .env fil findes${NC}"

    # Tjek om default passwords stadig bruges
    if grep -q "DitSikkerPostgresPassword123!" .env 2>/dev/null; then
        echo -e "${RED}⚠️  ADVARSEL: Du bruger stadig default passwords!${NC}"
        read -p "Vil du redigere .env nu? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            nano .env
        fi
    fi
fi

# Tjek 3: Docker Compose konfiguration
echo -e "\n${YELLOW}[3/6] Validerer Docker Compose konfiguration...${NC}"
if docker-compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ docker-compose.yml er valid${NC}"
else
    echo -e "${RED}❌ Fejl i docker-compose.yml${NC}"
    docker-compose config
    exit 1
fi

# Tjek 4: Download images
echo -e "\n${YELLOW}[4/6] Downloader Docker images...${NC}"
echo "Dette kan tage 5-10 minutter første gang..."
docker-compose pull

echo -e "${GREEN}✅ Alle images downloaded${NC}"

# Tjek 5: Start services
echo -e "\n${YELLOW}[5/6] Starter services...${NC}"
docker-compose up -d

echo -e "${GREEN}✅ Services startet${NC}"

# Vent på at services er klar
echo -e "\n${YELLOW}⏳ Venter på at services starter (30 sekunder)...${NC}"
sleep 10
echo -n "."
sleep 10
echo -n "."
sleep 10
echo -e ".\n"

# Tjek 6: Verificer status
echo -e "${YELLOW}[6/6] Verificerer status...${NC}\n"
docker-compose ps

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}   🎉 Installation Gennemført!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📊 Adgang til services:${NC}"
echo ""
echo -e "  🔹 n8n:       ${BLUE}http://localhost:5678${NC}"
echo -e "     Login: Se N8N_BASIC_AUTH_USER i .env"
echo ""
echo -e "  🔹 NocoDB:    ${BLUE}http://localhost:8080${NC}"
echo -e "     Første gang: Opret admin bruger"
echo ""
echo -e "  🔹 Nextcloud: ${BLUE}http://localhost:8081${NC}"
echo -e "     Login: Se NEXTCLOUD_ADMIN_USER i .env"
echo ""
echo -e "${YELLOW}💡 Nyttige kommandoer:${NC}"
echo "  • Se logs:          docker-compose logs -f"
echo "  • Se en service:    docker-compose logs -f n8n"
echo "  • Genstart:         docker-compose restart"
echo "  • Stop alt:         docker-compose down"
echo "  • Backup:           ./backup.sh"
echo ""
echo -e "${YELLOW}📚 Næste trin:${NC}"
echo "  1. Test adgang til alle services i browser"
echo "  2. Opsæt Cloudflare Tunnel: Se CLOUDFLARE_SETUP.md"
echo "  3. Opsæt auto-update: ./setup-auto-update.sh"
echo "  4. Lav første backup: ./backup.sh"
echo ""
echo -e "${GREEN}God fornøjelse med din homeserver! 🚀${NC}"
