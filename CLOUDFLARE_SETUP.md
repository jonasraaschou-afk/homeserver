# Cloudflare Tunnel Setup Guide

Denne guide viser dig præcis hvordan du opsætter Cloudflare Tunnel så alle dine services kan tilgås via internettet - helt gratis og uden port forwarding!

## 🎯 Fordele ved Cloudflare Tunnel

- ✅ **Gratis** - Ingen omkostninger
- ✅ **Ingen port forwarding** - Din router forbliver lukket
- ✅ **Sikker** - Alt trafik går gennem Cloudflares netværk
- ✅ **SSL/TLS automatisk** - HTTPS uden manuel certificering
- ✅ **DDoS beskyttelse** - Built-in fra Cloudflare

## 📋 Forudsætninger

1. Et domæne (kan købes billigt hos Cloudflare, Namecheap, etc.)
2. Cloudflare account (gratis)
3. Dit domæne skal bruge Cloudflares nameservere

## 🚀 Trin-for-trin Opsætning

### 1. Tilføj dit domæne til Cloudflare

1. Log ind på https://dash.cloudflare.com
2. Klik på "Add a Site"
3. Indtast dit domæne (f.eks. `dinserver.com`)
4. Vælg den gratis plan
5. Opdater nameservere hos din domæne registrar til Cloudflares nameservere

**Vent på at DNS propagerer (kan tage op til 24 timer, men ofte kun minutter)**

### 2. Opret Cloudflare Tunnel

1. I Cloudflare Dashboard, gå til **"Zero Trust"**
2. I venstre menu: **"Networks"** → **"Tunnels"**
3. Klik på **"Create a tunnel"**
4. Vælg **"Cloudflared"** som connector type
5. Giv tunnelen et navn: `homeserver-mac-mini`
6. Klik **"Save tunnel"**

### 3. Kopier Tunnel Token

Efter oprettelse får du et **Tunnel Token** - det ser sådan ud:
```
eyJhIjoiMTIzNDU2Nzg5MGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6IiwidCI6IjEyMzQ1Njc4LWFiY2QtMTIzNC1hYmNkLTEyMzQ1Njc4OTBhYiIsInMiOiJBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWiJ9
```

**Kopier hele tokenet** og indsæt det i din `.env` fil:
```bash
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiMTIz...
```

### 4. Konfigurer Public Hostnames

Nu skal du fortælle Cloudflare hvilke services der skal være tilgængelige.

I Cloudflare Tunnel konfigurationen, klik på **"Public Hostname"** fanen:

#### Service 1: n8n

Klik **"Add a public hostname"**:
- **Subdomain:** `n8n`
- **Domain:** `dinserver.com` (dit domæne)
- **Type:** `HTTP`
- **URL:** `n8n:5678`

Fuld URL bliver: `https://n8n.dinserver.com` → `http://n8n:5678`

#### Service 2: NocoDB

Klik **"Add a public hostname"**:
- **Subdomain:** `nocodb`
- **Domain:** `dinserver.com`
- **Type:** `HTTP`
- **URL:** `nocodb:8080`

Fuld URL bliver: `https://nocodb.dinserver.com` → `http://nocodb:8080`

#### Service 3: Nextcloud

Klik **"Add a public hostname"**:
- **Subdomain:** `cloud` (eller `nextcloud`)
- **Domain:** `dinserver.com`
- **Type:** `HTTP`
- **URL:** `nextcloud:80`

Fuld URL bliver: `https://cloud.dinserver.com` → `http://nextcloud:80`

**Gem hver konfiguration!**

### 5. Opdater .env fil

Nu skal du opdatere `.env` filen med de rigtige URLs:

```bash
# Opdater disse linjer i .env:

# n8n
N8N_HOST=n8n.dinserver.com
N8N_PROTOCOL=https
N8N_WEBHOOK_URL=https://n8n.dinserver.com/

# NocoDB
NOCODB_PUBLIC_URL=https://nocodb.dinserver.com

# Nextcloud
NEXTCLOUD_TRUSTED_DOMAINS=cloud.dinserver.com
NEXTCLOUD_PROTOCOL=https
```

**Husk:** Erstat `dinserver.com` med dit eget domæne!

### 6. Start din Homeserver

```bash
./deploy.sh
```

### 7. Test Adgang

Efter 1-2 minutter skulle alt være klar. Prøv at tilgå:

- 🔗 https://n8n.dinserver.com
- 🔗 https://nocodb.dinserver.com
- 🔗 https://cloud.dinserver.com

**Alt har automatisk HTTPS! 🎉**

## 🔒 Sikkerhed: Access Policies (Anbefalet)

For ekstra sikkerhed kan du tilføje adgangskontrol via Cloudflare Access:

### Trin 1: Aktiver Cloudflare Access

1. I Zero Trust Dashboard: **"Access"** → **"Applications"**
2. Klik **"Add an application"**
3. Vælg **"Self-hosted"**

### Trin 2: Konfigurer Applikation

For hver service (n8n, nocodb, nextcloud):

**Application Configuration:**
- **Application name:** `n8n` (eller service navn)
- **Session Duration:** `24 hours`
- **Application domain:**
  - Subdomain: `n8n`
  - Domain: `dinserver.com`

