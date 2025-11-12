# Automatisk Deployment Guide

Der er **to måder** at sætte automatisk deployment op til din Mac mini. Vælg den der passer bedst til dine behov:

## 🎯 Metode 1: Auto-Update Script (Anbefalet - Simpel)

**Fordele:**
- ✅ Meget simpel at sætte op (2 minutter)
- ✅ Kører automatisk i baggrunden på din Mac mini
- ✅ Checker GitHub hvert 5. minut
- ✅ Opdaterer kun hvis der er ændringer
- ✅ Bevarer din `.env` fil

**Ulemper:**
- ⚠️ Kræver at Mac mini kører hele tiden
- ⚠️ Max 5 minutters delay før opdatering

### Setup (Metode 1)

```bash
cd ~/homeserver
./setup-auto-update.sh
```

**Det er det! 🎉**

Systemet checker nu automatisk GitHub hvert 5. minut og opdaterer hvis nødvendigt.

### Se Logs

```bash
# Se live logs
tail -f ~/homeserver/auto-update.log

# Se de seneste linjer
tail -20 ~/homeserver/auto-update.log
```

### Test Det

1. Lav en ændring i GitHub (f.eks. rediger README.md)
2. Commit og push ændringen
3. Vent 5 minutter (eller kør manuelt: `./auto-update.sh`)
4. Tjek logs for at se opdateringen

### Stop/Start Auto-Update

```bash
# Stop
launchctl unload ~/Library/LaunchAgents/com.homeserver.auto-update.plist

# Start igen
launchctl load ~/Library/LaunchAgents/com.homeserver.auto-update.plist

# Se status
launchctl list | grep homeserver
```

---

## 🚀 Metode 2: GitHub Actions (Avanceret)

**Fordele:**
- ✅ Øjeblikkelig deployment ved push til GitHub
- ✅ Kan køre tests før deployment
- ✅ Kan sende notifikationer ved fejl
- ✅ Deployment historik i GitHub

**Ulemper:**
- ⚠️ Mere kompleks setup
- ⚠️ Kræver GitHub Actions runner på Mac mini

### Setup (Metode 2)

#### 1. Installer GitHub Actions Runner på Mac mini

```bash
# Lav en runner directory
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download runner (Tjek GitHub for seneste version)
curl -o actions-runner-osx-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Udpak
tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz
```

#### 2. Konfigurer Runner

1. Gå til dit GitHub repository
2. Klik på **"Settings"** → **"Actions"** → **"Runners"**
3. Klik på **"New self-hosted runner"**
4. Vælg **"macOS"** som operating system
5. Kopier og kør configuration kommandoerne:

```bash
# Eksempel (brug kommandoerne fra GitHub):
./config.sh --url https://github.com/jonasraaschou-afk/homeserver --token DIN_TOKEN_HER

# Når den spørger:
# - Enter name of runner: mac-mini-homeserver
# - Enter work folder: _work (standard)
```

#### 3. Installer Runner som Service

```bash
# Install service
cd ~/actions-runner
./svc.sh install

# Start service
./svc.sh start

# Tjek status
./svc.sh status
```

#### 4. Verificer

Gå til GitHub repository → Settings → Actions → Runners

Du skulle se din runner som **"Idle"** (grøn).

#### 5. Test GitHub Actions Workflow

GitHub Actions workflow er allerede konfigureret i `.github/workflows/deploy.yml`.

**Test det:**

1. Lav en lille ændring i en fil
2. Commit og push:
   ```bash
   echo "# Test" >> README.md
   git add README.md
   git commit -m "Test auto-deployment"
   git push
   ```
3. Gå til GitHub repository → **"Actions"** tab
4. Se deployment køre live! 🎉

### GitHub Actions Workflow Filer

Din workflow er allerede sat op i `.github/workflows/deploy.yml`:

```yaml
name: Deploy til Mac Mini Homeserver

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Pull nye images
        run: docker-compose pull

      - name: Genstart services
        run: docker-compose up -d --force-recreate
```

**Det betyder:**
- Kører automatisk ved push til `main` branch
- Kan også triggers manuelt fra Actions tab
- Opdaterer Docker images og genstarter services

---

## 📊 Sammenligning

| Feature | Auto-Update Script | GitHub Actions |
|---------|-------------------|----------------|
| **Setup tid** | 2 minutter | 15-20 minutter |
| **Kompleksitet** | Meget simpel | Middel |
| **Deployment tid** | 0-5 minutter | Øjeblikkelig |
| **Historik** | Logs lokalt | GitHub UI |
| **Notifikationer** | macOS notifikation | GitHub/Email/Slack |
| **Tests før deploy** | ❌ | ✅ |
| **Rollback** | Manuel | Manuel/Automatisk |

