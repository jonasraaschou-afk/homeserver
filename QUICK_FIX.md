# Quick Fix Guide - Løsning af aktuelle problemer

## 🚨 Problem 1: Dashboard viser ikke nyeste version

**Symptom:** Dashboard viser gammel version selvom filer er opdateret

**Løsning:**
```bash
# Genstart dashboard container
docker-compose restart dashboard

# Hvis det ikke virker, stop og start containeren
docker-compose down dashboard
docker-compose up -d dashboard
```

**I browseren:**
- Mac: `Cmd + Shift + R` (Hard refresh)
- Windows/Linux: `Ctrl + Shift + R` (Hard refresh)
- Eller åbn i inkognito/privat browsing

---

## 🚨 Problem 2: Nextcloud Volume Permission Fejl

**Symptom:**
```
Error response from daemon: error while creating mount source path '/host_mnt/Volumes/docker/nextcloud/html':
mkdir /host_mnt/Volumes/docker: permission denied
```

**Årsag:** Docker har et gammelt volume eller bind mount med forkert sti konfiguration.

**Løsning 1 - Ryd gamle volumes (Anbefalet):**
```bash
# Stop alle services
docker-compose down

# Slet ALLE gamle volumes (ADVARSEL: Dette sletter alle data!)
docker volume prune -f

# Eller slet kun nextcloud volumes specifikt:
docker volume rm homeserver_nextcloud_data
docker volume rm homeserver_nextcloud_apps
docker volume rm homeserver_nextcloud_config
docker volume rm homeserver_nextcloud_data_files

# Start services igen
docker-compose up -d
```

**Løsning 2 - Verificer Docker Desktop File Sharing:**
```bash
# Åbn Docker Desktop
# Gå til Settings > Resources > File Sharing
# Tilføj din projekt mappe (f.eks. ~/homeserver eller /Users/[dit-brugernavn]/homeserver)
# Klik Apply & Restart
```

**Løsning 3 - Hvis data skal bevares:**
```bash
# Backup eksisterende nextcloud data først
docker run --rm -v homeserver_nextcloud_data:/data -v $(pwd):/backup alpine tar czf /backup/nextcloud_backup.tar.gz -C /data .

# Derefter følg Løsning 1

# Efter services er startet, restore data:
docker run --rm -v homeserver_nextcloud_data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/nextcloud_backup.tar.gz"
```

---

## 🚨 Problem 3: Cloudflared starter ikke

**Symptom:** `homeserver-cloudflared` container starter aldrig op

**Årsag:** Cloudflared ventede på alle services inkl. Nextcloud

**Løsning:** Dette er nu rettet i `docker-compose.yml`. Cloudflared afhænger nu kun af:
- Dashboard (skal være startet)
- PostgreSQL (skal være healthy)

**Verificer fix:**
```bash
# Pull nyeste ændringer
git pull origin claude/homeserver-docker-setup-011CV4TX6UCk2kWbeh3L9FSA

# Genstart services
docker-compose down
docker-compose up -d

# Check at cloudflared nu starter
docker-compose logs cloudflared
```

---

## ✅ Verificer at alt virker

Efter du har anvendt ovenstående fixes:

```bash
# Check status på alle services
docker-compose ps

# Services der SKAL være "Up" eller "Up (healthy)":
# - homeserver-postgres (healthy)
# - homeserver-redis (healthy)
# - homeserver-n8n (up)
# - homeserver-nocodb (up)
# - homeserver-docmost (up)
# - homeserver-strapi (up)
# - homeserver-dashboard (up)
# - homeserver-portainer (up)
# - homeserver-cloudflared (up)

# Nextcloud er optional - hvis den fejler pga. volumes, følg Problem 2

# Check logs for eventuelle fejl
docker-compose logs --tail=50

# Test dashboard i browser
open http://localhost:8082  # Mac
# eller besøg http://localhost:8082 i browser
```

---

## 📝 Hvis du har .env fil problemer

Hvis du ikke har en `.env` fil:

```bash
# Kopier example filen
cp .env.example .env

# Rediger .env filen og udfyld MINDST disse værdier:
# - POSTGRES_PASSWORD
# - NOCODB_JWT_SECRET
# - N8N_BASIC_AUTH_USER
# - N8N_BASIC_AUTH_PASSWORD
# - NEXTCLOUD_ADMIN_PASSWORD
# - DOCMOST_APP_SECRET
# - STRAPI_JWT_SECRET
# - STRAPI_ADMIN_JWT_SECRET
# - STRAPI_APP_KEYS
# - STRAPI_API_TOKEN_SALT
# - STRAPI_TRANSFER_TOKEN_SALT
# - CLOUDFLARE_TUNNEL_TOKEN (valgfrit)

# Generer tilfældige secrets:
openssl rand -base64 32  # Kør flere gange for forskellige secrets
```

---

## 🆘 Hvis intet andet virker

**Nuclear option - Fuld reset:**
```bash
# ADVARSEL: Dette sletter ALT data!

# Stop og slet alt
docker-compose down -v

# Slet ALLE homeserver volumes
docker volume ls | grep homeserver | awk '{print $2}' | xargs docker volume rm

# Slet evt. gamle images
docker-compose pull

# Start frisk
docker-compose up -d

# Monitor startup
docker-compose logs -f
```

---

## 📞 Stadig problemer?

1. Check logs for specifikke fejlmeddelelser:
   ```bash
   docker-compose logs [service-navn]
   ```

2. Verificer Docker Desktop kører og er opdateret

3. Check at portene ikke er i brug:
   ```bash
   lsof -i :5678  # n8n
   lsof -i :8080  # nocodb
   lsof -i :8081  # nextcloud
   lsof -i :3000  # docmost
   lsof -i :1337  # strapi
   lsof -i :8082  # dashboard
   lsof -i :9000  # portainer
   ```

4. Opret et GitHub issue med:
   - Output fra `docker-compose ps`
   - Output fra `docker-compose logs`
   - Din macOS version
   - Din Docker Desktop version
