# Mac Mini Homeserver med Docker

Et komplet Docker-baseret homeserver setup til Mac mini med n8n, PostgreSQL, NocoDB, Nextcloud og Cloudflare Tunnel.

## 📚 Guides

- **[INSTALLATION.md](INSTALLATION.md)** - Trin-for-trin installations guide
- **[AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)** - Automatisk deployment fra GitHub til Docker
- **[CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md)** - Detaljeret Cloudflare Tunnel opsætning

## 📋 Services

- **PostgreSQL 16** - Fælles database for alle services
- **n8n** - Workflow automation platform (port 5678)
- **NocoDB** - No-code database platform (port 8080)
- **Nextcloud** - Cloud storage og collaboration (port 8081)
- **Docmost** - Modern wiki & documentation platform (port 3000)
- **Strapi** - Headless CMS (port 1337)
- **Dashboard** - Premium landing page til alle services (port 8082)
- **Portainer** - Docker management UI (port 9000)
- **Redis** - Cache for Docmost
- **Cloudflare Tunnel** - Sikker adgang til internettet uden port forwarding

## 🚀 Hurtig Start

### Forudsætning: Installer Docker Desktop

```bash
brew install --cask docker
```

Eller download fra: https://www.docker.com/products/docker-desktop

### Metode 1: Automatisk Installation (Anbefalet) ⚡

```bash
# Klon repository
git clone https://github.com/jonasraaschou-afk/homeserver.git
cd homeserver

# Kør installations script
./install.sh
```

**Scriptet gør alt for dig:**
- ✅ Verificerer Docker
- ✅ Opretter .env fil
- ✅ Downloader images
- ✅ Starter services
- ✅ Verificerer status

### Metode 2: Manuel Installation

Se detaljeret guide: **[INSTALLATION.md](INSTALLATION.md)**

## 🌐 Efter Installation

### Opsæt Cloudflare Tunnel (Valgfrit)

For internet adgang med HTTPS, se: **[CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md)**

### Opsæt Automatisk Opdatering

```bash
./setup-auto-update.sh
```

Se også: **[AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)**

## 🔐 Standard Login Credentials

**Dashboard:**
- URL: http://localhost:8082 (eller din Cloudflare URL)
- Ingen login påkrævet - direkte adgang til alle services

**n8n:**
- URL: http://localhost:5678 (eller din Cloudflare URL)
- Bruger: Se `N8N_BASIC_AUTH_USER` i `.env`
- Password: Se `N8N_BASIC_AUTH_PASSWORD` i `.env`

**NocoDB:**
- URL: http://localhost:8080 (eller din Cloudflare URL)
- Første gang opretter du en admin bruger

**Nextcloud:**
- URL: http://localhost:8081 (eller din Cloudflare URL)
- Bruger: Se `NEXTCLOUD_ADMIN_USER` i `.env`
- Password: Se `NEXTCLOUD_ADMIN_PASSWORD` i `.env`

**Docmost:**
- URL: http://localhost:3000 (eller din Cloudflare URL)
- Første gang opretter du en admin bruger

**Strapi:**
- URL: http://localhost:1337 (eller din Cloudflare URL)
- Første gang opretter du en admin bruger

**Portainer:**
- URL: http://localhost:9000 (eller din Cloudflare URL)
- Første gang opretter du en admin bruger

## 🔄 Automatisk Deployment fra GitHub

Se den komplette guide: **[AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)**

**To måder at sætte det op:**

### Metode 1: Auto-Update Script (Simpel - Anbefalet)
```bash
./setup-auto-update.sh
```
Checker automatisk GitHub hvert 5. minut og opdaterer hvis nødvendigt.

### Metode 2: GitHub Actions (Avanceret)
Øjeblikkelig deployment ved push til GitHub. Kræver GitHub Actions runner på Mac mini.

### Manuel Deployment
```bash
cd ~/homeserver
./deploy.sh
```

