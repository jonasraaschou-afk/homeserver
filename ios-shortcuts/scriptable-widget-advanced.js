// Avanceret Server Status Widget Med Real-time Checks
// Kræver internet forbindelse for at checke status

const widget = new ListWidget();

// Gradient background
const gradient = new LinearGradient();
gradient.colors = [new Color("#667eea"), new Color("#764ba2")];
gradient.locations = [0, 1];
widget.backgroundGradient = gradient;
widget.setPadding(16, 16, 16, 16);

// Header
const header = widget.addText("🏠 Kobber.me");
header.font = Font.boldSystemFont(18);
header.textColor = Color.white();

widget.addSpacer(12);

// Services to check
const services = [
  { name: "Dashboard", url: "https://home.kobber.me", emoji: "🏠" },
  { name: "n8n", url: "https://n8n.kobber.me", emoji: "⚡" },
  { name: "NocoDB", url: "https://nocodb.kobber.me", emoji: "📊" },
  { name: "Nextcloud", url: "https://cloud.kobber.me", emoji: "☁️" }
];

// Check service status
async function checkService(url) {
  try {
    const req = new Request(url);
    req.timeoutInterval = 3;
    await req.loadString();
    return true;
  } catch (e) {
    return false;
  }
}

// Check all services
for (const service of services) {
  const isOnline = await checkService(service.url);

  const row = widget.addStack();
  row.layoutHorizontally();
  row.centerAlignContent();

  const statusIcon = isOnline ? "🟢" : "🔴";
  const statusText = row.addText(`${statusIcon} ${service.emoji} ${service.name}`);
  statusText.font = Font.systemFont(13);
  statusText.textColor = Color.white();

  widget.addSpacer(4);
}

widget.addSpacer(8);

// Last updated
const now = new Date();
const time = now.toLocaleTimeString('da-DK', {
  hour: '2-digit',
  minute: '2-digit'
});
const updated = widget.addText(`Opdateret: ${time}`);
updated.font = Font.systemFont(10);
updated.textColor = new Color("#ffffff", 0.7);

// Tap to open dashboard
widget.url = "https://home.kobber.me";

// Refresh interval
widget.refreshAfterDate = new Date(Date.now() + 1000 * 60 * 5); // 5 minutter

// Present
if (config.runsInWidget) {
  Script.setWidget(widget);
} else {
  widget.presentMedium();
}

Script.complete();
