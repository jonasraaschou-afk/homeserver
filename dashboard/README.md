# Dashboard - Homeserver Landing Page

En moderne, responsiv dashboard til at tilgå alle dine homeserver services.

## 🎨 Features

- ✨ Moderne glassmorphism design
- 📱 Fuldt responsiv (desktop, tablet, mobil)
- 🎭 Theme toggle (lys/mørk gradient)
- ⚡ Animerede service cards
- 🟢 Status indikatorer
- 🔗 Direkte links til alle services

## 🌐 Adgang

**Lokalt:**
http://localhost:8082

**Via Cloudflare Tunnel:**
https://kobber.me (eller dit valgte subdomain)

## ⚙️ Konfiguration i Cloudflare

For at få dashboard'et tilgængeligt fra internettet, tilføj i Cloudflare Tunnel:

```
Subdomain: (lad stå tom for root domain)
Domain: kobber.me
Type: HTTP
URL: dashboard:80
```

Dette gør at https://kobber.me peger direkte på dit dashboard!

Alternativt kan du bruge et subdomain:
```
Subdomain: home
Domain: kobber.me
Type: HTTP
URL: dashboard:80
```

Så bliver det tilgængeligt på: https://home.kobber.me

## 🎨 Tilpas Dashboard

Rediger `index.html` for at:

### Tilføje nye services:

```html
<a href="https://din-service.kobber.me" class="service-card" target="_blank">
    <span class="service-icon">🚀</span>
    <div class="service-title">Din Service</div>
    <div class="service-description">
        Beskrivelse af hvad servicen gør.
    </div>
    <div class="service-status">
        <span class="status-dot"></span> Online
    </div>
</a>
```

### Ændre farver:

I `<style>` sektionen, find:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

Erstat med dine egne farver (brug f.eks. https://uigradients.com)

### Ændre ikoner:

Service ikoner kan ændres til:
- ⚡ 🔥 🚀 💎 🎯 🎨 🎭 🎪 🎬 🎮
- 📊 📈 📉 📁 📂 📋 📌 📍 📎 📧
- ☁️ 🌐 🌟 ⭐ 💫 ✨ 🔮 🔒 🔓 🔑

## 🔧 Avanceret Tilpasning

### Real-time status check

Uncomment denne linje i scriptet:
```javascript
checkServiceStatus();
```

Dette vil forsøge at checke om services er online (kræver CORS setup).

### Custom CSS

Tilføj dine egne styles i `<style>` sektionen for at matche dit brand.

### Dynamisk content

For dynamisk content (f.eks. server statistikker), kan du:
1. Tilføje en simpel API service
2. Fetch data med JavaScript
3. Opdatere cards dynamisk

## 📱 Mobile App Look

Dashboard'et bruger PWA-venlig styling, så du kan:
1. Åbn dashboard på mobil
2. Vælg "Tilføj til hjemmeskærm"
3. Nu har du en app-lignende oplevelse!

## 💡 Ideer til Flere Services

Overvej at tilføje:
- **Portainer** - Docker management UI
- **Uptime Kuma** - Service monitoring
- **Grafana** - Metrics og dashboards
- **Jellyfin** - Media server
- **Home Assistant** - Smart home
- **Vaultwarden** - Password manager
- **Gitea** - Git server
- **Bookstack** - Documentation
- **Invoice Ninja** - Fakturering
- **Monica** - Personal CRM

## 🎯 Best Practices

1. **Simpelt design** - Hold dashboard overskueligt
2. **Konsistent styling** - Brug samme ikoner og farver
3. **Status monitoring** - Tilføj real-time status checks
4. **Mobile first** - Test altid på mobil
5. **Fast loading** - Hold filer små og optimerede

## 🛠 Troubleshooting

### Dashboard vises ikke

```bash
# Tjek at container kører
docker-compose ps dashboard

# Tjek logs
docker-compose logs dashboard

# Genstart
docker-compose restart dashboard
```

### Styling virker ikke

Browser cache kan være problemet:
- Hard refresh: Cmd+Shift+R (Mac) eller Ctrl+Shift+R (Windows)
- Eller: Clear browser cache

### Cloudflare viser ikke dashboard

Tjek at public hostname er konfigureret korrekt:
- Service type: HTTP
- URL: `dashboard:80` (IKKE localhost!)

---

**Nyd dit nye dashboard! 🎉**
