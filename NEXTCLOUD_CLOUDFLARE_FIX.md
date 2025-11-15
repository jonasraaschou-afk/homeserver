# Nextcloud og Cloudflare Tunnel - Fejlfinding

## 🔍 Problemer Identificeret

Baseret på konfigurationen er der flere kritiske punkter der kan forhindre Nextcloud og Cloudflare Tunnel i at virke:

---

## Problem 1: Manglende .env Fil

### Symptom
`.env` filen eksisterer ikke i din homeserver mappe. Kun `.env.example` findes.

### Hvorfor Det Er Et Problem
- Docker Compose læser konfiguration fra `.env` filen
- Uden denne fil har services ikke deres nødvendige environment variabler
- Dette betyder ingen passwords, ingen tunnel token, ingen SMTP konfiguration

### ✅ Løsning

```bash
cd ~/homeserver

# Kopier example filen til en rigtig .env fil
cp .env.example .env

# Rediger filen med dine rigtige værdier
nano .env
```

**VIGTIGT:** Du skal udfylde følgende i `.env`:

```env
# PostgreSQL Password (KRITISK!)
POSTGRES_PASSWORD=DitEgetSikkerPassword123!

# Nextcloud Admin
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=DitSikkerNextcloudPassword123!
NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost

# Cloudflare Tunnel Token (KRITISK!)
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiMTIzNDU2Nzg5MGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6IiwidCI6IjEyMzQ1Njc4...
```

---

## Problem 2: Cloudflare Tunnel Token Mangler

### Symptom
Cloudflare Tunnel kan ikke starte uden et gyldigt tunnel token.

### Hvorfor Det Forhindrer Nextcloud
Hvis du vil tilgå Nextcloud via `cloud.kobber.me`, SKAL Cloudflare Tunnel køre for at route trafikken.

### ✅ Løsning

#### Trin 1: Opret Cloudflare Tunnel

1. Gå til https://dash.cloudflare.com
2. Vælg dit domæne `kobber.me`
3. I venstre menu: **Zero Trust** → **Networks** → **Tunnels**
4. Klik **"Create a tunnel"**
5. Vælg **"Cloudflared"**
6. Navngiv den: `homeserver`
7. Kopier det lange **Tunnel Token**

#### Trin 2: Tilføj Token til .env

```bash
nano ~/homeserver/.env
```

Find linjen:
```env
CLOUDFLARE_TUNNEL_TOKEN=din-cloudflare-tunnel-token-her
```

Erstat med dit rigtige token.

#### Trin 3: Konfigurer Public Hostnames

I Cloudflare Dashboard under din tunnel, tilføj disse public hostnames:

**Dashboard (valgfrit):**
```
Subdomain: homeserver
Domain: kobber.me
Service Type: HTTP
URL: dashboard:80
```

**Nextcloud:**
```
Subdomain: cloud
Domain: kobber.me
Service Type: HTTP
URL: nextcloud:80  ⚠️ VIGTIGT: Port 80, IKKE 8081!
```

**n8n:**
```
Subdomain: n8n
Domain: kobber.me
Service Type: HTTP
URL: n8n:5678
```

**NocoDB:**
```
Subdomain: nocodb
Domain: kobber.me
Service Type: HTTP
URL: nocodb:8080
```

**Portainer:**
```
Subdomain: portainer
Domain: kobber.me
Service Type: HTTP
URL: portainer:9000
```

**Docmost:**
```
Subdomain: wiki
Domain: kobber.me
Service Type: HTTP
URL: docmost:3000
```

---

## Problem 3: Nextcloud TRUSTED_DOMAINS Konfiguration

### Symptom
Nextcloud viser "Access through untrusted domain" når du prøver at tilgå via cloud.kobber.me.

### Hvorfor Det Sker
Nextcloud har en sikkerhedsfunktion der kun tillader adgang fra pre-godkendte domæner.

### ✅ Løsning

I din `.env` fil:

```env
NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost 127.0.0.1
```

Hvis Nextcloud allerede kører og problemet fortsætter:

