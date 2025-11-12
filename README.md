# Mac Mini Homeserver med Docker

Et komplet Docker-baseret homeserver setup til Mac mini med n8n, PostgreSQL, NocoDB, Nextcloud og Cloudflare Tunnel.

## 📚 Guides

- **[INSTALLATION.md](INSTALLATION.md)** - Trin-for-trin installations guide
- **[AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)** - Automatisk deployment fra GitHub til Docker
- **[CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md)** - Detaljeret Cloudflare Tunnel opsætning

## 📋 Services

- **PostgreSQL 15** - Fælles database for alle services
- **n8n** - Workflow automation platform (port 5678)
- **NocoDB** - No-code database platform (port 8080)
- **Nextcloud** - Cloud storage og collaboration (port 8081)
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
- `postgres_data` - Database data
- `n8n_data` - n8n workflows og credentials
- `nocodb_data` - NocoDB data
- `nextcloud_data*` - Nextcloud filer og konfiguration

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

### Services starter ikke
```bash
# Check logs
docker-compose logs

# Genstart alt
docker-compose down -v
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
