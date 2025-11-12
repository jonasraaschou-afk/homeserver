# Brug Ekstern Disk til Nextcloud Data

Guide til at flytte Nextcloud data til din 1TB eksterne disk.

## 🎯 Mål

Flytte alt Nextcloud data fra Docker volumes til din eksterne disk for mere plads.

---

## 📋 Trin-for-Trin Guide

### Trin 1: Find Din Eksterne Disk

Først skal vi finde hvor din eksterne disk er mounted.

```bash
# Se alle mounted disks
df -h

# Eller se disks i /Volumes (macOS)
ls -la /Volumes/
```

**Output vil vise noget som:**
```
/dev/disk2s1    932Gi   10Gi   922Gi   2%   /Volumes/MinDisk
```

**Note:** Diskens navn kan være forskelligt - typisk noget som:
- `/Volumes/External`
- `/Volumes/Untitled`
- `/Volumes/MinDisk`
- Eller hvad du har navngivet den

---

### Trin 2: Opret Nextcloud Mappe På Ekstern Disk

```bash
# Erstat "MinDisk" med dit disk navn
DISK_NAME="MinDisk"  # ÆNDR DETTE!

# Opret mapper
sudo mkdir -p "/Volumes/$DISK_NAME/nextcloud/data"
sudo mkdir -p "/Volumes/$DISK_NAME/nextcloud/apps"
sudo mkdir -p "/Volumes/$DISK_NAME/nextcloud/config"
sudo mkdir -p "/Volumes/$DISK_NAME/nextcloud/html"

# Se strukturen
ls -la "/Volumes/$DISK_NAME/nextcloud/"
```

---

### Trin 3: Backup Eksisterende Data (Hvis Du Har Noget)

```bash
cd ~/homeserver

# Stop Nextcloud
docker-compose stop nextcloud

# Backup eksisterende data (hvis der er noget)
docker run --rm \
  -v homeserver_nextcloud_data:/source \
  -v "/Volumes/$DISK_NAME/nextcloud":/backup \
  alpine sh -c "cp -av /source/. /backup/html/"

docker run --rm \
  -v homeserver_nextcloud_data_files:/source \
  -v "/Volumes/$DISK_NAME/nextcloud":/backup \
  alpine sh -c "cp -av /source/. /backup/data/"

docker run --rm \
  -v homeserver_nextcloud_config:/source \
  -v "/Volumes/$DISK_NAME/nextcloud":/backup \
  alpine sh -c "cp -av /source/. /backup/config/"

docker run --rm \
  -v homeserver_nextcloud_apps:/source \
  -v "/Volumes/$DISK_NAME/nextcloud":/backup \
  alpine sh -c "cp -av /source/. /backup/apps/"
```

---

### Trin 4: Opdater docker-compose.yml

Åbn `docker-compose.yml`:

```bash
cd ~/homeserver
nano docker-compose.yml
```

**Find Nextcloud sektionen** og ændr `volumes`:

**FØR:**
```yaml
  nextcloud:
    image: nextcloud:latest
    container_name: homeserver-nextcloud
    restart: unless-stopped
    ports:
      - "${NEXTCLOUD_PORT:-8081}:80"
    environment:
      # ... environment variables ...
    volumes:
      - nextcloud_data:/var/www/html
      - nextcloud_apps:/var/www/html/custom_apps
      - nextcloud_config:/var/www/html/config
      - nextcloud_data_files:/var/www/html/data
```

**EFTER (erstat MinDisk med dit disk navn):**
```yaml
  nextcloud:
    image: nextcloud:latest
    container_name: homeserver-nextcloud
    restart: unless-stopped
    ports:
      - "${NEXTCLOUD_PORT:-8081}:80"
    environment:
      # ... environment variables ...
    volumes:
      - /Volumes/MinDisk/nextcloud/html:/var/www/html
      - /Volumes/MinDisk/nextcloud/apps:/var/www/html/custom_apps
      - /Volumes/MinDisk/nextcloud/config:/var/www/html/config
      - /Volumes/MinDisk/nextcloud/data:/var/www/html/data
```

**Gem:** `Ctrl+X`, `Y`, `Enter`

---

### Trin 5: Fix Permissions

Nextcloud kræver specifikke permissions:

```bash
# Set correct ownership (www-data i containeren = user 33:33)
sudo chown -R 33:33 "/Volumes/$DISK_NAME/nextcloud"

# Set correct permissions
sudo chmod -R 750 "/Volumes/$DISK_NAME/nextcloud"
```

---

### Trin 6: Start Nextcloud

```bash
cd ~/homeserver
docker-compose up -d nextcloud
```

---

### Trin 7: Verificer

```bash
# Tjek logs
docker-compose logs -f nextcloud

# Skal vise noget som:
# "Nextcloud was successfully installed"
# eller
# "Initializing finished"
```

**Test i browser:**
- Gå til: https://cloud.kobber.me
- Login med dine credentials
- Upload en testfil
- Tjek at den ligger på den eksterne disk:

