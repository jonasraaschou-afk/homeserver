# 📱 iPhone Integration Guide

Alt du kan lave med din iPhone og din homeserver!

## 🎯 Muligheder

1. **PWA App** - Installer dashboard som en app
2. **iOS Shortcuts** - Automatiser opgaver med Siri
3. **Push Notifikationer** - Få beskeder via n8n
4. **Widgets** - Homescreen widgets
5. **iCloud Sync** - Sync filer med Nextcloud
6. **Siri Integration** - Styr med stemmen

---

## 1️⃣ Installer Dashboard Som App (PWA)

Dit dashboard er nu en **Progressive Web App**! Det betyder du kan installere det som en rigtig app på din iPhone.

### Sådan Gør Du:

1. **Åbn Safari på din iPhone**
   - Gå til: `https://kobber.me` (eller `https://home.kobber.me`)

2. **Tryk på "Del" knappen** (firkant med pil op)

3. **Scroll ned og vælg "Føj til hjemmeskærm"**

4. **Giv appen et navn:** "Homeserver" eller "Kobber.me"

5. **Tryk "Tilføj"**

### Resultat:

- 🎨 App ikon på din hjemmeskærm
- 📱 Åbner i fuld skærm (ingen browser UI)
- ⚡ Hurtig adgang til alle services
- 🔄 Offline support (dashboard virker uden internet)
- 🎭 Native app-oplevelse

### Features:

- **Haptic feedback** når du trykker på tiles
- **Smooth animations** optimeret til iOS
- **Dark mode** respekterer system indstillinger
- **Safe area** support (iPhone notch)

---

## 2️⃣ iOS Shortcuts Integration

Automatiser opgaver med iOS Shortcuts app!

### Eksempel 1: Åbn n8n Med Siri

1. Åbn **Shortcuts** app på iPhone
2. Tryk **+** for ny shortcut
3. **Tilføj handling:** "Åbn URL'er"
4. **URL:** `https://n8n.kobber.me`
5. **Giv navn:** "Åbn n8n"
6. **Tilføj til Siri:** "Hey Siri, åbn n8n"

Nu kan du sige: **"Hey Siri, åbn n8n"** 🎤

### Eksempel 2: Backup Trigger

Hvis du laver en n8n webhook til at køre backup:

1. Opret workflow i n8n med webhook trigger
2. Webhook URL: `https://n8n.kobber.me/webhook/backup`
3. I Shortcuts:
   - **Handling:** "Hent indhold fra URL"
   - **URL:** `https://n8n.kobber.me/webhook/backup`
   - **Metode:** POST
4. **Giv navn:** "Kør Backup"
5. **Tilføj til Siri:** "Hey Siri, kør backup"

### Eksempel 3: Quick Actions

**Shortcut der viser alle services:**

```
1. "Vælg fra menu" handling
2. Prompt: "Hvilken service?"
3. Options:
   - n8n → Åbn https://n8n.kobber.me
   - NocoDB → Åbn https://nocodb.kobber.me
   - Nextcloud → Åbn https://cloud.kobber.me
   - Dashboard → Åbn https://kobber.me
```

### Eksempel 4: Location-Based Automation

**Åbn dashboard automatisk når du kommer hjem:**

1. Shortcuts app → **Automation** tab
2. **Create Personal Automation**
3. **Når:** "Jeg ankommer"
4. **Lokation:** Dit hjem
5. **Handling:** Åbn URL → `https://kobber.me`
6. **Deaktiver "Ask Before Running"**

Nu åbnes dashboard automatisk når du kommer hjem! 🏠

---

## 3️⃣ Push Notifikationer Via n8n

Send notifikationer til din iPhone med n8n workflows!

### Metode 1: Pushover (Anbefalet)

**Setup:**

1. **Download Pushover app** fra App Store (gratis trial, derefter $5 one-time)
2. **Opret konto:** https://pushover.net
3. **Kopier User Key** fra dashboard
4. **Opret Application** og kopier API Token

**I n8n:**

1. Opret workflow
2. Tilføj **Pushover node**
3. **Credentials:**
   - User Key: [din user key]
   - API Token: [din api token]
4. **Message:** "Din besked her"
5. **Title:** "Homeserver Alert"

**Eksempler:**

```
📊 "Backup completed successfully!"
⚠️ "Disk space below 10%"
🔔 "New file uploaded to Nextcloud"
💡 "Server restarted"
```

