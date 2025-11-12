# 🐳 Portainer Setup Guide

Portainer er nu installeret! Her er hvordan du bruger det.

## 🎯 Hvad Er Portainer?

Portainer er et **grafisk interface til Docker**. I stedet for at bruge terminal kommandoer, kan du:

- 👀 Se alle containers i et dashboard
- ▶️ Start/stop/genstart containers med et klik
- 📊 Se ressourceforbrug (CPU, RAM, disk)
- 📝 Se logs live
- 🔍 Inspicere container detaljer
- 🌐 Administrere netværk og volumes
- 📦 Pull nye images
- 🚀 Deploy nye stacks

**Perfekt til:** Nybegyndere og dem der foretrækker GUI over CLI

---

## 🚀 Installation

Portainer er allerede tilføjet til din docker-compose.yml!

### Trin 1: Tilføj Port til .env

```bash
cd ~/homeserver
echo "PORTAINER_PORT=9000" >> .env
echo "PORTAINER_EDGE_PORT=8000" >> .env
```

### Trin 2: Start Portainer

```bash
docker-compose up -d portainer
```

### Trin 3: Vent 10 sekunder

```bash
sleep 10
```

### Trin 4: Åbn Portainer Lokalt

**På din Mac mini:**
Åbn browser: http://localhost:9000

Du vil se en setup wizard første gang! 🎉

---

## 🔐 Første Gangs Setup

### 1. Create Admin User

Første gang du åbner Portainer:

**Username:** `admin`
**Password:** Vælg et stærkt password (min. 12 tegn)

**VIGTIGT:** Gem dette password - det er dit Portainer admin login!

### 2. Vælg Environment

Efter login:
- Vælg **"Get Started"**
- Eller vælg **"Docker"** → **"Connect"**

Portainer detecter automatisk din lokale Docker!

### 3. Explore Dashboard

Du vil nu se:
- **Home** - Oversigt over miljøer
- **Containers** - Alle dine containers
- **Images** - Docker images
- **Networks** - Docker networks
- **Volumes** - Data volumes
- **Stacks** - Docker compose stacks

**Prøv at klikke rundt! Alt er intuitivt 🎨**

---

## 🌐 Cloudflare Tunnel Setup

For at tilgå Portainer fra internettet:

### 1. Gå til Cloudflare Zero Trust Dashboard

https://one.dash.cloudflare.com

### 2. Find Din Tunnel

Networks → Tunnels → homeserver (eller dit tunnel navn)

### 3. Tilføj Public Hostname

Klik **"Add a public hostname"**:

```
Subdomain: portainer
Domain: kobber.me
Type: HTTP
URL: portainer:9000
```

**Vigtig:** Port `9000` (ikke 9443!)

Klik **Save**

### 4. Test Fra Internettet

Gå til: **https://portainer.kobber.me**

Login med dit admin password! 🎉

---

## 📊 Sådan Bruger Du Portainer

### Se Alle Containers

1. **Containers** i venstre menu
2. Se liste med alle containers
3. **Grøn = Running**, **Rød = Stopped**

**Quick actions:**
- ▶️ Start
- ⏸️ Pause
- ⏹️ Stop
- 🔄 Restart
- 🗑️ Remove
- 📝 Logs
- 📊 Stats
- 🔍 Inspect

### Start/Stop Container

1. Vælg container (checkbox)
2. Klik **Start** eller **Stop** knap øverst
3. Færdig! 🎉

### Se Live Logs

1. Klik på container navn
2. **Logs** tab
3. **Auto-refresh** for live logs
4. **Search** for at finde specifik fejl

### Se Ressourceforbrug

1. Klik på container navn
2. **Stats** tab
3. Se live CPU, RAM, network, disk I/O

**Perfekt til:** At finde hvilke containers bruger mest ressourcer

### Restart Container

1. Klik på container navn
2. **Restart** knap øverst
3. Confirm

**Eller:**
1. Vælg container i listen
2. **Restart** knap i toppen

### Administrer Volumes

1. **Volumes** i venstre menu
2. Se alle Docker volumes
3. Klik på volume for detaljer
4. Se hvilke containers der bruger det

### Administrer Images

1. **Images** i venstre menu
2. Se alle downloaded images
3. **Pull Image** for at hente nye
4. **Remove** ubrugte images

### Deploy Ny Stack

1. **Stacks** i venstre menu
2. **Add stack**
3. Paste docker-compose.yml indhold
4. **Deploy**

**Alternativt:** Upload docker-compose.yml fil

---

## 💡 Nyttige Features