```bash
# Tilslut til Nextcloud container
docker exec -it homeserver-nextcloud bash

# Rediger config.php direkte
apt update && apt install -y nano
nano /var/www/html/config/config.php
```

Find linjen med `trusted_domains` og opdater den:

```php
'trusted_domains' =>
array (
  0 => 'localhost',
  1 => 'cloud.kobber.me',
  2 => '127.0.0.1',
),
```

Gem filen (`Ctrl+X`, `Y`, `Enter`) og exit containeren (`exit`).

Genstart Nextcloud:
```bash
docker compose restart nextcloud
```

---

## Problem 4: Nextcloud OVERWRITEPROTOCOL Konfiguration

### Symptom
Nextcloud genererer HTTP links selvom du tilgår via HTTPS (gennem Cloudflare).

### Hvorfor Det Er Et Problem
- Mixed content warnings i browser
- Nextcloud apps virker ikke korrekt

### ✅ Løsning

I `.env` filen:

```env
NEXTCLOUD_PROTOCOL=https
```

Genstart Nextcloud:
```bash
docker compose restart nextcloud
```

---

## Problem 5: Database Ikke Oprettet

### Symptom
Nextcloud kan ikke starte fordi `nextcloud` databasen ikke eksisterer.

### Hvorfor Det Sker
`init-db.sql` kører kun når PostgreSQL containeren oprettes **første gang**. Hvis du har startet PostgreSQL før, er databasen ikke blevet oprettet.

### ✅ Løsning

Kør fix-databases.sh scriptet:

```bash
cd ~/homeserver
chmod +x fix-databases.sh
./fix-databases.sh
```

Eller manuelt:

```bash
# Tjek om databasen eksisterer
docker exec homeserver-postgres psql -U postgres -c "\l" | grep nextcloud

# Hvis den ikke eksisterer, opret den
docker exec homeserver-postgres psql -U postgres -c "CREATE DATABASE nextcloud;"
docker exec homeserver-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE nextcloud TO postgres;"

# Genstart Nextcloud
docker compose restart nextcloud
```

---

## Problem 6: Cloudflare Tunnel Afhængighed

### Symptom
I `docker-compose.yml` har `cloudflared` en `depends_on` dependency på `dashboard` og `postgres`, men ikke på `nextcloud`.

### Hvorfor Det Kan Være Et Problem
Hvis Cloudflare Tunnel starter før Nextcloud, kan der være timing issues.

### ✅ Løsning (Valgfri)

Dette er normalt ikke et problem da Cloudflare Tunnel kontinuerligt prøver at forbinde, men hvis du oplever issues:

```yaml
cloudflared:
  depends_on:
    dashboard:
      condition: service_started
    postgres:
      condition: service_healthy
    nextcloud:
      condition: service_started
```

---

## 🔧 Komplet Troubleshooting Checklist

### 1. Verificer .env Fil Eksisterer og Er Korrekt

```bash
cd ~/homeserver

# Tjek om .env eksisterer
ls -la .env

# Hvis ikke, kopier fra example
cp .env.example .env

# Rediger med dine værdier
nano .env
```

**Kritiske variabler der SKAL udfyldes:**
- ✅ `POSTGRES_PASSWORD`
- ✅ `NEXTCLOUD_ADMIN_PASSWORD`
- ✅ `NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost`
- ✅ `NEXTCLOUD_PROTOCOL=https`
- ✅ `CLOUDFLARE_TUNNEL_TOKEN` (dit rigtige token fra Cloudflare)

### 2. Tjek Om Databaser Eksisterer

```bash
docker exec homeserver-postgres psql -U postgres -c "\l"
```

Du skal se:
- ✅ n8n
- ✅ nocodb
- ✅ nextcloud
- ✅ docmost

Hvis nextcloud mangler:
```bash
./fix-databases.sh
```

### 3. Genstart Services Med Korrekt .env

```bash
cd ~/homeserver

# Stop alle services
docker compose down

# Start op med ny konfiguration
docker compose up -d

# Vent 30 sekunder
sleep 30

# Tjek status
docker compose ps
```

### 4. Tjek Nextcloud Logs

```bash
docker compose logs nextcloud --tail=100
```