### Metode 2: Telegram

1. **Download Telegram** app
2. **Opret bot:** Chat med @BotFather
3. **Kopier Bot Token**
4. **Find Chat ID:** Chat med @userinfobot

**I n8n:**
- Node: **Telegram**
- Send beskeder til din chat!

### Metode 3: Email

Simpelt, men virker:
- n8n **Email node**
- Send til din iPhone email
- Modtag som iOS notifikation

---

## 4️⃣ iOS Widgets (Scriptable)

Lav hjemmeskærm widgets med **Scriptable** app!

### Setup:

1. **Download Scriptable** (gratis) fra App Store
2. Opret nyt script
3. Paste koden nedenfor

### Widget Kode - Server Status:

```javascript
// Kobber.me Server Status Widget

const widget = new ListWidget();
widget.backgroundColor = new Color("#667eea");

// Header
const header = widget.addText("🏠 Kobber.me");
header.font = Font.boldSystemFont(16);
header.textColor = Color.white();

widget.addSpacer(10);

// Services
const services = [
  { name: "n8n", url: "https://n8n.kobber.me" },
  { name: "NocoDB", url: "https://nocodb.kobber.me" },
  { name: "Nextcloud", url: "https://cloud.kobber.me" }
];

for (const service of services) {
  const row = widget.addText(`🟢 ${service.name}`);
  row.font = Font.systemFont(12);
  row.textColor = Color.white();
}

widget.addSpacer(8);

// Last updated
const time = new Date().toLocaleTimeString('da-DK', {
  hour: '2-digit',
  minute: '2-digit'
});
const updated = widget.addText(`Updated: ${time}`);
updated.font = Font.systemFont(10);
updated.textColor = new Color("#ffffff", 0.7);

// Tap to open dashboard
widget.url = "https://kobber.me";

Script.setWidget(widget);
Script.complete();
widget.presentSmall();
```

### Installation:

1. Kopier koden til Scriptable
2. Gem som "Homeserver Status"
3. Gå til iOS hjemmeskærm
4. Tryk og hold → **Tilføj Widget**
5. Vælg **Scriptable**
6. Vælg widget størrelse (Small, Medium, Large)
7. Tryk på widget → **Vælg Script** → "Homeserver Status"

**Færdig!** Nu har du et live widget på hjemmeskærmen! 📊

### Avanceret: Real-time Status Check

```javascript
// Check if services are online
async function checkService(url) {
  try {
    const req = new Request(url);
    req.timeoutInterval = 3;
    await req.load();
    return true;
  } catch {
    return false;
  }
}

// Use in widget:
const n8nOnline = await checkService("https://n8n.kobber.me");
const icon = n8nOnline ? "🟢" : "🔴";
```

---

## 5️⃣ iCloud Integration Med Nextcloud

Sync filer mellem iCloud og Nextcloud!

### Metode 1: Nextcloud iOS App

1. **Download Nextcloud app** fra App Store
2. **Server:** `https://cloud.kobber.me`
3. **Login** med dine credentials fra .env
4. **Enable "Auto Upload"** for billeder
5. **Files app integration** aktiveres automatisk

**Nu kan du:**
- 📸 Auto-upload billeder til Nextcloud
- 📁 Browse Nextcloud filer i iOS Files app
- 🔄 Offline sync vigtige filer
- ✍️ Rediger dokumenter direkte

### Metode 2: n8n Automation

**Auto-backup iPhone billeder:**

n8n workflow:
1. **Webhook trigger** → Fra iOS Shortcuts
2. **Upload to Nextcloud** → Gem billedet
3. **Send notification** → Bekræftelse til iPhone

iOS Shortcut:
1. **Tag nyeste billede**
2. **Send til n8n webhook**
3. **Få bekræftelse**

---

## 6️⃣ Siri Kommandoer

Opret custom Siri kommandoer for alt!

### Eksempler:

**"Hey Siri, server status"**
→ Åbner dashboard med status

**"Hey Siri, kør backup"**
→ Trigger n8n backup workflow

**"Hey Siri, upload billede til server"**
→ Tag billede og upload til Nextcloud

**"Hey Siri, hvad er min disk usage"**
→ n8n webhook henter disk stats og viser i notification

**"Hey Siri, start workflow"**
→ Trigger specifik n8n workflow

### Setup i Shortcuts:

1. Opret shortcut med handling
2. **Tryk på shortcut navn** → Info (i)
3. **"Add to Siri"**
4. **Indtast din phrase**
5. **Done!**

---

## 7️⃣ Lock Screen Widgets (iOS 16+)

Hvis du har iOS 16 eller nyere:

### Custom Lock Screen Widget:

1. **Tryk og hold** på lock screen
2. **Tilpas** → Vælg lock screen
3. **Tilføj Widget**
4. **Scriptable** → Vælg dit homeserver script

Nu ser du server status lige på lock screen! 🔒

---

## 8️⃣ Focus Modes Integration

**Automatisk åbn services baseret på Focus Mode:**

### Eksempel: "Work" Focus

Når "Work" focus aktiveres:
1. Åbn n8n automatisk
2. Send notification: "Work mode active"
3. Deaktiver sociale medier

### Setup:

1. **Indstillinger** → **Focus** → **Work**
2. **Automation:**
   - When entering: Run shortcut "Open n8n"
   - When exiting: Run shortcut "Close apps"

---

## 9️⃣ Share Sheet Integration

Del direkte til dine services!

### Del Til Nextcloud:

1. På en webside/billede → Tryk **Del**
2. **Shortcuts** → Vælg "Upload til Nextcloud"
3. Filen uploades automatisk

### Setup:

Opret shortcut:
1. **Input:** Share Sheet
2. **Get URLs from Input**
3. **Send til n8n webhook** (med URL)
4. n8n downloader og gemmer i Nextcloud

---

## 🔟 Apple Watch Support

Hvis du har Apple Watch:

### Quick Actions:

1. Opret shortcuts til Apple Watch
2. **"Trigger backup"** → Tryk på ur
3. **"Check status"** → Se på ur
4. **"Open dashboard"** → Opens på iPhone

### Setup:

Shortcuts automatisk syncer til Apple Watch hvis:
- De er simple (max 2-3 actions)
- Tilføjet til Siri

---

## 💡 Mere Avancerede Ideer

### 1. Morning Routine Automation

**Når alarm slukkes:**
1. Åbn homeserver dashboard
2. Vis dagens opgaver fra NocoDB
3. Tjek backup status
4. Send "Good morning" til n8n

### 2. Battery Warning

**Når iPhone batteri < 20%:**
1. n8n gemmer position via webhook
2. Sender notification til andre enheder
3. Logger i database

### 3. Photo Library Backup

**Hver nat kl. 03:00:**
1. Shortcuts checker nye billeder
2. Uploader til Nextcloud
3. Sender rapport næste morgen

### 4. Server Health Monitor

**Scriptable widget der viser:**
- CPU usage
- RAM usage
- Disk space
- Service status
- Uptime

---

## 🎯 Quick Start Checklist

- [ ] Installer dashboard som PWA app
- [ ] Opret "Åbn n8n" Siri shortcut
- [ ] Download Nextcloud app
- [ ] Opret Scriptable widget
- [ ] Setup Pushover for notifikationer
- [ ] Lav "Coming home" automation
- [ ] Tilføj shortcuts til lock screen
- [ ] Test Share Sheet upload

---

## 📚 Nyttige Apps

**Gratis:**
- **Shortcuts** (built-in) - Automatisering
- **Scriptable** - Widgets og scripting
- **Nextcloud** - File sync
- **Telegram** - Notifikationer (gratis)

**Betalt:**
- **Pushover** ($5 one-time) - Best notifikationer
- **Toolbox Pro** (subscription) - Avancerede shortcut actions
- **Data Jar** (gratis) - Persistent data til shortcuts

---

## 🛠 Troubleshooting

### PWA App virker ikke
- Brug Safari (IKKE Chrome!)
- Tjek at HTTPS virker (Cloudflare Tunnel)
- Hard refresh: Hold power + volume ned

### Shortcuts timeout
- Øg timeout i Shortcuts settings
- Tjek netværksforbindelse
- Brug webhook endpoints (hurtigere)

### Widgets opdaterer ikke
- Scriptable har 15 min refresh limit
- Tryk på widget for manual refresh
- Brug Background Refresh i iOS settings

---

## 💬 Feedback og Ideer

Har du flere ideer til iPhone integration?

Overvej at dele dem i GitHub issues eller diskussioner!

---

**Nyd din homeserver på iPhone! 📱🚀**
