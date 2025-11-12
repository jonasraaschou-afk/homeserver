# iOS Shortcuts - Import Instruktioner

Her er færdige shortcuts du kan importere til din iPhone!

## 📲 Hurtig Installation

### Metode 1: Manuel Oprettelse (Anbefalet)

De følgende shortcuts kan du oprette manuelt i Shortcuts app. Det tager kun 2-3 minutter pr. shortcut.

---

## 🚀 Shortcut 1: Åbn Dashboard

**Navn:** "Åbn Dashboard" eller "Open Homeserver"

**Actions:**
1. Åbn URL: `https://home.kobber.me`

**Siri:** "Hey Siri, åbn dashboard" eller "Hey Siri, åbn homeserver"

---

## ⚡ Shortcut 2: Åbn n8n

**Navn:** "Åbn n8n"

**Actions:**
1. Åbn URL: `https://n8n.kobber.me`

**Siri:** "Hey Siri, åbn n8n" eller "Hey Siri, automation"

---

## 📊 Shortcut 3: Åbn NocoDB

**Navn:** "Åbn NocoDB"

**Actions:**
1. Åbn URL: `https://nocodb.kobber.me`

**Siri:** "Hey Siri, åbn database"

---

## ☁️ Shortcut 4: Åbn Nextcloud

**Navn:** "Åbn Cloud" eller "Åbn Filer"

**Actions:**
1. Åbn URL: `https://cloud.kobber.me`

**Siri:** "Hey Siri, åbn cloud" eller "Hey Siri, mine filer"

---

## 🎯 Shortcut 5: Service Menu

**Navn:** "Homeserver Menu"

**Actions:**
1. **Vælg fra menu** med prompt: "Hvilken service?"
   - **n8n**
     - Åbn URL: `https://n8n.kobber.me`
   - **NocoDB**
     - Åbn URL: `https://nocodb.kobber.me`
   - **Nextcloud**
     - Åbn URL: `https://cloud.kobber.me`
   - **Dashboard**
     - Åbn URL: `https://home.kobber.me`

**Siri:** "Hey Siri, homeserver"

---

## 📸 Shortcut 6: Upload Billede til Server

**Navn:** "Upload til Server"

**Actions:**
1. **Vælg Billeder** (max 1)
2. **Basis64 Encode** Billeder
3. **Hent indhold fra URL**
   - URL: `https://n8n.kobber.me/webhook/upload-image`
   - Metode: POST
   - Request Body: JSON
   ```json
   {
     "image": "Basis64 Encoded Image",
     "timestamp": "Current Date"
   }
   ```
4. **Vis Notifikation:** "Billede uploaded!"

**Note:** Kræver n8n webhook - se n8n setup sektion nedenfor.

**Brug:** Del billede → Shortcuts → "Upload til Server"

---

## 🏠 Shortcut 7: Kom Hjem Automation

**Type:** Personal Automation (IKKE shortcut)

**Trigger:** Når du ankommer (ved dit hjem)

**Actions:**
1. **Vent** 5 sekunder
2. **Åbn URL:** `https://home.kobber.me`
3. **Vis Notifikation:** "Velkommen hjem! Dashboard åbnet."

**Setup:**
1. Shortcuts app → **Automation** tab
2. **+** → **Create Personal Automation**
3. **Arrive** → Vælg din hjemme-lokation
4. Tilføj actions ovenfor
5. **Deaktiver "Ask Before Running"**

---

## 🔋 Shortcut 8: Low Battery Alert

**Type:** Personal Automation

**Trigger:** Når batteri når 20%

**Actions:**
1. **Hent indhold fra URL**
   - URL: `https://n8n.kobber.me/webhook/battery-low`
   - Metode: POST
   - Body:
   ```json
   {
     "battery": "Battery Level",
     "device": "iPhone",
     "location": "Current Location"
   }
   ```

**Note:** Logger batteri status i n8n - nyttigt til at tracke forbrug patterns.

---

## ⏰ Shortcut 9: Morgen Rutine

**Navn:** "Morgen Rutine"

**Actions:**
1. **Vis Notifikation:** "God morgen! 🌅"
2. **Vent** 2 sekunder
3. **Åbn URL:** `https://home.kobber.me`
4. **Vent** 3 sekunder
5. **Hent indhold fra URL:** `https://n8n.kobber.me/webhook/morning-routine`
   - Metode: POST
6. **Vis resultat** (fra n8n - dagens opgaver fx)

**Automation:** Trigger når alarm stoppes (iOS Automation)

---

