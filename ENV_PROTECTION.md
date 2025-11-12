# .env Fil Beskyttelse - Sikkerhedsguide

## ✅ Din .env Fil Er Allerede Beskyttet!

Din `.env` fil med passwords og secrets er **automatisk beskyttet** på flere måder:

### 1️⃣ Git Ignore

`.env` filen er i `.gitignore`, hvilket betyder:
- ❌ Den bliver **aldrig** committet til GitHub
- ❌ Den bliver **aldrig** pushet til remote repository
- ✅ Kun `.env.example` (uden passwords) er i GitHub

Verificer:
```bash
cat .gitignore | grep .env
# Output: .env
```

### 2️⃣ Auto-Update Script Beskyttelse

`auto-update.sh` scriptet **bevarer automatisk** din `.env` fil:

```bash
# Fra auto-update.sh linje 42-48:
if ! git diff-index --quiet HEAD --; then
    log "Gemmer lokale ændringer..."
    git stash push -m "Auto-stash før update $(date)"
    STASHED=true
fi
```

Dette betyder:
- ✅ Lokale ændringer (inkl. .env) bliver stashed
- ✅ GitHub ændringer pulles
- ✅ Lokale ændringer merges tilbage

### 3️⃣ Deploy Script Beskyttelse

`deploy.sh` scriptet tjekker om `.env` eksisterer:

```bash
if [ ! -f .env ]; then
    echo "⚠️  .env fil ikke fundet"
    cp .env.example .env
    echo "⚠️  VIGTIGT: Rediger .env filen!"
    exit 1
fi
```

## 🔒 Best Practices

### DO ✅

1. **Behold .env lokalt**
   ```bash
   # .env er kun på din Mac mini
   # Aldrig i GitHub
   ```

2. **Backup .env sikkert**
   ```bash
   # Backup til ekstern disk eller password manager
   cp .env .env.backup

   # Eller krypter backup
   openssl enc -aes-256-cbc -salt -in .env -out .env.backup.enc
   ```

3. **Opdater .env.example**
   Hvis du tilføjer nye variable:
   ```bash
   # Tilføj til .env.example (uden rigtige værdier!)
   echo "NEW_VAR=example-value-here" >> .env.example
   git add .env.example
   git commit -m "Add NEW_VAR to env template"
   ```

4. **Brug stærke passwords**
   ```bash
   # Generer sikre passwords
   openssl rand -base64 32
   ```

### DON'T ❌

1. **Commit aldrig .env**
   ```bash
   # ALDRIG gør dette:
   git add .env  # ❌ FARLIGT!
   ```

2. **Del aldrig .env**
   - Aldrig send via email
   - Aldrig del i chat
   - Aldrig upload til cloud sync (Dropbox, iCloud)

3. **Hardcode aldrig secrets**
   ```bash
   # I kode - ALDRIG:
   password = "minPassword123"  # ❌ FARLIGT!

   # Brug altid environment variables:
   password = os.getenv("PASSWORD")  # ✅ GODT!
   ```

## 🔍 Verificer Beskyttelse

### Tjek 1: .env er i .gitignore

```bash
cd ~/homeserver
cat .gitignore | grep -E "^\.env$"
# Skal vise: .env
```

### Tjek 2: .env er ikke i Git

```bash
git ls-files | grep ".env"
# Skal IKKE vise .env (kun .env.example)
```

### Tjek 3: .env er lokalt

```bash
ls -la .env
# Skal vise filen lokalt
```

### Tjek 4: GitHub har ikke .env

Gå til: https://github.com/jonasraaschou-afk/homeserver

Du skal **IKKE** kunne se `.env` filen der!

## 🆘 Nødsituationer

### "Jeg committede ved en fejl .env til Git!"

**STOP! Gør dette NU:**

```bash
# 1. Fjern fra staging
git reset HEAD .env

# 2. Hvis allerede committet (MEN IKKE pushed):
git reset --soft HEAD~1  # Undo sidste commit

# 3. Hvis allerede pushed til GitHub:
# ⚠️ Du skal rotere ALLE passwords!
# Følg "Password Rotation Guide" nedenfor
```

### Password Rotation Guide

Hvis .env ved en fejl er blevet exposed:

1. **Skift alle passwords øjeblikkeligt**
   ```bash
   nano .env
   # Skift:
   # - POSTGRES_PASSWORD
   # - N8N_BASIC_AUTH_PASSWORD
   # - NEXTCLOUD_ADMIN_PASSWORD
   # - NOCODB_JWT_SECRET
   # - CLOUDFLARE_TUNNEL_TOKEN (opret ny tunnel!)
   ```

2. **Genstart alle services**
   ```bash
   docker-compose down -v  # ⚠️ Sletter database!
   docker-compose up -d
   ```

3. **Verificer ny sikkerhed**
   ```bash
   # Tjek GitHub history for .env
   # Overvej at gøre repo privat
   # Ændr GitHub credentials hvis nødvendigt
   ```

## 📋 Sikkerhedstjekliste

- [ ] `.env` er i `.gitignore`
- [ ] `.env` er IKKE i Git history
- [ ] `.env` har stærke passwords (min. 20 tegn)
- [ ] `.env` er backupet sikkert (krypteret)
- [ ] Kun du har adgang til `.env` filen
- [ ] Services bruger environment variables (ikke hardcoded)
- [ ] `.env.example` har IKKE rigtige passwords
- [ ] GitHub repository er privat (eller .env aldrig committet)

## 🔐 Avanceret: Encrypt .env

For ekstra sikkerhed, krypter din `.env` backup:

```bash
# Krypter
openssl enc -aes-256-cbc -salt -in .env -out .env.encrypted -pbkdf2

# Dekrypter senere
openssl enc -d -aes-256-cbc -in .env.encrypted -out .env -pbkdf2
```

Gem krypteringsnøglen i en password manager!

## 💡 Alternative Løsninger

### 1. Docker Secrets (Swarm mode)

```yaml
secrets:
  postgres_password:
    file: ./secrets/postgres_password.txt
```

### 2. HashiCorp Vault

Enterprise løsning til secret management.

### 3. Password Managers

Gem .env indhold i:
- 1Password
- Bitwarden
- LastPass

## 📚 Læs Mere

- [12 Factor App - Config](https://12factor.net/config)
- [OWASP Secrets Management](https://owasp.org/www-community/vulnerabilities/Sensitive_Data_Exposure)
- [Git Secret](https://git-secret.io/)

---

## ✅ TL;DR - Quick Facts

1. ✅ `.env` er allerede beskyttet via `.gitignore`
2. ✅ Auto-update script bevarer din lokale `.env`
3. ✅ GitHub har ALDRIG adgang til din `.env`
4. ✅ Kun `.env.example` (uden secrets) er i Git
5. ⚠️ Backup `.env` sikkert (krypteret)
6. ⚠️ Rotér passwords hvis exposed

**Du er sikker! 🔒**
