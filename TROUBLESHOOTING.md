# Troubleshooting Guide

## Docmost og Strapi virker ikke

### Problem
Docmost og/eller Strapi kan ikke starte eller viser database fejl i logs.

### Årsag
`init-db.sql` bliver kun kørt når PostgreSQL containeren oprettes **første gang**. Hvis du har startet din PostgreSQL container før Docmost og Strapi blev tilføjet, eksisterer deres databaser ikke.

### Løsning

#### 1. Kør fix-databases.sh scriptet
```bash
# Gør scriptet eksekverbart
chmod +x fix-databases.sh

# Kør scriptet
./fix-databases.sh
```

Scriptet vil:
- Verificere at PostgreSQL kører
- Tjekke om alle nødvendige databaser eksisterer
- Oprette manglende databaser automatisk

#### 2. Genstart services
```bash
# Genstart Docmost
docker compose restart docmost

# Genstart Strapi
docker compose restart strapi
```

#### 3. Tjek logs
```bash
# Se logs for begge services
docker compose logs -f docmost strapi

# Kun Docmost
docker compose logs -f docmost

# Kun Strapi
docker compose logs -f strapi
```

### Manuel database oprettelse

Hvis scriptet ikke virker, kan du oprette databasene manuelt:

```bash
# Tilslut til PostgreSQL container
docker exec -it homeserver-postgres psql -U postgres

# Opret databaser
CREATE DATABASE docmost;
CREATE DATABASE strapi;

# Grant rettigheder
GRANT ALL PRIVILEGES ON DATABASE docmost TO postgres;
GRANT ALL PRIVILEGES ON DATABASE strapi TO postgres;

# Afslut
\q
```

## Docmost viser fejl om APP_URL

### Problem
Docmost klager over APP_URL eller redirect problemer.

### Løsning
Opdater `DOCMOST_APP_URL` i din `.env` fil til dit offentlige domæne:

```env
# Forkert (hvis du bruger Cloudflare Tunnel)
DOCMOST_APP_URL=http://localhost:3000

# Korrekt
DOCMOST_APP_URL=https://wiki.kobber.me
```

Genstart derefter Docmost:
```bash
docker compose restart docmost
```

## Email virker ikke

### Gmail SMTP problemer

1. **Tjek App Password**: Sørg for at du bruger et Gmail App Password (ikke dit normale password)
   - Gå til https://myaccount.google.com/security
   - Aktiver 2FA hvis ikke allerede gjort
   - Generer et App Password under "App passwords"

2. **Tjek SMTP indstillinger** i `.env`:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=din-email@gmail.com
   SMTP_PASSWORD=xxxx xxxx xxxx xxxx  # App Password (mellemrum er OK)
   SMTP_SECURE=true
   ```

3. **Genstart services**:
   ```bash
   docker compose restart docmost strapi n8n nextcloud
   ```

## Database connection fejl

### Problem
Services kan ikke forbinde til PostgreSQL.

### Tjek
```bash
# Er PostgreSQL container healthy?
docker ps | grep postgres

# Tjek PostgreSQL logs
docker compose logs postgres

# Test database forbindelse
docker exec homeserver-postgres pg_isready -U postgres
```

### Løsning
```bash
# Genstart PostgreSQL og vent på healthy status
docker compose restart postgres
sleep 10

# Genstart alle services der bruger databasen
docker compose restart n8n nocodb nextcloud docmost strapi
```

## Container starter ikke

### Tjek logs
```bash
# Se alle logs
docker compose logs

# Specifik service
docker compose logs [service-navn]

# Follow mode (real-time)
docker compose logs -f [service-navn]
```

### Genstart alt
```bash
# Stop alt
docker compose down

# Start op igen
docker compose up -d

# Tjek status
docker compose ps
```

## Cloudflare Tunnel problemer

### Tjek tunnel status
```bash
# Se tunnel logs
docker compose logs cloudflared

# Genstart tunnel
docker compose restart cloudflared
```

### Verificer Tunnel Token
Sørg for at `CLOUDFLARE_TUNNEL_TOKEN` i `.env` er korrekt og matcher din Cloudflare tunnel konfiguration.

## Port konflikter

### Problem
"Port already in use" fejl.

### Find hvad der bruger porten
```bash
# Eksempel: Tjek hvem der bruger port 3000
sudo lsof -i :3000
# eller
sudo netstat -tulpn | grep 3000
```

### Løsning
- Stop den konfliktende service, eller
- Ændr porten i `.env` filen (f.eks. `DOCMOST_PORT=3001`)