## 🌙 Shortcut 10: Nat Backup

**Type:** Personal Automation

**Trigger:** Kl. 03:00 hver nat

**Actions:**
1. **Find Billeder** hvor:
   - Creation Date er efter "Yesterday"
2. **Hvis** Billeder count > 0:
   - **For hvert** billede:
     - Upload til Nextcloud via n8n webhook
3. **Hent indhold fra URL:** `https://n8n.kobber.me/webhook/night-backup-complete`
4. **Gem resultat** til fil (backup log)

---

## 🎮 Shortcut 11: Focus Mode Integration

### Work Mode Starter

**Type:** Automation
**Trigger:** Når "Work" focus aktiveres

**Actions:**
1. **Vis Notifikation:** "Work mode aktiv 💼"
2. **Åbn URL:** `https://n8n.kobber.me`
3. **Hent indhold:** `https://n8n.kobber.me/webhook/work-mode-start`

### Work Mode Stopper

**Type:** Automation
**Trigger:** Når "Work" focus deaktiveres

**Actions:**
1. **Hent indhold:** `https://n8n.kobber.me/webhook/work-mode-end`
2. **Vis Notifikation:** "Work mode slut! God weekend 🎉"

---

## 📤 Shortcut 12: Del Link til Server

**Navn:** "Gem Link på Server"

**Actions:**
1. **Modtag input** fra Share Sheet (URLs)
2. **Hent indhold fra URL:**
   - URL: `https://n8n.kobber.me/webhook/save-link`
   - Metode: POST
   - Body:
   ```json
   {
     "url": "Shortcut Input",
     "saved_at": "Current Date",
     "device": "iPhone"
   }
   ```
3. **Vis Notifikation:** "Link gemt!"

**Brug:** Safari → Del → Shortcuts → "Gem Link"

---

## 🛠 n8n Webhook Setup

For at bruge shortcuts med n8n webhooks, skal du oprette workflows:

### Basic Webhook Node Setup:

1. I n8n → **New Workflow**
2. Tilføj **Webhook** node
3. **HTTP Method:** POST
4. **Path:** `/webhook/dit-endpoint-navn`
5. **Response Mode:** On Response Receipt
6. Test URL: `https://n8n.kobber.me/webhook-test/dit-endpoint-navn`
7. Production URL: `https://n8n.kobber.me/webhook/dit-endpoint-navn`

### Eksempel: Upload Image Webhook

```
Webhook (POST /webhook/upload-image)
  ↓
Set (Extract base64 data)
  ↓
Move Binary Data (Convert to file)
  ↓
Nextcloud (Upload to folder)
  ↓
Respond to Webhook (Success message)
```

### Eksempel: Battery Low Webhook

```
Webhook (POST /webhook/battery-low)
  ↓
Set (Format data)
  ↓
PostgreSQL (Log to database)
  ↓
Pushover (Send notification)
  ↓
Respond to Webhook
```

---

## 📋 Installation Checklist

- [ ] Opret "Åbn Dashboard" shortcut
- [ ] Opret "Åbn n8n" shortcut
- [ ] Opret "Homeserver Menu" shortcut
- [ ] Setup "Kom Hjem" automation
- [ ] Tilføj Siri phrases til alle shortcuts
- [ ] Test hver shortcut
- [ ] Setup n8n webhooks (valgfrit)
- [ ] Opret avancerede automations (valgfrit)

---

## 💡 Tips

1. **Korte Siri phrases:** "Dashboard", "n8n", "Server" virker godt
2. **Deaktiver "Ask Before Running"** for automations
3. **Test webhooks** først med Postman eller curl
4. **Background Refresh** skal være aktiveret i iOS settings
5. **Low Power Mode** kan disable automations

---

## 🔧 Troubleshooting

### Shortcut timeout
- Øg timeout i Shortcuts settings
- Tjek internet forbindelse
- Brug hurtige endpoints

### Automation kører ikke
- Tjek "Ask Before Running" er slået fra
- Verificer location permissions
- Check Low Power Mode er slået fra

### Webhook fejler
- Test URL i Safari først
- Tjek n8n workflow er aktiveret
- Verificer HTTP method (POST/GET)

---

## 🎯 Næste Skridt

1. Start med de simple shortcuts (Åbn Dashboard, Åbn n8n)
2. Test Siri integration
3. Lav "Kom Hjem" automation
4. Eksperimenter med webhooks i n8n
5. Byg custom automations til dine behov!

---

**God fornøjelse med dine iOS shortcuts! 📱🚀**
