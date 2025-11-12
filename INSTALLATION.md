# Installations Guide - Mac Mini Docker Setup

Følg disse trin for at installere og starte din homeserver.

## ✅ Tjekliste Før Start

- [ ] Docker Desktop installeret på Mac mini
- [ ] Repository klonet til din Mac mini
- [ ] Du er i homeserver mappen

## 📋 Trin-for-Trin Installation

### Trin 1: Verificer Docker

```bash
# Tjek om Docker kører
docker --version
docker-compose --version
docker info
```

**Forventet output:**
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

**Hvis Docker ikke kører:**
- Åbn Docker Desktop fra Applications
- Vent til Docker ikonen viser "Docker Desktop is running"

---

### Trin 2: Opret din .env fil

```bash
# Kopier template filen
cp .env.example .env

# Rediger filen
nano .env
```

**Vigtigt - Skift disse værdier:**

```bash
# PostgreSQL Password (SKAL ændres!)
POSTGRES_PASSWORD=DitEgetSikkerPassword123!

# n8n Login
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=DitN8nPassword123!

# NocoDB JWT Secret (generer en lang random string)
NOCODB_JWT_SECRET=GenererEnLangRandomString12345678901234567890

# Nextcloud Admin
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=DitNextcloudPassword123!

# Cloudflare Tunnel Token (få fra Cloudflare Dashboard)
CLOUDFLARE_TUNNEL_TOKEN=dit-token-her
```

**Tip til at generere sikre passwords:**
```bash
# Generer random password på macOS
openssl rand -base64 32
```

**Gem filen:**
- I nano: Tryk `Ctrl + X`, derefter `Y`, derefter `Enter`

---

### Trin 3: Test Docker Compose Konfiguration

```bash
# Verificer at docker-compose.yml er valid
docker-compose config
```

Hvis der er fejl, vil du se dem her. Hvis alt er ok, ser du den komplette konfiguration.

---

### Trin 4: Download Docker Images

```bash
# Pull alle images (dette kan tage 5-10 minutter første gang)
docker-compose pull
```

Du vil se:
```
Pulling postgres    ... done
Pulling n8n         ... done
Pulling nocodb      ... done
Pulling nextcloud   ... done
Pulling cloudflared ... done
```

---

### Trin 5: Start Alle Services

```bash
# Start alle containers i baggrunden
docker-compose up -d
```

**Output:**
```
Creating homeserver-postgres    ... done
Creating homeserver-n8n         ... done
Creating homeserver-nocodb      ... done
Creating homeserver-nextcloud   ... done
Creating homeserver-cloudflared ... done
```

---

### Trin 6: Verificer at Alt Kører

```bash
# Se status på alle containers
docker-compose ps
```

**Forventet output:**
```
NAME                     STATUS              PORTS
homeserver-postgres      Up (healthy)        5432/tcp
homeserver-n8n           Up                  0.0.0.0:5678->5678/tcp
homeserver-nocodb        Up                  0.0.0.0:8080->8080/tcp
homeserver-nextcloud     Up                  0.0.0.0:8081->80/tcp
homeserver-cloudflared   Up
```

**Alle skal vise "Up"!**

---

### Trin 7: Se Logs (Vent på Services Starter)

```bash
# Se logs fra alle services
docker-compose logs -f
```

**Vent på:**
- PostgreSQL: `database system is ready to accept connections`
- n8n: `Editor is now accessible via`
- Nextcloud: `apache2 -D FOREGROUND`
- Cloudflared: `Connection established` (kun hvis token er sat)

**Stop logs:** Tryk `Ctrl + C`

---

### Trin 8: Test Adgang til Services

Åbn din browser og test hver service:

#### n8n
```
http://localhost:5678
```
- Login med: `N8N_BASIC_AUTH_USER` og `N8N_BASIC_AUTH_PASSWORD` fra .env

#### NocoDB
```
http://localhost:8080
```
- Første gang skal du oprette en admin bruger

#### Nextcloud
```
http://localhost:8081
```
- Login med: `NEXTCLOUD_ADMIN_USER` og `NEXTCLOUD_ADMIN_PASSWORD` fra .env