---

## 🎯 Hvilken Metode Skal Jeg Vælge?

### Vælg **Auto-Update Script** hvis:
- ✅ Du vil have noget simpelt der bare virker
- ✅ 5 minutters delay er acceptabel
- ✅ Du er ny til GitHub Actions
- ✅ Din Mac mini kører 24/7

### Vælg **GitHub Actions** hvis:
- ✅ Du vil have øjeblikkelig deployment
- ✅ Du vil køre tests før deployment
- ✅ Du vil have deployment historik i GitHub
- ✅ Du planlægger flere udviklere på projektet

---

## 🔄 Kan Jeg Bruge Begge?

**Nej** - du bør kun bruge én metode ad gangen for at undgå konflikter.

Hvis du starter med Auto-Update Script og senere vil skifte til GitHub Actions:

```bash
# Stop auto-update
launchctl unload ~/Library/LaunchAgents/com.homeserver.auto-update.plist

# Setup GitHub Actions runner (se ovenfor)
```

---

## 🧪 Test Din Opsætning

### Test Auto-Update Script:

```bash
# Kør manuelt
cd ~/homeserver
./auto-update.sh

# Se output i real-time
tail -f auto-update.log
```

### Test GitHub Actions:

```bash
# Lav en test ændring
echo "# Test $(date)" >> README.md
git add README.md
git commit -m "Test deployment"
git push

# Gå til GitHub og se Actions tab
```

---

## 🛠 Troubleshooting

### Auto-Update Script Problemer

**Problem: "Permission denied"**
```bash
chmod +x auto-update.sh setup-auto-update.sh
```

**Problem: Script kører ikke automatisk**
```bash
# Tjek LaunchAgent status
launchctl list | grep homeserver

# Se fejl logs
cat ~/homeserver/auto-update.error.log

# Genstart service
launchctl unload ~/Library/LaunchAgents/com.homeserver.auto-update.plist
launchctl load ~/Library/LaunchAgents/com.homeserver.auto-update.plist
```

**Problem: Docker opdaterer ikke**
```bash
# Tjek logs
tail -50 ~/homeserver/auto-update.log

# Test Docker manuelt
docker-compose ps
```

### GitHub Actions Problemer

**Problem: Runner offline**
```bash
cd ~/actions-runner
./svc.sh status

# Genstart hvis nødvendigt
./svc.sh restart
```

**Problem: Workflow fejler**
- Gå til GitHub Actions tab
- Klik på den fejlede workflow
- Se logs for fejlmeddelelser

**Problem: Runner kan ikke finde docker-compose**
Tilføj PATH til runner:
```bash
cd ~/actions-runner
nano .env

# Tilføj:
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

---

## 📝 Best Practices

1. **Test altid ændringer lokalt først**
   ```bash
   docker-compose config  # Valider syntax
   docker-compose up -d   # Test lokalt
   ```

2. **Backup før større opdateringer**
   ```bash
   ./backup.sh
   ```

3. **Overvåg logs efter deployment**
   ```bash
   docker-compose logs -f
   ```

4. **Hold `.env` opdateret**
   - Auto-update bevarer automatisk din `.env`
   - Tjek `.env.example` for nye variable

5. **Test rollback procedure**
   ```bash
   git log  # Find forrige commit
   git checkout <commit-hash>
   ./deploy.sh
   ```

---

## 💡 Pro Tips

1. **Notifikationer ved fejl**

   Tilføj til `auto-update.sh`:
   ```bash
   # Send fejl notifikation
   if [ $? -ne 0 ]; then
       osascript -e 'display notification "Deployment fejlede!" with title "Homeserver" sound name "Basso"'
   fi
   ```

2. **Slack notifikationer**

   Tilføj webhook til at sende til Slack ved deployment.

3. **Health checks efter deployment**

   Tilføj til scripts:
   ```bash
   # Vent og tjek at services er healthy
   sleep 30
   docker-compose ps | grep -q "unhealthy" && echo "ADVARSEL: Nogle services er unhealthy!"
   ```

4. **Deploy kun bestemte services**

   I stedet for at genstarte alt:
   ```bash
   docker-compose up -d --no-deps --build <service-navn>
   ```

---

## 🎓 Lær Mere

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [macOS LaunchAgent Guide](https://www.launchd.info/)

---

**Happy Automating! 🚀**
