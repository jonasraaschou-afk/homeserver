# Cloudflare Tunnel Setup Guide for kobber.me

## 🎯 Dit Mål
- Tilgå n8n, NocoDB og Nextcloud fra internettet via kobber.me
- Få HTTPS til at virke (så n8n fungerer korrekt)
- Ingen port forwarding nødvendig

## 📋 Status
- ✅ Domæne: kobber.me registreret i Cloudflare
- ⏳ Cloudflare Tunnel: Skal opsættes
- ⏳ Services: Kører lokalt, men skal exponeres

---

## 🚀 Trin-for-Trin Setup

### Trin 1: Opret Cloudflare Tunnel

1. **Log ind på Cloudflare Dashboard**
   - Gå til: https://dash.cloudflare.com
   - Vælg dit domæne `kobber.me`

2. **Gå til Zero Trust**
   - I venstre menu, klik på **"Zero Trust"**
   - Hvis det er første gang, skal du muligvis aktivere Zero Trust (det er gratis)

3. **Opret Tunnel**
   - I venstre menu: **"Networks"** → **"Tunnels"**
   - Klik på **"Create a tunnel"** (blå knap øverst til højre)
   - Vælg **"Cloudflared"** som tunnel type
   - Giv tunnelen et navn: `homeserver` eller `mac-mini`
   - Klik **"Save tunnel"**

4. **Kopier Tunnel Token**
   Du får nu vist et **Tunnel Token** - det ser sådan ud:
   ```
   eyJhIjoiMTIzNDU2Nzg5MGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6IiwidCI6IjEyMzQ1Njc4...
   ```

   **VIGTIGT: Kopier hele tokenet!**

---

### Trin 2: Tilføj Token til Din Homeserver

På din Mac mini:

```bash
cd ~/homeserver
nano .env
```

Find linjen:
```bash
CLOUDFLARE_TUNNEL_TOKEN=dit-token-her
```

Erstat `dit-token-her` med dit rigtige token:
```bash
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiMTIzNDU2Nzg5MGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6...
```

**Gem filen:** `Ctrl+X`, derefter `Y`, derefter `Enter`

---

### Trin 3: Konfigurer Public Hostnames i Cloudflare

Tilbage i Cloudflare Dashboard (tunnel konfiguration):

#### Service 1: n8n

Klik **"Add a public hostname"** eller gå til "Public Hostname" fanen:

```
Subdomain:  n8n
Domain:     kobber.me (vælg fra dropdown)
Path:       (lad stå tom)

Service:
  Type: HTTP
  URL:  n8n:5678
```

Fuld URL bliver: **n8n.kobber.me → http://n8n:5678**

Klik **"Save hostname"**

#### Service 2: NocoDB

Klik **"Add a public hostname"** igen:

```
Subdomain:  nocodb
Domain:     kobber.me
Path:       (lad stå tom)

Service:
  Type: HTTP
  URL:  nocodb:8080
```

Fuld URL bliver: **nocodb.kobber.me → http://nocodb:8080**

Klik **"Save hostname"**

#### Service 3: Nextcloud

Klik **"Add a public hostname"** igen:

```
Subdomain:  cloud
Domain:     kobber.me
Path:       (lad stå tom)

Service:
  Type: HTTP
  URL:  nextcloud:80
```

⚠️ **Bemærk:** Port `80` (IKKE 8081!) fordi det er den interne port i containeren.

Fuld URL bliver: **cloud.kobber.me → http://nextcloud:80**

Klik **"Save hostname"**

---

### Trin 4: Opdater .env Fil Med Dine Domæner

På din Mac mini:

```bash
cd ~/homeserver
nano .env
```

**Find og opdater disse linjer:**

```bash
# n8n Configuration
N8N_HOST=n8n.kobber.me
N8N_PROTOCOL=https
N8N_WEBHOOK_URL=https://n8n.kobber.me/

# NocoDB Configuration
NOCODB_PUBLIC_URL=https://nocodb.kobber.me

# Nextcloud Configuration
NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me
NEXTCLOUD_PROTOCOL=https
```

**Gem:** `Ctrl+X`, `Y`, `Enter`

---

### Trin 5: Genstart Services

```bash
cd ~/homeserver
docker-compose down
docker-compose up -d
```

Vent 30 sekunder på at services starter.

---

### Trin 6: Verificer Cloudflare Tunnel

Tjek at cloudflared containeren kører:

```bash
docker-compose logs cloudflared
```

Du skal se noget lignende:
```
INF Connection established
INF Registered tunnel connection
```

Hvis du ser fejl som "tunnel credentials not found", tjek at dit token er korrekt i `.env`.

---

### Trin 7: Test Adgang Fra Internettet! 🎉

Åbn din browser og test:

1. **n8n**: https://n8n.kobber.me
   - Du skal nu se n8n login siden
   - Login med dine credentials fra `.env` filen

2. **NocoDB**: https://nocodb.kobber.me
   - Opret admin bruger første gang

3. **Nextcloud**: https://cloud.kobber.me
   - Login med admin credentials fra `.env`

**Alt har nu automatisk HTTPS! 🔒**

---

## ✅ Tjekliste

- [ ] Cloudflare Tunnel oprettet
- [ ] Tunnel token kopieret til `.env`
- [ ] Public hostnames konfigureret (n8n, nocodb, cloud)
- [ ] `.env` opdateret med kobber.me domæner
- [ ] Services genstartet
- [ ] Cloudflared logs viser "Connection established"
- [ ] n8n.kobber.me virker i browser
- [ ] nocodb.kobber.me virker i browser
- [ ] cloud.kobber.me virker i browser

---

## 🔧 Troubleshooting

### Problem: "Unable to reach origin service"

**Årsag:** Cloudflare kan ikke nå din service

**Løsning:**
```bash
# Tjek at services kører
docker-compose ps

# Tjek at service navne er korrekte
# Skal være: n8n:5678, nocodb:8080, nextcloud:80
# IKKE: localhost:5678 eller 127.0.0.1:5678
```

### Problem: Nextcloud viser "Access through untrusted domain"

**Løsning:**
```bash
nano .env

# Tilføj:
NEXTCLOUD_TRUSTED_DOMAINS=cloud.kobber.me localhost

# Genstart
docker-compose restart nextcloud
```

### Problem: n8n viser SSL fejl

**Løsning:**
```bash
nano .env

# Verificer:
N8N_PROTOCOL=https
N8N_HOST=n8n.kobber.me
N8N_WEBHOOK_URL=https://n8n.kobber.me/

# Genstart
docker-compose restart n8n
```

### Problem: "Tunnel credentials file not found"

**Løsning:**
```bash
# Tjek at token er i .env
grep CLOUDFLARE_TUNNEL_TOKEN .env

# Hvis tom eller forkert, tilføj dit rigtige token
nano .env
```

### Problem: Kan ikke tilgå fra internettet

**Tjek:**
1. Er dit domæne aktivt i Cloudflare? (Orange sky ikon)
2. Er tunnel "Active" i Cloudflare Dashboard?
3. Viser cloudflared logs "Connection established"?
4. Er public hostnames korrekt konfigureret?

```bash
# Tjek tunnel status
docker-compose logs cloudflared --tail=50
```

---

## 📊 Oversigt Over Dine URLs

| Service | Lokal URL | Internet URL (via Cloudflare) |
|---------|-----------|-------------------------------|
| n8n | http://localhost:5678 | https://n8n.kobber.me |
| NocoDB | http://localhost:8080 | https://nocodb.kobber.me |
| Nextcloud | http://localhost:8081 | https://cloud.kobber.me |

---

## 🔐 Ekstra Sikkerhed (Valgfrit)

Vil du tilføje ekstra login før dine services?

### Opsæt Cloudflare Access

1. Gå til Zero Trust → **"Access"** → **"Applications"**
2. Klik **"Add an application"** → **"Self-hosted"**
3. Konfigurer:
   - Application name: `n8n`
   - Session Duration: `24 hours`
   - Application domain: `n8n.kobber.me`
4. Vælg login metode (email OTP er nemmest)
5. Opret policy: Kun tillad din email

Nu skal man logge ind via Cloudflare før man kan tilgå n8n!

---

## 🎉 Færdig!

Nu kan du tilgå din homeserver fra hele verden via:
- https://n8n.kobber.me
- https://nocodb.kobber.me
- https://cloud.kobber.me

Alt er automatisk sikret med HTTPS! 🔒

**Næste skridt:**
- Opsæt automatisk opdatering: `./setup-auto-update.sh`
- Lav backup: `./backup.sh`
- Læs mere i CLOUDFLARE_SETUP.md for avancerede features

---

**Held og lykke! 🚀**