Kig efter:
- ✅ "Starting apache2" eller "Apache started"
- ❌ Database connection errors
- ❌ "trusted_domains" fejl

### 5. Tjek Cloudflare Tunnel Logs

```bash
docker compose logs cloudflared --tail=50
```

Kig efter:
- ✅ "Connection established"
- ✅ "Registered tunnel connection"
- ❌ "tunnel credentials file not found"
- ❌ "authentication error"

### 6. Test Lokal Adgang Først

Før du tester cloud.kobber.me, verificer at Nextcloud virker lokalt:

```bash
curl http://localhost:8081
```

Du skal få HTML tilbage (ikke en fejl).

### 7. Test Cloudflare Tunnel

Når lokalt virker og Cloudflare Tunnel logger viser "Connection established":

Åbn browser og gå til:
```
https://cloud.kobber.me
```

Du skal se Nextcloud login siden.

---

## 🚨 Mest Sandsynlige Årsager (I Rækkefølge)

### 1. `.env` fil mangler eller er tom
**Sandsynlighed: 90%**

Løsning:
```bash
cp .env.example .env
nano .env  # Udfyld alle nødvendige værdier
```

### 2. Cloudflare Tunnel Token er ikke sat eller forkert
**Sandsynlighed: 85%**

Løsning: Opret tunnel i Cloudflare og kopier token til `.env`

### 3. Nextcloud database eksisterer ikke
**Sandsynlighed: 60%**

Løsning:
```bash
./fix-databases.sh
```

### 4. NEXTCLOUD_TRUSTED_DOMAINS mangler cloud.kobber.me
**Sandsynlighed: 50%**

Løsning:
```bash
nano .env
# Tilføj: NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost
docker compose restart nextcloud
```

### 5. Public hostname ikke konfigureret i Cloudflare
**Sandsynlighed: 40%**

Løsning: Tilføj "cloud" hostname i Cloudflare Dashboard → pegende på `nextcloud:80`

---

## 📝 Quick Fix Script

Her er et script der fikser de mest almindelige problemer:

```bash
#!/bin/bash

cd ~/homeserver

echo "🔍 Tjekker .env fil..."
if [ ! -f .env ]; then
    echo "❌ .env mangler! Kopierer fra .env.example..."
    cp .env.example .env
    echo "⚠️  VIGTIGT: Rediger .env med dine rigtige værdier!"
    echo "   nano .env"
    exit 1
fi

echo "🔍 Tjekker om containere kører..."
docker compose ps

echo "🔍 Tjekker nextcloud database..."
docker exec homeserver-postgres psql -U postgres -c "\l" | grep nextcloud
if [ $? -ne 0 ]; then
    echo "❌ Nextcloud database mangler! Opretter den..."
    docker exec homeserver-postgres psql -U postgres -c "CREATE DATABASE nextcloud;"
    docker exec homeserver-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE nextcloud TO postgres;"
fi

echo "🔄 Genstarter Nextcloud..."
docker compose restart nextcloud

echo "🔍 Tjekker Nextcloud logs..."
sleep 5
docker compose logs nextcloud --tail=20

echo "🔍 Tjekker Cloudflare Tunnel..."
docker compose logs cloudflared --tail=20

echo "✅ Færdig! Test nu https://cloud.kobber.me"
```

Gem dette som `fix-nextcloud-cloudflare.sh` og kør:
```bash
chmod +x fix-nextcloud-cloudflare.sh
./fix-nextcloud-cloudflare.sh
```

---

## 🎯 Næste Skridt

1. **Opret `.env` fil** fra `.env.example`
2. **Udfyld Cloudflare Tunnel Token** i `.env`
3. **Konfigurer Public Hostnames** i Cloudflare Dashboard
4. **Opdater NEXTCLOUD_TRUSTED_DOMAINS** til `cloud.kobber.me localhost`
5. **Genstart alle services**: `docker compose down && docker compose up -d`
6. **Tjek logs**: `docker compose logs cloudflared nextcloud`
7. **Test**: https://cloud.kobber.me

---

**Held og lykke! 🚀**