**Identity Providers:**
- Vælg hvordan brugere skal logge ind:
  - **One-time PIN** (email baseret, nemt)
  - **Google** (hvis du har Google Workspace)
  - **GitHub** (god for udviklere)

**Policies:**
- Opret en policy der kun tillader din email:
  - **Policy name:** `Only me`
  - **Rule:** Include → Emails → `din@email.com`

Nu skal alle der vil tilgå dine services **først logge ind via Cloudflare**!

## 🧪 Troubleshooting

### Problem: "tunnel credentials file not found"

**Løsning:** Tjek at `CLOUDFLARE_TUNNEL_TOKEN` er sat korrekt i `.env`

```bash
# Tjek at token er der:
grep CLOUDFLARE_TUNNEL_TOKEN .env
```

### Problem: "Unable to reach origin service"

**Løsninger:**

1. **Tjek at services kører:**
   ```bash
   docker-compose ps
   ```

2. **Tjek service navne i Cloudflare:**
   - Brug service navn fra docker-compose (f.eks. `n8n`, `nocodb`, `nextcloud`)
   - IKKE `localhost` eller `127.0.0.1`

3. **Tjek porte:**
   - n8n: port `5678`
   - nocodb: port `8080`
   - nextcloud: port `80` (ikke 8081!)

### Problem: Nextcloud viser "Access through untrusted domain"

**Løsning:** Opdater `NEXTCLOUD_TRUSTED_DOMAINS` i `.env`:

```bash
NEXTCLOUD_TRUSTED_DOMAINS=cloud.dinserver.com localhost
```

Genstart derefter:
```bash
docker-compose restart nextcloud
```

### Problem: n8n webhooks virker ikke

**Løsning:** Tjek `N8N_WEBHOOK_URL` i `.env`:

```bash
N8N_WEBHOOK_URL=https://n8n.dinserver.com/
```

Skal matche din Cloudflare public hostname.

## 📊 Monitoring

### Se Cloudflare Tunnel Status

```bash
docker-compose logs -f cloudflared
```

Du skulle se:
```
INF Connection established
INF Registered tunnel connection
```

### Se Trafik i Cloudflare

1. Gå til Zero Trust Dashboard
2. **"Networks"** → **"Tunnels"**
3. Klik på din tunnel
4. Se **"Traffic"** fanen for statistik

## 🎯 Komplet Eksempel

Her er et komplet eksempel med domænet `homelab.dk`:

### Cloudflare Public Hostnames:
```
n8n.homelab.dk → http://n8n:5678
nocodb.homelab.dk → http://nocodb:8080
cloud.homelab.dk → http://nextcloud:80
```

### .env fil:
```bash
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiZGluLXJpZ3RpZ2UtdG9rZW4taGVyIn0=

N8N_HOST=n8n.homelab.dk
N8N_PROTOCOL=https
N8N_WEBHOOK_URL=https://n8n.homelab.dk/

NOCODB_PUBLIC_URL=https://nocodb.homelab.dk

NEXTCLOUD_TRUSTED_DOMAINS=cloud.homelab.dk
NEXTCLOUD_PROTOCOL=https
```

### Test:
- ✅ https://n8n.homelab.dk - n8n login side
- ✅ https://nocodb.homelab.dk - NocoDB dashboard
- ✅ https://cloud.homelab.dk - Nextcloud login

**Alt tilgængeligt fra hele verden med HTTPS! 🌍**

## 💡 Pro Tips

1. **Brug korte subdomains** - `n8n.din.dk` er bedre end `n8n-workflow-automation.din.dk`

2. **Aktiver Cloudflare WAF** (Web Application Firewall):
   - Zero Trust → Gateway → Firewall Policies
   - Tilføj regler for ekstra beskyttelse

3. **Log alt** - Cloudflare logger al trafik:
   - Zero Trust → Logs → Gateway
   - Se hvem der tilgår hvad og hvornår

4. **Backup dit tunnel token** - gem det sikkert, du kan ikke se det igen!

5. **Test fra mobil netværk** - Tjek at det virker uden for dit hjemmenetværk

## ❓ Ofte Stillede Spørgsmål

**Q: Skal jeg åbne porte i min router?**
A: Nej! Det er hele pointen med Cloudflare Tunnel - ingen port forwarding nødvendig.

**Q: Koster Cloudflare Tunnel noget?**
A: Nej, det er 100% gratis med Cloudflares Free plan.

**Q: Hvor mange services kan jeg eksponere?**
A: Ubegrænset! Du kan tilføje så mange public hostnames du vil.

**Q: Kan andre se min homeserver?**
A: Kun hvis de kender URL'en. Brug Cloudflare Access for ekstra sikkerhed.

**Q: Hvad hvis min Mac mini genstarter?**
A: Docker er konfigureret til at starte automatisk (`restart: unless-stopped`).

**Q: Kan jeg bruge mit eget SSL certifikat?**
A: Ikke nødvendigt - Cloudflare håndterer alt SSL automatisk.

## 📚 Nyttige Links

- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflare Zero Trust](https://www.cloudflare.com/zero-trust/)
- [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/applications/)
- [Tunnel Configuration](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/)

---

**Held og lykke med din homeserver! 🚀**

Hvis du har problemer, tjek først:
1. Cloudflared logs: `docker-compose logs cloudflared`
2. Service logs: `docker-compose logs <service-navn>`
3. Cloudflare Dashboard for tunnel status
