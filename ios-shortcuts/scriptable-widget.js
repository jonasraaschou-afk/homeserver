// Kobber.me Server Status Widget for Scriptable
// Installation: Kopier denne kode til Scriptable app og kør som widget

const widget = new ListWidget();

// Gradient background - matcher dashboard
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

// Services status
const services = [
  { name: "n8n", emoji: "⚡" },
  { name: "NocoDB", emoji: "📊" },
  { name: "Nextcloud", emoji: "☁️" }
];

for (const service of services) {
  const row = widget.addStack();
  row.layoutHorizontally();
  row.centerAlignContent();

  const statusText = row.addText(`🟢 ${service.emoji} ${service.name}`);
  statusText.font = Font.systemFont(14);
  statusText.textColor = Color.white();

  widget.addSpacer(6);
}

widget.addSpacer(10);

// Last updated
const time = new Date().toLocaleTimeString('da-DK', {
  hour: '2-digit',
  minute: '2-digit'
});
const updated = widget.addText(`Opdateret: ${time}`);
updated.font = Font.systemFont(11);
updated.textColor = new Color("#ffffff", 0.8);

// Tap to open dashboard
widget.url = "https://home.kobber.me";

// Present widget
if (config.runsInWidget) {
  Script.setWidget(widget);
} else {
  widget.presentMedium();
}

Script.complete();