```bash
ls -lh "/Volumes/$DISK_NAME/nextcloud/data/admin/files/"
```

---

## ✅ Verificer At Det Virker

```bash
# Se hvor meget plads der er brugt
du -sh "/Volumes/$DISK_NAME/nextcloud"

# Upload en fil i Nextcloud, og tjek at den dukker op:
ls -lh "/Volumes/$DISK_NAME/nextcloud/data/DINBRUGER/files/"
```

---

## 🧹 Ryd Op (Valgfrit)

Når alt virker, kan du slette de gamle Docker volumes:

```bash
# ADVARSEL: Dette sletter permanent!
# Kun hvis du er SIKKER på at alt virker!

docker volume rm homeserver_nextcloud_data
docker volume rm homeserver_nextcloud_apps
docker volume rm homeserver_nextcloud_config
docker volume rm homeserver_nextcloud_data_files
```

---

## ⚠️ Vigtige Noter

### 1. Ekstern Disk Skal Være Tilsluttet

Nextcloud virker KUN når disken er tilsluttet!

Hvis disken ikke er tilsluttet og du starter Docker:
- Nextcloud vil fejle
- Data vil ikke være tilgængelig

### 2. Disk Navn Consistency

Sørg for disken har samme navn altid:

```bash
# Tjek disk navn
diskutil list

# Omdøb disk hvis nødvendigt
diskutil rename /Volumes/GammeltNavn NytNavn
```

### 3. Auto-Mount Ved Opstart

macOS mounter automatisk eksterne disks ved opstart, så det skulle virke automatisk.

### 4. Backup Strategi

Din eksisterende `backup.sh` script vil IKKE backup den eksterne disk!

**Opdater backup.sh:**

```bash
nano ~/homeserver/backup.sh
```

Tilføj:
```bash
# Backup ekstern disk data
echo "📦 Backing up external disk data..."
tar czf "$BACKUP_FILE" \
  -C "/Volumes/$DISK_NAME" \
  nextcloud
```

---

## 🔧 Troubleshooting

### Problem: Nextcloud viser "Internal Server Error"

**Løsning:**
```bash
# Fix permissions
sudo chown -R 33:33 "/Volumes/$DISK_NAME/nextcloud"
sudo chmod -R 750 "/Volumes/$DISK_NAME/nextcloud"

# Genstart
docker-compose restart nextcloud
```

### Problem: "Permission denied" i logs

**Løsning:**
```bash
# Tjek nuværende permissions
ls -la "/Volumes/$DISK_NAME/nextcloud"

# Reset permissions
sudo chown -R 33:33 "/Volumes/$DISK_NAME/nextcloud"
```

### Problem: Disk ikke mounted

**Løsning:**
```bash
# Tjek om disk er mounted
df -h | grep MinDisk

# Hvis ikke, tjek Disk Utility app
# Eller mount manuelt
diskutil mount /dev/disk2s1
```

### Problem: Nextcloud siger "trusted domain"

**Løsning:**
```bash
docker exec -u www-data homeserver-nextcloud php occ config:system:set trusted_domains 1 --value=cloud.kobber.me
```

---

## 💡 Optimering

### APFS vs. exFAT vs. HFS+

For bedste performance med macOS:

- **APFS** (Anbefalet) - Hurtigst, macOS native
- **HFS+** - Kompatibel, lidt langsommere
- **exFAT** - Hvis du skal bruge disken med Windows også

Check format:
```bash
diskutil info /Volumes/$DISK_NAME | grep "File System"
```

Reformater til APFS (ADVARSEL: Sletter alt!):
```bash
# BACKUP FØRST!
diskutil eraseDisk APFS NextcloudData GPT /dev/disk2
```

---

## 📊 Plads Overvågning

Se hvor meget plads Nextcloud bruger:

```bash
# Total størrelse
du -sh "/Volumes/$DISK_NAME/nextcloud"

# Per bruger
du -sh "/Volumes/$DISK_NAME/nextcloud/data/"*

# Største filer
find "/Volumes/$DISK_NAME/nextcloud/data" -type f -exec du -h {} + | sort -rh | head -20
```

---

## 🎯 Quick Reference

**Disk Navn:**
```bash
export DISK_NAME="MinDisk"  # Ændr til dit disk navn
```

**Nextcloud Data Sti:**
```
/Volumes/$DISK_NAME/nextcloud/
├── html/          (Nextcloud installation)
├── apps/          (Custom apps)
├── config/        (Configuration)
└── data/          (User files - DET STORE!)
    └── admin/
        └── files/ (Dine filer her!)
```

**Genstart Nextcloud:**
```bash
docker-compose restart nextcloud
```

**Se logs:**
```bash
docker-compose logs -f nextcloud
```

**Fix permissions:**
```bash
sudo chown -R 33:33 "/Volumes/$DISK_NAME/nextcloud"
```

---

**Held og lykke med din 1TB cloud! ☁️📦**
