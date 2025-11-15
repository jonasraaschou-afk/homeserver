# Komplet Installationsguide - Homeserver i Docker

En komplet guide til at installere din homeserver med Docker helt fra bunden.

## 📋 Indholdsfortegnelse

1. [Forudsætninger](#forudsætninger)
2. [Trin 1: Installer Docker Desktop](#trin-1-installer-docker-desktop)
3. [Trin 2: Klon Repository](#trin-2-klon-repository)
4. [Trin 3: Opsæt .env Fil](#trin-3-opsæt-env-fil)
5. [Trin 4: Start Homeserveren](#trin-4-start-homeserveren)
6. [Trin 5: Verificer Installation](#trin-5-verificer-installation)
7. [Trin 6: Tilgå Dine Services](#trin-6-tilgå-dine-services)
8. [Næste Trin](#næste-trin)
9. [Troubleshooting](#troubleshooting)

---

## Forudsætninger

### Hvad du skal bruge:

- **Mac mini** (eller anden Mac/Linux/Windows computer)
- **Mindst 8GB RAM** (16GB anbefalet)
- **Mindst 20GB ledig diskplads**
- **Internet forbindelse**
- **Terminal adgang** (macOS Terminal, Linux Terminal, eller Windows PowerShell)

### Hvad du får installeret:

- **PostgreSQL 16** - Database til alle services
- **n8n** - Workflow automation (som Zapier/Make.com)
- **NocoDB** - No-code database (som Airtable)
- **Nextcloud** - Cloud storage (som Dropbox/Google Drive)
- **Docmost** - Wiki & dokumentation
- **Dashboard** - Landing page til alle services
- **Portainer** - Docker management UI
- **Cloudflare Tunnel** - Sikker internet adgang (valgfrit)

---

## Trin 1: Installer Docker Desktop

Docker er platformen der kører alle dine services. Det er den eneste forudsætning du skal installere manuelt.

### På macOS:

#### Metode 1: Via Homebrew (Anbefalet)

```bash
# Installer Homebrew hvis du ikke har det
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Docker Desktop
brew install --cask docker
```

#### Metode 2: Manuel download

1. Gå til https://www.docker.com/products/docker-desktop
2. Download Docker Desktop til Mac
3. Åbn den downloadede .dmg fil
4. Træk Docker til Applications mappen
5. Åbn Docker fra Applications

### På Windows:

1. Download Docker Desktop fra https://www.docker.com/products/docker-desktop
2. Kør installationsfilen
3. Følg installations-guiden
4. Genstart computeren hvis påkrævet

### På Linux (Ubuntu/Debian):

```bash
# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Tilføj din bruger til docker gruppen
sudo usermod -aG docker $USER

# Log ud og ind igen
```

### Verificer Docker Installation

```bash
# Åbn Terminal og kør:
docker --version
docker-compose --version

# Du skal se noget lignende:
# Docker version 24.0.x
# Docker Compose version v2.x.x
```

### Start Docker Desktop

**Vigtigt:** Docker Desktop skal køre før du går videre!

- På macOS/Windows: Åbn Docker Desktop fra Applications
- Vent til status viser "Docker Desktop is running"
- Du ser et grønt ikon i menubaren/system tray

---

## Trin 2: Klon Repository

Nu skal du hente homeserver projektet til din computer.

### Hvis du har Git installeret:

```bash
# Åbn Terminal og kør:
cd ~
git clone https://github.com/jonasraaschou-afk/homeserver.git
cd homeserver
```

### Hvis du IKKE har Git:

1. Gå til https://github.com/jonasraaschou-afk/homeserver
2. Klik på den grønne "Code" knap
3. Vælg "Download ZIP"
4. Pak ZIP filen ud i din hjemmemappe
5. Åbn Terminal og naviger til mappen:

```bash
cd ~/homeserver
```

### Verificer at du er i den rigtige mappe:

```bash
# Kør:
ls -la

# Du skal se disse filer:
# docker-compose.yml
# .env.example
# install.sh
# README.md
# osv.
```

---

## Trin 3: Opsæt .env Fil

.env filen indeholder alle dine konfigurationer og passwords. Dette er det vigtigste trin!

### Trin 3.1: Kopier Template Filen

```bash
# Kopier example filen til .env
cp .env.example .env
```

### Trin 3.2: Åbn .env Filen

```bash
# Rediger filen med nano (eller din favorit editor)
nano .env
```

### Trin 3.3: Skift Vigtige Værdier

**⚠️ VIGTIGT: Du SKAL ændre disse værdier før du går i produktion!**

Gennemgå filen og opdater følgende:

#### 1. PostgreSQL Database Password

Find denne linje og skift til dit eget sikre password:

```bash
POSTGRES_PASSWORD=DitSikkerPostgresPassword123!
```

**Tip:** Generer et sikkert password:
```bash
# På macOS/Linux:
openssl rand -base64 32
```

#### 2. n8n Login Credentials

```bash
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=DitSikkerN8nPassword123!
```

#### 3. NocoDB JWT Secret

```bash
NOCODB_JWT_SECRET=GenererEnLangRandomString123456789
```

Skift til en lang random string (mindst 32 tegn):
```bash
# Generer med:
openssl rand -base64 48
```

#### 4. Nextcloud Admin Login

```bash
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=DitSikkerNextcloudPassword123!
```

#### 5. Docmost App Secret

```bash
DOCMOST_APP_SECRET=GenererEnLangRandomString64CharactersMinimum123456789ABCDEFGHIJK
```

Skift til en lang random string (mindst 64 tegn):
```bash
# Generer med:
openssl rand -base64 64
```

#### 6. SMTP Email Indstillinger (Valgfrit - kan sættes op senere)

Hvis du vil have email notifikationer, skal du konfigurere SMTP:

**For Gmail:**

```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=din-email@gmail.com
SMTP_PASSWORD=xxxx-xxxx-xxxx-xxxx  # Gmail App Password
SMTP_SECURE=true
```

**Sådan får du Gmail App Password:**
1. Gå til https://myaccount.google.com/security
2. Aktiver 2-Factor Authentication
3. Klik på "App passwords"
4. Generer et nyt password til "Mail"
5. Brug det 16-tegns password i SMTP_PASSWORD

**Andre SMTP udbydere:**
- **SendGrid**: smtp.sendgrid.net (port 587)
- **Mailgun**: smtp.mailgun.org (port 587)
- **AWS SES**: email-smtp.REGION.amazonaws.com (port 587)

#### 7. Cloudflare Tunnel (Valgfrit - kan sættes op senere)

Spring over nu, hvis du kun vil have lokal adgang. Se [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) senere.

```bash
CLOUDFLARE_TUNNEL_TOKEN=din-cloudflare-tunnel-token-her
```

### Trin 3.4: Gem .env Filen

I nano:
- Tryk `Ctrl + X`
- Tryk `Y` for at bekræfte
- Tryk `Enter`

### Trin 3.5: Verificer .env Filen

```bash
# Tjek at filen er oprettet:
ls -la .env

# Se at dine ændringer er gemt (uden at vise passwords):
grep "POSTGRES_USER" .env
```

**⚠️ SIKKERHED:**
- Del ALDRIG din .env fil med andre
- Commit ALDRIG .env til git
- Lav en backup af .env på et sikkert sted

---

## Trin 4: Start Homeserveren

Nu er vi klar til at starte alle services!

### Metode 1: Automatisk Installation (Nemmest - Anbefalet)

Brug det medfølgende installations-script:

```bash
# Gør scriptet executable (hvis det ikke allerede er det)
chmod +x install.sh

# Kør installations-scriptet
./install.sh
```

**Scriptet vil:**
1. ✅ Tjekke at Docker kører
2. ✅ Verificere din .env fil
3. ✅ Downloade alle Docker images (5-10 minutter)
4. ✅ Starte alle services
5. ✅ Vise status og næste trin

**Følg bare instruktionerne på skærmen!**

### Metode 2: Manuel Installation (Mere kontrol)

Hvis du foretrækker at gøre det manuelt trin for trin:

#### Step 4.1: Verificer Docker Compose Konfiguration

```bash
docker-compose config
```

Hvis der er fejl, vil du se dem nu. Hvis alt er ok, ser du hele konfigurationen udskrevet.

#### Step 4.2: Download Docker Images

```bash
# Download alle Docker images (første gang tager 5-10 minutter)
docker-compose pull
```

Du vil se progress bars for hver service:
```
Pulling postgres    ... done
Pulling n8n         ... done
Pulling nocodb      ... done
Pulling nextcloud   ... done
Pulling docmost     ... done
Pulling dashboard   ... done
Pulling portainer   ... done
Pulling redis       ... done
Pulling cloudflared ... done
```

#### Step 4.3: Start Alle Services

```bash
# Start alle containers i baggrunden
docker-compose up -d
```

**Output:**
```
Creating network "homeserver_homeserver-network" ... done
Creating volume "homeserver_postgres_data" ... done
Creating volume "homeserver_n8n_data" ... done
...
Creating homeserver-postgres    ... done
Creating homeserver-redis       ... done
Creating homeserver-n8n         ... done
Creating homeserver-nocodb      ... done
Creating homeserver-nextcloud   ... done
Creating homeserver-docmost     ... done
Creating homeserver-dashboard   ... done
Creating homeserver-portainer   ... done
Creating homeserver-cloudflared ... done
```

#### Step 4.4: Vent på at Services Starter

```bash
# Vent 30 sekunder
echo "Venter på at services starter..."
sleep 30
```

---

## Trin 5: Verificer Installation

Nu skal vi tjekke at alt kører som det skal.

### Tjek Container Status

```bash
docker-compose ps
```

**Forventet output:**

```
NAME                      STATUS              PORTS
homeserver-postgres       Up (healthy)        5432/tcp
homeserver-redis          Up (healthy)        6379/tcp
homeserver-n8n            Up                  0.0.0.0:5678->5678/tcp
homeserver-nocodb         Up                  0.0.0.0:8080->8080/tcp
homeserver-nextcloud      Up                  0.0.0.0:8081->80/tcp
homeserver-docmost        Up                  0.0.0.0:3000->3000/tcp
homeserver-dashboard      Up                  0.0.0.0:8082->80/tcp
homeserver-portainer      Up                  0.0.0.0:9000->9000/tcp
homeserver-cloudflared    Up
```

**✅ Alle skal vise "Up"!**

Hvis nogle viser "Exit" eller "Restarting", se [Troubleshooting](#troubleshooting) sektionen.

### Se Logs

```bash
# Se logs fra alle services
docker-compose logs -f

# Eller se logs fra en specifik service
docker-compose logs -f n8n
```

**Vent på disse beskeder:**

- **PostgreSQL**: `database system is ready to accept connections`
- **n8n**: `Editor is now accessible via`
- **Nextcloud**: `apache2 -D FOREGROUND`
- **NocoDB**: `App started successfully`
- **Docmost**: `Server started`

**Stop logs:** Tryk `Ctrl + C`

### Tjek Docker Resource Forbrug

```bash
# Se CPU og RAM forbrug
docker stats --no-stream
```

**Typisk forbrug:**
- Total RAM: 2-4 GB
- PostgreSQL: ~50-100 MB
- Nextcloud: ~150-300 MB
- n8n: ~100-200 MB
- Andre: ~50-100 MB hver

---

## Trin 6: Tilgå Dine Services

Nu kan du åbne dine services i browseren! 🎉

### Dashboard (Landing Page)

**URL:** http://localhost:8082

- Premium landing page med links til alle services
- Ingen login påkrævet
- Start her for nem adgang til alt!

### n8n (Workflow Automation)

**URL:** http://localhost:5678

**Login:**
- Brugernavn: Se `N8N_BASIC_AUTH_USER` i din .env fil
- Password: Se `N8N_BASIC_AUTH_PASSWORD` i din .env fil

**Første gang:**
- Login med Basic Auth credentials
- Du kommer direkte til workflow editoren
- Klar til at oprette automatiseringer!

### NocoDB (No-Code Database)

**URL:** http://localhost:8080

**Første gang:**
- Klik "Sign Up"
- Opret en admin bruger:
  - Email: din@email.com
  - Password: DitSikkerPassword123!
- Login med dine nye credentials

**Efterfølgende:**
- Login med den email og password du oprettede

### Nextcloud (Cloud Storage)

**URL:** http://localhost:8081

**Login:**
- Brugernavn: Se `NEXTCLOUD_ADMIN_USER` i din .env fil
- Password: Se `NEXTCLOUD_ADMIN_PASSWORD` i din .env fil

**Første gang:**
- Installation tager ~30-60 sekunder
- Vent tålmodigt mens Nextcloud sætter sig selv op
- Derefter kan du logge ind
- Installer apps fra App Store (Calendar, Contacts, Mail, osv.)

### Docmost (Wiki & Dokumentation)

**URL:** http://localhost:3000

**Første gang:**
- Klik "Create workspace"
- Opret admin bruger:
  - Name: Dit Navn
  - Email: din@email.com
  - Password: DitSikkerPassword123!
- Opret dit workspace

**Efterfølgende:**
- Login med dine credentials

### Portainer (Docker Management)

**URL:** http://localhost:9000

**Første gang:**
- Opret admin bruger:
  - Username: admin
  - Password: DitSikkerPassword123! (mindst 12 tegn)
- Vælg "Docker" environment
- Klik "Connect"

**Efterfølgende:**
- Login med dine credentials
- Se og administrer alle dine Docker containers

---

## Næste Trin

Tillykke! Din homeserver kører nu! 🚀

### 1. Opsæt Cloudflare Tunnel (Anbefalet)

Få sikker HTTPS adgang til dine services fra internettet:

```bash
# Følg guiden i:
cat CLOUDFLARE_SETUP.md
```

**Benefits:**
- ✅ Tilgå dine services fra hvor som helst
- ✅ Automatisk HTTPS certifikater
- ✅ Ingen port forwarding nødvendig
- ✅ Sikkerhed via Cloudflare Access
- ✅ Gratis!

### 2. Opsæt Automatisk Opdatering

Lad din homeserver automatisk opdatere sig selv fra GitHub:

```bash
# Simpel metode - checker GitHub hvert 5. minut
./setup-auto-update.sh
```

Se også: [AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)

### 3. Lav Din Første Backup

```bash
# Lav backup af alle data
./backup.sh
```

Backups gemmes i `./backups/` mappen.

**Restore backup:**
```bash
./restore.sh backups/backup-2024-01-01.tar.gz
```

### 4. Opsæt Eksternt Disk (Valgfrit)

Hvis du vil bruge en ekstern disk til data:

```bash
# Følg guiden i:
cat EXTERNAL_DISK_SETUP.md

# Eller kør setup scriptet:
./setup-external-disk.sh
```

### 5. Udforsk Guides

- **[AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md)** - Automatisering og GitHub Actions
- **[CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md)** - Cloudflare Tunnel setup
- **[IOS_INTEGRATION.md](IOS_INTEGRATION.md)** - iOS Shortcuts integration
- **[PORTAINER_SETUP.md](PORTAINER_SETUP.md)** - Docker administration

---

## Nyttige Kommandoer

### Status og Logs

```bash
# Se status på alle containers
docker-compose ps

# Se logs fra alle services
docker-compose logs -f

# Se logs fra én service
docker-compose logs -f n8n

# Se de sidste 100 linjer
docker-compose logs --tail=100

# Følg logs real-time
docker-compose logs -f --tail=50
```

### Start, Stop, Genstart

```bash
# Start alle services
docker-compose up -d

# Stop alle services
docker-compose down

# Genstart alle services
docker-compose restart

# Genstart én service
docker-compose restart n8n

# Stop én service
docker-compose stop n8n

# Start én service
docker-compose start n8n
```

### Opdatering

```bash
# Opdater alle images til nyeste version
docker-compose pull

# Start med opdaterede images
docker-compose up -d

# Kombiner i én kommando
docker-compose pull && docker-compose up -d
```

### Cleanup

```bash
# Stop og fjern alle containers (BEVARER data)
docker-compose down

# Stop og fjern alt inkl. volumes (SLETTER data!)
docker-compose down -v

# Ryd ubrugte Docker resources
docker system prune -a

# Se disk forbrug
docker system df
```

### Resource Monitoring

```bash
# Se resource forbrug real-time
docker stats

# Se resource forbrug én gang
docker stats --no-stream

# Se kun specifikke containers
docker stats homeserver-postgres homeserver-nextcloud
```

### Database Adgang

```bash
# Tilgå PostgreSQL database direkte
docker exec -it homeserver-postgres psql -U postgres -d homeserver

# Se alle databaser
docker exec -it homeserver-postgres psql -U postgres -c "\l"

# Backup database manuelt
docker exec homeserver-postgres pg_dump -U postgres homeserver > backup.sql

# Restore database
docker exec -i homeserver-postgres psql -U postgres homeserver < backup.sql
```

---

## Troubleshooting

### Problem 1: "Port already in use"

**Fejl:**
```
Error: bind: address already in use
```

**Løsning:**

```bash
# Find hvad der bruger porten (f.eks. port 5678)
lsof -i :5678

# Stop processen eller skift port i .env:
nano .env

# Skift f.eks.:
N8N_PORT=5679
NOCODB_PORT=8082
NEXTCLOUD_PORT=8083

# Genstart
docker-compose down
docker-compose up -d
```

### Problem 2: "Database connection failed"

**Fejl:**
```
FATAL: password authentication failed
Could not connect to PostgreSQL
```

**Løsning:**

```bash
# Stop alle services
docker-compose down

# Slet database volumes (ADVARSEL: sletter alle data!)
docker volume rm homeserver_postgres_data

# Verificer .env POSTGRES_PASSWORD er korrekt
grep POSTGRES_PASSWORD .env

# Start igen
docker-compose up -d

# Se logs
docker-compose logs -f postgres
```

### Problem 3: Nextcloud "Access through untrusted domain"

**Fejl i browser:**
```
Access through untrusted domain
```

**Løsning:**

```bash
# Rediger .env
nano .env

# Find og opdater NEXTCLOUD_TRUSTED_DOMAINS
# Tilføj dit domæne eller IP:
NEXTCLOUD_TRUSTED_DOMAINS=localhost 192.168.1.100 cloud.ditdomæne.com

# Genstart Nextcloud
docker-compose restart nextcloud

# Vent 10 sekunder og reload browser
```

### Problem 4: Docker Desktop ikke kører

**Fejl:**
```
Cannot connect to the Docker daemon
```

**Løsning:**

1. Åbn Docker Desktop fra Applications
2. Vent til status viser "Docker Desktop is running"
3. Prøv igen

**På Linux:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable på boot
sudo systemctl enable docker
```

### Problem 5: Services starter ikke (Exit eller Restarting)

**Debug:**

```bash
# Se status
docker-compose ps

# Se detaljerede logs
docker-compose logs --tail=100

# Se logs for specifik service
docker-compose logs n8n

# Prøv at genstarte
docker-compose restart

# Eller stop og start forfra
docker-compose down
docker-compose up -d
```

### Problem 6: Nextcloud volume permission fejl

**Fejl:**
```
mkdir /host_mnt/Volumes/docker: permission denied
```

**Løsning:**

```bash
# Stop alle services
docker-compose down

# Slet Nextcloud volumes (ADVARSEL: sletter Nextcloud data!)
docker volume rm homeserver_nextcloud_data
docker volume rm homeserver_nextcloud_apps
docker volume rm homeserver_nextcloud_config
docker volume rm homeserver_nextcloud_data_files

# Start igen
docker-compose up -d
```

**Alternativ:**

Giv Docker Desktop adgang til din projekt mappe:
1. Åbn Docker Desktop
2. Settings > Resources > File Sharing
3. Tilføj din homeserver mappe
4. Apply & Restart

### Problem 7: Cloudflared "tunnel credentials not found"

**Fejl:**
```
Failed to get tunnel: tunnel credentials not found
```

**Løsning:**

```bash
# Tjek at token er sat i .env
grep CLOUDFLARE_TUNNEL_TOKEN .env

# Hvis ikke sat eller forkert:
nano .env

# Tilføj/opdater:
CLOUDFLARE_TUNNEL_TOKEN=dit-korrekte-token-her

# Genstart cloudflared
docker-compose restart cloudflared

# Se logs
docker-compose logs -f cloudflared
```

### Problem 8: Dashboard viser gammel version efter update

**Løsning:**

```bash
# Force rebuild af dashboard
docker-compose restart dashboard

# Eller genbyg fra scratch
docker-compose stop dashboard
docker-compose rm -f dashboard
docker-compose up -d dashboard

# I browser: Hard refresh
# Mac: Cmd + Shift + R
# Windows/Linux: Ctrl + Shift + R
```

### Problem 9: Ikke nok diskplads

**Tjek diskplads:**

```bash
# Se Docker disk forbrug
docker system df

# Se detaljeret info
docker system df -v
```

**Cleanup:**

```bash
# Ryd ubrugte images, containers, networks
docker system prune -a

# Ryd volumes (ADVARSEL: kan slette data!)
docker volume prune

# Ryd alt (ADVARSEL: sletter ubrugte volumes!)
docker system prune -a --volumes
```

### Problem 10: Langsom performance

**Tjek resource forbrug:**

```bash
docker stats
```

**Løsninger:**

1. **Øg RAM til Docker Desktop:**
   - Docker Desktop > Settings > Resources
   - Øg Memory til 4-8 GB

2. **Genstart tunge services:**
   ```bash
   docker-compose restart nextcloud
   docker-compose restart postgres
   ```

3. **Reducér antal services:**
   - Kommenter services ud i docker-compose.yml du ikke bruger
   - `docker-compose down && docker-compose up -d`

---

## Verificer Installation - Samlet Tjekliste

Kør denne kommando for en samlet status:

```bash
echo "=== HOMESERVER STATUS ===" && \
echo "" && \
echo "=== Docker Version ===" && \
docker --version && \
docker-compose --version && \
echo "" && \
echo "=== Container Status ===" && \
docker-compose ps && \
echo "" && \
echo "=== Resource Forbrug ===" && \
docker stats --no-stream && \
echo "" && \
echo "=== Disk Forbrug ===" && \
docker system df && \
echo "" && \
echo "=== Services URLs ===" && \
echo "Dashboard:  http://localhost:8082" && \
echo "n8n:        http://localhost:5678" && \
echo "NocoDB:     http://localhost:8080" && \
echo "Nextcloud:  http://localhost:8081" && \
echo "Docmost:    http://localhost:3000" && \
echo "Portainer:  http://localhost:9000" && \
echo ""
```

---

## Sikkerhed Checklist

Før du går i produktion, gennemgå denne checklist:

- [ ] Alle passwords i .env er ændret fra default værdier
- [ ] .env filen er IKKE committet til git (tjek `.gitignore`)
- [ ] Stærke passwords bruges (mindst 16 tegn, mixed case, tal, specialtegn)
- [ ] SMTP er konfigureret (hvis du vil have email notifikationer)
- [ ] Cloudflare Tunnel sat op (hvis du vil have internet adgang)
- [ ] Backup rutine etableret (`./backup.sh`)
- [ ] Portainer admin bruger oprettet med stærkt password
- [ ] Nextcloud trusted domains konfigureret korrekt
- [ ] NocoDB admin bruger oprettet
- [ ] Docmost workspace oprettet

---

## Yderligere Ressourcer

### Officiel Dokumentation

- [n8n Documentation](https://docs.n8n.io/)
- [NocoDB Documentation](https://docs.nocodb.com/)
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Docmost Documentation](https://docmost.com/docs)
- [Portainer Documentation](https://docs.portainer.io/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Documentation](https://docs.docker.com/)

### Homeserver Guides

- [README.md](README.md) - Projekt overview
- [AUTOMATION_GUIDE.md](AUTOMATION_GUIDE.md) - GitHub automation
- [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) - Internet adgang
- [IOS_INTEGRATION.md](IOS_INTEGRATION.md) - iPhone/iPad integration
- [EXTERNAL_DISK_SETUP.md](EXTERNAL_DISK_SETUP.md) - Ekstern disk
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Fejlfinding

---

## FAQ

### Hvor ligger mine data?

Alle data gemmes i Docker volumes:

```bash
# Se alle volumes
docker volume ls | grep homeserver

# Inspect et volume
docker volume inspect homeserver_postgres_data

# Data ligger typisk i:
# Mac: ~/Library/Containers/com.docker.docker/Data/vms/0/
# Linux: /var/lib/docker/volumes/
```

### Kan jeg flytte min homeserver til en anden computer?

Ja! Lav en backup og restore på den nye computer:

```bash
# På gammel computer:
./backup.sh

# Kopier backup filen til ny computer
# På ny computer (efter installation):
./restore.sh backup-2024-01-01.tar.gz
```

### Hvordan opdaterer jeg til nyeste version?

```bash
# Pull seneste kode fra GitHub
git pull origin main

# Opdater Docker images
docker-compose pull

# Genstart med nye images
docker-compose up -d
```

### Kan jeg bruge andre porte?

Ja! Rediger portene i `.env` filen:

```bash
N8N_PORT=5679
NOCODB_PORT=8082
NEXTCLOUD_PORT=8083
DOCMOST_PORT=3001
DASHBOARD_PORT=8084
PORTAINER_PORT=9001
```

### Hvor meget koster det at køre?

**Gratis software:**
- Alle services er open source og gratis!

**Hosting omkostninger:**
- Hvis du kører på din egen computer: Kun strøm (~$5-10/måned)
- Hvis du bruger Cloudflare Tunnel: Gratis!
- Hvis du køber en domain: ~$10-15/år

### Hvordan sletter jeg alt?

```bash
# Stop alle services
docker-compose down

# Slet alle volumes (DATA!)
docker-compose down -v

# Slet projekt mappen
cd ~
rm -rf homeserver
```

---

**🎉 Tillykke! Du er nu klar med din homeserver!**

Hvis du har spørgsmål eller problemer, se [TROUBLESHOOTING.md](TROUBLESHOOTING.md) eller opret et issue på GitHub.

**God fornøjelse! 🚀**