## 📦 Data Persistens

Alle data gemmes i Docker volumes:
- `postgres_data` - Database data (delt mellem alle services)
- `n8n_data` - n8n workflows og credentials
- `nocodb_data` - NocoDB data
- `nextcloud_data*` - Nextcloud filer og konfiguration (4 separate volumes)
- `docmost_data` - Docmost dokumentation og uploads
- `strapi_data` - Strapi CMS indhold
- `redis_data` - Redis cache data
- `portainer_data` - Portainer konfiguration

**Note:** Dashboard bruger ingen volumes - al HTML/CSS/JS er i `./dashboard` mappen

### Backup

```bash
# Backup alle volumes
./backup.sh

# Restore
./restore.sh backup-2024-01-01.tar.gz
```

## 🛠 Nyttige Kommandoer

```bash
# Start alle services
docker-compose up -d

# Stop alle services
docker-compose down

# Se logs
docker-compose logs -f

# Se logs for en specifik service
docker-compose logs -f n8n

# Genstart en service
docker-compose restart n8n

# Se ressource forbrug
docker stats

# Opdater alle images
docker-compose pull
docker-compose up -d
```

## 🔧 Troubleshooting

### Volume Permission Fejl (Nextcloud)
Hvis du får fejl som `mkdir /host_mnt/Volumes/docker: permission denied`:

```bash
# Stop alle services
docker-compose down

# Ryd gamle volumes (ADVARSEL: sletter data!)
docker volume prune -f

# Eller slet specifikke nextcloud volumes
docker volume rm homeserver_nextcloud_data homeserver_nextcloud_apps homeserver_nextcloud_config homeserver_nextcloud_data_files

# Start igen
docker-compose up -d
```

**Alternativ løsning:**
```bash
# Verificer at Docker Desktop har adgang til korrekte mapper
# Docker Desktop > Settings > Resources > File Sharing
# Tilføj din projekt mappe hvis nødvendigt
```

### Dashboard viser gammel version
```bash
# Force refresh af dashboard container
docker-compose restart dashboard

# Eller genbyg helt fra scratch
docker-compose down dashboard
docker-compose up -d dashboard

# I browseren: Hard refresh (Cmd+Shift+R på Mac, Ctrl+Shift+R på Windows)
```

### Services starter ikke
```bash
# Check logs
docker-compose logs

# Genstart alt
docker-compose down
docker-compose up -d
```

### Database forbindelsesfejl
```bash
# Check at PostgreSQL er healthy
docker-compose ps postgres

# Reset database (ADVARSEL: sletter alle data)
docker-compose down -v
docker-compose up -d
```

### Cloudflare Tunnel virker ikke
```bash
# Check cloudflared logs
docker-compose logs cloudflared

# Verificer token i .env filen
# Verificer at public hostnames er konfigureret korrekt i Cloudflare Dashboard
```

### Ports er allerede i brug
Rediger porte i `.env` filen:
```bash
N8N_PORT=5679
NOCODB_PORT=8082
NEXTCLOUD_PORT=8083
DOCMOST_PORT=3001
STRAPI_PORT=1338
DASHBOARD_PORT=8084
PORTAINER_PORT=9001
```

## 📚 Yderligere Ressourcer

- [n8n Documentation](https://docs.n8n.io/)
- [NocoDB Documentation](https://docs.nocodb.com/)
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

## 🔒 Sikkerhed

- Brug stærke passwords i `.env` filen
- Hold `.env` filen privat (den er allerede i `.gitignore`)
- Opdater regelmæssigt Docker images: `docker-compose pull && docker-compose up -d`
- Overvej at enable two-factor authentication hvor muligt
- Brug Cloudflare Tunnel Access Policies for ekstra sikkerhed

## 📝 Licens

MIT

## 🤝 Support

Opret et issue i GitHub repository hvis du har problemer eller spørgsmål.
