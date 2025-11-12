#!/bin/bash

# Setup External Disk for Nextcloud
# Dette script hjælper med at flytte Nextcloud data til ekstern disk

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
║   Nextcloud - Ekstern Disk Setup         ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Tjek 1: Find mounted disks
echo -e "${YELLOW}📀 Tilgængelige eksterne disks:${NC}"
echo ""
df -h | grep "/Volumes" || echo "Ingen eksterne disks fundet i /Volumes"
echo ""

# Prompt for disk navn
echo -e "${YELLOW}Hvad hedder din eksterne disk?${NC}"
echo "Eksempler: MinDisk, External, Untitled"
read -p "Disk navn: " DISK_NAME

DISK_PATH="/Volumes/$DISK_NAME"

# Tjek at disk eksisterer
if [ ! -d "$DISK_PATH" ]; then
    echo -e "${RED}❌ Disk ikke fundet: $DISK_PATH${NC}"
    echo "Tilgængelige disks:"
    ls -la /Volumes/
    exit 1
fi

echo -e "${GREEN}✅ Disk fundet: $DISK_PATH${NC}"

# Vis disk info
DISK_SIZE=$(df -h "$DISK_PATH" | tail -1 | awk '{print $2}')
DISK_USED=$(df -h "$DISK_PATH" | tail -1 | awk '{print $3}')
DISK_AVAIL=$(df -h "$DISK_PATH" | tail -1 | awk '{print $4}')

echo ""
echo -e "${BLUE}💾 Disk Information:${NC}"
echo "  Størrelse: $DISK_SIZE"
echo "  Brugt: $DISK_USED"
echo "  Tilgængelig: $DISK_AVAIL"
echo ""

# Confirmation
echo -e "${YELLOW}⚠️  Dette vil:${NC}"
echo "  1. Stop Nextcloud containeren"
echo "  2. Kopiere eksisterende data til $DISK_PATH/nextcloud/"
echo "  3. Opdatere docker-compose.yml"
echo "  4. Genstarte Nextcloud med ny sti"
echo ""
read -p "Fortsæt? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Afbrudt"
    exit 1
fi

# Step 1: Opret mapper
echo -e "\n${YELLOW}[1/5] Opretter mapper på ekstern disk...${NC}"
mkdir -p "$DISK_PATH/nextcloud/data"
mkdir -p "$DISK_PATH/nextcloud/apps"
mkdir -p "$DISK_PATH/nextcloud/config"
mkdir -p "$DISK_PATH/nextcloud/html"
echo -e "${GREEN}✅ Mapper oprettet${NC}"

# Step 2: Stop Nextcloud
echo -e "\n${YELLOW}[2/5] Stopper Nextcloud...${NC}"
cd ~/homeserver
docker-compose stop nextcloud
echo -e "${GREEN}✅ Nextcloud stoppet${NC}"

# Step 3: Backup eksisterende data
echo -e "\n${YELLOW}[3/5] Kopierer eksisterende data (dette kan tage tid)...${NC}"

# Tjek om der er eksisterende data
if docker volume ls | grep -q "homeserver_nextcloud_data"; then
    echo "  Kopierer nextcloud_data..."
    docker run --rm \
      -v homeserver_nextcloud_data:/source \
      -v "$DISK_PATH/nextcloud":/backup \
      alpine sh -c "cp -av /source/. /backup/html/" 2>/dev/null || true

    echo "  Kopierer nextcloud_data_files..."
    docker run --rm \
      -v homeserver_nextcloud_data_files:/source \
      -v "$DISK_PATH/nextcloud":/backup \
      alpine sh -c "cp -av /source/. /backup/data/" 2>/dev/null || true

    echo "  Kopierer nextcloud_config..."
    docker run --rm \
      -v homeserver_nextcloud_config:/source \
      -v "$DISK_PATH/nextcloud":/backup \
      alpine sh -c "cp -av /source/. /backup/config/" 2>/dev/null || true

    echo "  Kopierer nextcloud_apps..."
    docker run --rm \
      -v homeserver_nextcloud_apps:/source \
      -v "$DISK_PATH/nextcloud":/backup \
      alpine sh -c "cp -av /source/. /backup/apps/" 2>/dev/null || true

    echo -e "${GREEN}✅ Data kopieret${NC}"
else
    echo -e "${YELLOW}⚠️  Ingen eksisterende data fundet (første installation)${NC}"
fi

# Step 4: Fix permissions
echo -e "\n${YELLOW}[4/5] Sætter korrekte permissions...${NC}"
sudo chown -R 33:33 "$DISK_PATH/nextcloud" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Kunne ikke ændre permissions (kræver sudo)${NC}"
    echo "Kør manuelt: sudo chown -R 33:33 \"$DISK_PATH/nextcloud\""
}
echo -e "${GREEN}✅ Permissions sat${NC}"

# Step 5: Opdater docker-compose.yml
echo -e "\n${YELLOW}[5/5] Opdaterer docker-compose.yml...${NC}"

# Backup original
cp docker-compose.yml docker-compose.yml.backup

# Brug sed til at erstatte volume paths
sed -i.bak "s|nextcloud_data:/var/www/html|$DISK_PATH/nextcloud/html:/var/www/html|g" docker-compose.yml
sed -i.bak "s|nextcloud_apps:/var/www/html/custom_apps|$DISK_PATH/nextcloud/apps:/var/www/html/custom_apps|g" docker-compose.yml
sed -i.bak "s|nextcloud_config:/var/www/html/config|$DISK_PATH/nextcloud/config:/var/www/html/config|g" docker-compose.yml
sed -i.bak "s|nextcloud_data_files:/var/www/html/data|$DISK_PATH/nextcloud/data:/var/www/html/data|g" docker-compose.yml

echo -e "${GREEN}✅ docker-compose.yml opdateret${NC}"
echo -e "${YELLOW}💾 Backup gemt som: docker-compose.yml.backup${NC}"

# Start Nextcloud
echo -e "\n${YELLOW}🚀 Starter Nextcloud med ny konfiguration...${NC}"
docker-compose up -d nextcloud

# Vent på at Nextcloud starter
echo -e "\n${YELLOW}⏳ Venter på at Nextcloud starter (30 sekunder)...${NC}"
sleep 30

# Tjek status
echo -e "\n${YELLOW}📊 Status:${NC}"
docker-compose ps nextcloud

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}   ✅ Setup Færdig!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📍 Nextcloud data er nu på:${NC}"
echo "   $DISK_PATH/nextcloud/"
echo ""
echo -e "${BLUE}🌐 Test Nextcloud:${NC}"
echo "   https://cloud.kobber.me"
echo ""
echo -e "${BLUE}📊 Se plads forbrug:${NC}"
echo "   du -sh \"$DISK_PATH/nextcloud\""
echo ""
echo -e "${BLUE}🔍 Se logs:${NC}"
echo "   docker-compose logs -f nextcloud"
echo ""
echo -e "${YELLOW}💡 Vigtigt:${NC}"
echo "   Den eksterne disk SKAL være tilsluttet for at Nextcloud virker!"
echo ""