### Quick Stats Dashboard

**Home** → Klik på dit environment

**Se:**
- Antal containers (running/stopped)
- Antal volumes
- Antal images
- System info (CPU, RAM)

### Container Console

1. Klik på container
2. **Console** tab
3. Connect som **root** eller **custom user**
4. Klik **Connect**

Nu har du en terminal inde i containeren! 🖥️

**Eksempel:** Debug Nextcloud inde i containeren

### Logs Med Search

1. Container → **Logs**
2. Brug search box
3. Find specifik fejl eller event
4. **Copy** logs til clipboard

### Container Inspect

1. Container → **Inspect**
2. Se fuld JSON konfiguration
3. Netværk, volumes, environment variables
4. Health checks, restart policy

---

## 🎨 Pro Tips

### 1. Bookmark Containers

Højreklik på container → **Add to favorites**

Nu vises de øverst i listen!

### 2. Container Groups

Filtrer efter:
- Status (Running/Stopped)
- Name
- Image

### 3. Bulk Actions

Vælg flere containers (checkbox) → Apply action til alle

**Eksempel:** Stop alle containers på én gang

### 4. Templates

**App Templates** i menu → Deploy populære apps med ét klik

**Eksempler:**
- WordPress
- MySQL
- Redis
- Nginx

### 5. Notifications

**Notifications** i toppen → Se alerts og events

---

## 🔐 Sikkerhed

### Change Admin Password

1. **User** icon (top right)
2. **My account**
3. **Change password**
4. Gem nyt password

### Add Users (Valgfrit)

1. **Users** i menu
2. **Add user**
3. Set permissions
4. Send login info

**Nyttigt hvis:** Flere personer skal have adgang

### Enable 2FA (Anbefalet)

**Pro feature** - kræver Portainer Business Edition

Alternativ: Brug Cloudflare Access policies (vi har det allerede!)

---

## 📱 Portainer Mobile App

Portainer har officiel mobile app!

**Download:**
- iOS: App Store (søg "Portainer")
- Android: Play Store

**Login:**
- URL: `https://portainer.kobber.me`
- Username: `admin`
- Password: Dit admin password

**Features:**
- Se containers on-the-go
- Start/stop containers fra telefonen
- Se logs
- Push notifications (Pro)

---

## 🛠 Troubleshooting

### Kan ikke tilgå Portainer

**Tjek container kører:**
```bash
docker-compose ps portainer
```

**Tjek logs:**
```bash
docker-compose logs portainer
```

**Genstart:**
```bash
docker-compose restart portainer
```

### "Connection refused"

**Årsag:** Docker socket ikke mounted korrekt

**Fix:**
```bash
docker-compose down portainer
docker-compose up -d portainer
```

### Forgot Admin Password

**Reset:**
```bash
docker-compose stop portainer
docker run --rm -v homeserver_portainer_data:/data \
  portainer/helper-reset-password
docker-compose start portainer
```

Du får et nyt midlertidigt password i output.

### Portainer viser "No containers"

**Årsag:** Ikke connected til Docker

**Fix:**
1. Settings → Environments
2. Select "local"
3. Verify socket: `/var/run/docker.sock`
4. Test connection

---

## 🎯 Common Tasks

### Restart All Containers

1. **Stacks** → **homeserver**
2. **Stop** button
3. Wait 10 seconds
4. **Start** button

### Update Container Image

1. **Images** → Find image
2. **Pull** button
3. Wait for download
4. **Containers** → Select container
5. **Recreate** button

### See What's Using Disk Space

1. **Volumes** menu
2. Sort by size
3. Click volume → See details

### Cleanup Unused Images

1. **Images** menu
2. Select unused images
3. **Remove** button

---

## 📊 Dashboard Integration

Portainer er nu tilføjet til dit home.kobber.me dashboard! 🎉

**Tile:** 🐳 Portainer - "Docker management UI"

Klik for at åbne direkte!

---

## 🚀 Næste Skridt

Nu hvor du har Portainer:

1. **Explore alle features** - Klik rundt, det er intuitivt!
2. **Bookmark i browser** - https://portainer.kobber.me
3. **Download mobile app** - Administrer fra iPhone
4. **Lær shortcuts** - Hurtigere workflows

**Pro tip:** Lav en iOS shortcut til at åbne Portainer! 📱

---

## 💬 Hvad Synes Du?

Portainer gør Docker management MEGET nemmere!

Før: `docker-compose logs nextcloud | grep error`
Nu: Klik → Logs tab → Search box 🎉

**Nyd dit nye Docker dashboard! 🐳✨**
