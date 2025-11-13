# 📅 Google Calendar Integration Guide

Sådan tilslutter du din Google Calendar til dashboard'et.

## 🎯 Hvad Du Får

- 📅 Se dine Google Calendar events direkte i dashboard
- 📱 Virker på desktop, iPhone, iPad
- 🔄 Altid opdateret (live sync)
- 🎨 Flot Apple liquid glass design

---

## 🚀 Quick Setup (3 minutter)

### Metode 1: Via Dashboard (Nemmest)

1. **Åbn dashboard:** https://home.kobber.me

2. **Klik på "Tilslut Google Calendar"** knappen

3. **Følg instruktionerne** i pop-up

4. **Paste din kalender URL/ID**

5. **Færdig!** 🎉 Kalenderen vises nu i dashboard

---

### Metode 2: Manuel Setup

#### Trin 1: Find Din Google Calendar ID

1. Gå til **Google Calendar:** https://calendar.google.com

2. Klik på **⚙️ Settings** (tandhjul)

3. Vælg din kalender i venstre menu

4. Scroll ned til **"Integrate calendar"**

5. Kopier **"Calendar ID"** (f.eks. `din-email@gmail.com`)

#### Trin 2: Eller Gør Kalenderen Offentlig (Hvis Du Vil Dele)

**Kun hvis du vil dele kalenderen:**

1. Samme Settings side
2. Find **"Access permissions"**
3. Enable **"Make available to public"**
4. Kopier **"Public URL to this calendar"**

**OBS:** Dette gør kalenderen synlig for alle med linket!

#### Trin 3: Tilføj til Dashboard

1. Åbn https://home.kobber.me
2. Klik **"Tilslut Google Calendar"**
3. Paste Calendar ID eller URL
4. Klik OK

---

## 🔐 Privat Kalender (Anbefalet)

### For at holde din kalender privat:

**IKKE gør den offentlig!** Brug i stedet en af disse metoder:

### Option A: Secret URL (Bedste Balance)

1. Google Calendar Settings → Din kalender
2. Find **"Secret address in iCal format"**
3. Kopier den **secret URL**
4. Paste i dashboard

**Fordel:** Privat men kan deles via secret link
**Ulempe:** Kan ikke altid embedes direkte

### Option B: Brug Din Email Som ID

Hvis det er din primære kalender:
- Bare brug din Gmail adresse: `din@gmail.com`
- Fungerer hvis kalenderen er sat til "private"

---

## 🎨 Kalender Visning

Dashboard viser kalenderen i:
- **Agenda view** - Liste af kommende events
- **Dark theme** - Matcher dashboard design
- **Compact mode** - Passer perfekt i liquid glass card

---

## 📱 På iPhone/iPad

1. Åbn dashboard som PWA app (hvis ikke gjort)
2. Kalenderen vises perfekt på mobil
3. Swipe/scroll i kalenderen
4. Klik på events for detaljer

---

## 🔄 Synkronisering

- **Live sync:** Ændringer i Google Calendar vises med det samme
- **Auto-refresh:** Kalenderen opdaterer automatisk
- **Offline:** Cached i PWA når du er offline

---

## 🎯 Pro Tips

### Flere Kalendere

Vil du vise flere kalendere?

1. Opret en **samlet visning** i Google Calendar
2. Eksporter/del den samlede kalender
3. Brug dens ID i dashboard

### Custom Farver

Kalenderen bruger automatisk dit dashboard tema:
- Dark mode = mørk kalender
- Light mode = lys kalender

### Integration Med n8n

Lav workflows baseret på kalender events:
- Reminder før møder
- Auto-opdater NocoDB med tasks
- Sync til Nextcloud

---

## 🛠 Troubleshooting

### "Kan ikke vise kalender"

**Løsning 1:** Tjek at kalender ID er korrekt
```
Skal være: din@gmail.com
IKKE: https://calendar.google.com/calendar/...
```

**Løsning 2:** Gør kalenderen offentlig (settings)

**Løsning 3:** Brug secret iCal URL i stedet

### Kalenderen viser ikke events

- Tjek at der faktisk er events i kalenderen
- Verificer tidszonen er korrekt (Europe/Copenhagen)
- Hard refresh dashboard (Cmd+Shift+R)

### "Access Denied"

Kalender er private. Du skal:
1. Gøre den offentlig, ELLER
2. Bruge secret URL

---

## 🔒 Sikkerhed

### Offentlig Kalender
- ✅ Nem at dele
- ⚠️ Alle med linket kan se events
- ⚠️ Brug KUN hvis du vil dele

### Privat Kalender
- ✅ Kun du kan se
- ✅ Mere sikkert
- ⚠️ Kan kræve secret URL

### Secret URL
- ✅ Privat men kan deles
- ✅ Kan revoke (disable) hvis nødvendigt
- ✅ God balance

**Min anbefaling:** Brug secret URL!

---

## 💡 Avanceret: Multiple Calendars

### Vis Flere Kalendere Samtidig

Google Calendar kan kombinere flere kalendere i én visning:

1. I Google Calendar web
2. Vælg alle kalendere du vil se
3. Settings → Integrate calendar
4. Kopier URL for den kombinerede visning

Eller brug Calendar ID separeret med komma:
```
cal1@gmail.com,cal2@gmail.com
```

---

## 🎨 Customization

### Ændr Kalender View

Dashboard bruger **Agenda mode** som default.

For at ændre til Month/Week view, rediger URL i koden:
```javascript
// I dashboard/index.html, find:
mode=AGENDA

// Ændr til:
mode=WEEK    // Uge visning
mode=MONTH   // Måned visning
```

### Ændr Farve

```javascript
// Find:
bgcolor=%23000000&color=%23007AFF

// Ændr farver til hex codes
```

---

## 📚 Links

- [Google Calendar Help](https://support.google.com/calendar)
- [Embed Calendar Guide](https://support.google.com/calendar/answer/41207)
- [Calendar Sharing](https://support.google.com/calendar/answer/37082)

---

## ✅ Quick Reference

**Find Calendar ID:**
Settings → Din kalender → Integrate calendar → Calendar ID

**Secret URL:**
Settings → Din kalender → Secret address in iCal format

**Offentlig URL:**
Settings → Din kalender → Access permissions → Make public

**Embed Settings:**
- Timezone: Europe/Copenhagen
- Mode: AGENDA (eller WEEK/MONTH)
- Theme: Dark

---

**Nyd din kalender integration! 📅✨**
