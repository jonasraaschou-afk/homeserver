# Mac Mini Homeserver med Docker

Et komplet Docker-baseret homeserver setup til Mac mini med n8n, PostgreSQL, NocoDB, Nextcloud og Cloudflare Tunnel.

## 📋 Services

- **PostgreSQL 15** - Fælles database for alle services
- **n8n** - Workflow automation platform (port 5678)
- **NocoDB** - No-code database platform (port 8080)
- **Nextcloud** - Cloud storage og collaboration (port 8081)
- **Cloudflare Tunnel** - Sikker adgang til internettet uden port forwarding

## 🚀 Hurtig Start

### 1. Forudsætninger

Installer Docker Desktop på din Mac mini:
```bash
brew install --cask docker
```

Eller download fra: https://www.docker.com/products/docker-desktop

### 2. Klon Repository

```bash
git clone https://github.com/jonasraaschou-afk/homeserver.git
cd homeserver
```

### 3. Konfigurer Environment Variables

```bash
cp .env.example .env
nano .env  # Rediger med dine egne værdier
```

**Vigtigt:** Skift alle passwords og secrets i `.env` filen!

### 4. Opsæt Cloudflare Tunnel

#### Trin-for-trin guide:

1. **Opret Cloudflare Account**
   - Gå til https://dash.cloudflare.com
   - Opret en gratis konto hvis du ikke har en

2. **Opret et Tunnel**
   - Gå til "Zero Trust" → "Networks" → "Tunnels"
   - Klik på "Create a tunnel"
   - Vælg "Cloudflared" som connector type
   - Giv tunnelen et navn (f.eks. "homeserver-mac-mini")

3. **Få Tunnel Token**
   - Efter oprettelse får du et token
   - Kopier tokenet og indsæt det i `.env` filen:
     ```
     CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiZGlnLXRva2VuLWhlciJ9...
     ```

4. **Konfigurer Public Hostnames**
   I Cloudflare Zero Trust Dashboard:

   - **n8n**:
     - Public hostname: `n8n.ditdomæne.com`
     - Service: `http://n8n:5678`

   - **NocoDB**:
     - Public hostname: `nocodb.ditdomæne.com`
     - Service: `http://nocodb:8080`

   - **Nextcloud**:
     - Public hostname: `cloud.ditdomæne.com`
     - Service: `http://nextcloud:80`

5. **Opdater Service URLs i .env**
   ```bash
   N8N_HOST=n8n.ditdomæne.com
   N8N_PROTOCOL=https
   N8N_WEBHOOK_URL=https://n8n.ditdomæne.com/
   NOCODB_PUBLIC_URL=https://nocodb.ditdomæne.com
   NEXTCLOUD_TRUSTED_DOMAINS=cloud.ditdomæne.com
   NEXTCLOUD_PROTOCOL=https
   ```

### 5. Start Serveren

```bash
docker-compose up -d
```

### 6. Verificer Status

```bash
docker-compose ps
docker-compose logs -f
```

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

### Opsæt GitHub Actions (Anbefalet)

For automatisk deployment når du pusher til GitHub, skal du:

1. **På din Mac mini:**
   ```bash
   # Kør deployment scriptet
   ./deploy.sh
   ```

2. **Eller brug GitHub Actions** (kræver self-hosted runner):
   - Installer GitHub Actions runner på din Mac mini
   - Følg guiden: https://docs.github.com/en/actions/hosting-your-own-runners

### Manuel Deployment

På din Mac mini:
```bash
cd ~/homeserver
git pull origin main
docker-compose down
docker-compose up -d
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
