#!/bin/bash

# Setup script til automatisk opdatering
# Kører på macOS med LaunchAgent

set -e

echo "🚀 Opsætter automatisk opdatering fra GitHub..."

# Konfiguration
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.homeserver.auto-update"
PLIST_FILE="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"
UPDATE_INTERVAL=300  # Sekunder (300 = 5 minutter)

# Farver
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Dette script vil:${NC}"
echo "1. Oprette en macOS LaunchAgent"
echo "2. Konfigurere automatisk check hvert $((UPDATE_INTERVAL / 60)) minut"
echo "3. Auto-opdatere Docker services ved ændringer fra GitHub"
echo ""

read -p "Fortsæt? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Afbrudt"
    exit 1
fi

# Gør scripts executable
chmod +x "$CURRENT_DIR/auto-update.sh"
chmod +x "$CURRENT_DIR/deploy.sh"

# Opret LaunchAgents directory hvis den ikke eksisterer
mkdir -p "$HOME/Library/LaunchAgents"

# Opret LaunchAgent plist fil
cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>

    <key>ProgramArguments</key>
    <array>
        <string>$CURRENT_DIR/auto-update.sh</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>$UPDATE_INTERVAL</integer>

    <key>StandardOutPath</key>
    <string>$CURRENT_DIR/auto-update.log</string>

    <key>StandardErrorPath</key>
    <string>$CURRENT_DIR/auto-update.error.log</string>

    <key>WorkingDirectory</key>
    <string>$CURRENT_DIR</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>

    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo -e "${GREEN}✅ LaunchAgent oprettet: $PLIST_FILE${NC}"

# Load LaunchAgent
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo -e "${GREEN}✅ LaunchAgent aktiveret${NC}"

# Verificer
if launchctl list | grep -q "$PLIST_NAME"; then
    echo -e "${GREEN}✅ Auto-update service kører!${NC}"
else
    echo -e "${RED}❌ Kunne ikke starte service${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Automatisk opdatering er nu aktiveret!${NC}"
echo ""
echo "Serveren vil nu automatisk:"
echo "  • Checke GitHub for ændringer hvert $((UPDATE_INTERVAL / 60)) minut"
echo "  • Opdatere Docker services hvis nødvendigt"
echo "  • Logge alt til: $CURRENT_DIR/auto-update.log"
echo ""
echo "Nyttige kommandoer:"
echo "  • Se logs:           tail -f $CURRENT_DIR/auto-update.log"
echo "  • Stop auto-update:  launchctl unload $PLIST_FILE"
echo "  • Start auto-update: launchctl load $PLIST_FILE"
echo "  • Se status:         launchctl list | grep homeserver"
echo "  • Kør nu:            $CURRENT_DIR/auto-update.sh"
echo ""
echo -e "${YELLOW}💡 Tip: Test det med en ændring i GitHub og vent $((UPDATE_INTERVAL / 60)) minutter${NC}"