---

## ✅ Success! Hvad Nu?

Hvis alle services kører, er du klar til at:

### 1. Opsæt Cloudflare Tunnel (Valgfrit men anbefalet)

Se: `CLOUDFLARE_SETUP.md`

Dette giver dig adgang fra internettet med HTTPS!

### 2. Opsæt Automatisk Opdatering

```bash
# Simpel metode - checker GitHub hvert 5. minut
./setup-auto-update.sh
```

Se: `AUTOMATION_GUIDE.md` for flere muligheder

---

## 🛠 Nyttige Kommandoer

```bash
# Se status
docker-compose ps

# Se logs for alle services
docker-compose logs -f

# Se logs for én service
docker-compose logs -f n8n

# Genstart alle services
docker-compose restart

# Genstart én service
docker-compose restart n8n

# Stop alle services
docker-compose down

# Stop og slet alle data (ADVARSEL!)
docker-compose down -v

# Opdater til nyeste images
docker-compose pull && docker-compose up -d
```

---

## ❌ Troubleshooting

### Problem 1: Port Already in Use

**Fejl:**
```
Error: bind: address already in use
```

**Løsning:**
```bash
# Find hvad der bruger porten (f.eks. port 5678)
lsof -i :5678

# Stop processen eller ændr port i .env:
nano .env
# Ændr f.eks.: N8N_PORT=5679
```

### Problem 2: Database Connection Failed

**Fejl:**
```
FATAL: password authentication failed for user "postgres"
```

**Løsning:**
```bash
# Stop alt og slet database (ADVARSEL: sletter data!)
docker-compose down -v

# Start igen
docker-compose up -d
```

### Problem 3: Nextcloud "Access through untrusted domain"

**Løsning:**
```bash
# Tilføj din IP/domæne til trusted domains
nano .env

# Ændr:
NEXTCLOUD_TRUSTED_DOMAINS=localhost 192.168.1.X cloud.ditdomæne.com

# Genstart
docker-compose restart nextcloud
```

### Problem 4: Services starter ikke

**Debug:**
```bash
# Se detaljerede logs
docker-compose logs --tail=100

# Tjek specifik service
docker-compose logs n8n

# Tjek Docker Desktop for fejl
```

### Problem 5: Cloudflared viser "tunnel credentials not found"

**Løsning:**
```bash
# Tjek at token er sat i .env
grep CLOUDFLARE_TUNNEL_TOKEN .env

# Hvis ikke sat, tilføj det:
nano .env
CLOUDFLARE_TUNNEL_TOKEN=dit-token-fra-cloudflare

# Genstart cloudflared
docker-compose restart cloudflared
```

---

## 📊 Verificer Installation

Kør denne kommando for at se en samlet status:

```bash
echo "=== Docker Status ===" && \
docker-compose ps && \
echo -e "\n=== Disk Usage ===" && \
docker system df && \
echo -e "\n=== Services URLs ===" && \
echo "n8n:       http://localhost:5678" && \
echo "NocoDB:    http://localhost:8080" && \
echo "Nextcloud: http://localhost:8081"
```

---

## 🎉 Next Steps

1. ✅ **Backup Setup**: Kør `./backup.sh` for første backup
2. ✅ **Cloudflare**: Følg `CLOUDFLARE_SETUP.md` for internet adgang
3. ✅ **Auto-Update**: Kør `./setup-auto-update.sh` for automation
4. ✅ **Dokumentation**: Læs guides for hver service

---

## 💾 Første Backup

Det er en god ide at lave en backup nu:

```bash
./backup.sh
```

Backups gemmes i `./backups/` mappen.

---

## 🔐 Sikkerhed Checklist

- [ ] Alle passwords i .env er ændret fra default
- [ ] .env filen er IKKE committet til git (tjek: `.gitignore` inkluderer `.env`)
- [ ] Cloudflare Tunnel sat op (eller firewall konfigureret)
- [ ] Backup rutine etableret

---

**Tillykke! Din homeserver kører nu! 🚀**

Spørgsmål? Se README.md eller de andre guides i projektet.
