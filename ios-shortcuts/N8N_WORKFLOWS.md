# n8n Workflows for iOS Integration

Færdige workflow ideer til at integrere med dine iOS shortcuts.

## 🎯 Workflow 1: Simple Webhook Echo

**Test at webhooks virker:**

### Nodes:
1. **Webhook** → POST `/webhook/test`
2. **Code** →
   ```javascript
   return [
     {
       json: {
         status: "success",
         message: "Webhook received!",
         timestamp: new Date().toISOString(),
         data: $input.all()
       }
     }
   ];
   ```
3. **Respond to Webhook** → Body: `{{ $json }}`

**Test:**
```bash
curl -X POST https://n8n.kobber.me/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

---

## 📸 Workflow 2: Upload Billede til Nextcloud

### Nodes:

1. **Webhook** → POST `/webhook/upload-image`
   - Response Mode: On Response Receipt

2. **Code** - Decode Base64
   ```javascript
   const imageData = $input.item.json.image;
   const fileName = `upload_${Date.now()}.jpg`;

   return [
     {
       json: { fileName },
       binary: {
         data: Buffer.from(imageData, 'base64')
       }
     }
   ];
   ```

3. **Move Binary Data**
   - Mode: JSON to Binary
   - Source: data
   - Destination: file

4. **Nextcloud** → Upload File
   - Resource: File
   - Operation: Upload
   - Folder: `/iPhone Uploads/`
   - Binary Property: file

5. **Respond to Webhook**
   ```json
   {
     "status": "success",
     "message": "Billede uploaded!",
     "fileName": "{{ $('Code').item.json.fileName }}"
   }
   ```

---

## 🔋 Workflow 3: Battery Low Logger

### Nodes:

1. **Webhook** → POST `/webhook/battery-low`

2. **Set** - Format Data
   ```javascript
   {
     "battery_level": "{{ $json.battery }}",
     "device": "{{ $json.device }}",
     "location_lat": "{{ $json.location.latitude }}",
     "location_lon": "{{ $json.location.longitude }}",
     "timestamp": "{{ new Date().toISOString() }}"
   }
   ```

3. **PostgreSQL** → Insert
   - Table: battery_logs
   - Columns: battery_level, device, location_lat, location_lon, timestamp

4. **Pushover** → Send Notification
   - Message: "iPhone battery low: {{ $json.battery_level }}%"
   - Title: "Battery Alert"
   - Priority: High

5. **Respond to Webhook**
   ```json
   {
     "status": "logged",
     "message": "Battery status saved"
   }
   ```

---

## 🏠 Workflow 4: Coming Home Automation

### Nodes:

1. **Webhook** → POST `/webhook/coming-home`

2. **Set** - Welcome Message
   ```javascript
   {
     "user": "{{ $json.user || 'User' }}",
     "time": "{{ new Date().toLocaleTimeString('da-DK') }}",
     "message": `Velkommen hjem! Det er ${new Date().toLocaleTimeString('da-DK')}`
   }
   ```

3. **IF** - Er det sent?
   - Condition: `{{ new Date().getHours() }}` > 22
   - True: Send "God aften" besked
   - False: Send "Velkommen hjem" besked

4. **PostgreSQL** → Log arrival
   - Table: home_arrivals
   - Columns: arrival_time, user

5. **NocoDB** → Update Tasks
   - Hent dagens opgaver og send i response

6. **Respond to Webhook** → JSON med velkommen besked + dagens tasks

---

## ⏰ Workflow 5: Morning Routine

### Nodes:

1. **Webhook** → POST `/webhook/morning-routine`

2. **Schedule Trigger** (parallel) → Daily at 07:00

3. **NocoDB** → Get Today's Tasks
   - Filter: Due date = Today
   - Sort: Priority DESC

4. **OpenWeather** → Get Weather
   - Operation: Current Weather
   - Location: Copenhagen

5. **Code** → Format Morning Summary
   ```javascript
   const tasks = $('NocoDB').all();
   const weather = $('OpenWeather').first().json;

   return [{
     json: {
       greeting: `☀️ God morgen! Det er ${new Date().toLocaleDateString('da-DK')}`,
       weather: `🌡️ ${Math.round(weather.main.temp)}°C, ${weather.weather[0].description}`,
       tasks: tasks.map(t => `• ${t.json.title}`).join('\n'),
       taskCount: tasks.length
     }
   }];
   ```

6. **Pushover** → Send Morning Summary

7. **Respond to Webhook** → Send summary til iOS shortcut

---

## 🌙 Workflow 6: Night Backup

### Nodes:

1. **Schedule Trigger** → Daily at 03:00

2. **Bash** → Run backup script
   ```bash
   cd /Users/jonasraaschou/homeserver && ./backup.sh
   ```

3. **Nextcloud** → List Files
   - Folder: `/iPhone Photos/`
   - Filter: Created today

4. **PostgreSQL** → Log Backup
   ```sql
   INSERT INTO backups (date, file_count, status)
   VALUES (NOW(), {{ $('Nextcloud').all().length }}, 'completed')
   ```

5. **IF** - Success?
   - True → Send success notification
   - False → Send error alert

6. **Pushover** → Send Completion Status

---

## 📤 Workflow 7: Save Link from iOS

### Nodes:

1. **Webhook** → POST `/webhook/save-link`

2. **HTTP Request** → Fetch Page Metadata
   - URL: `{{ $json.url }}`
   - Method: GET

3. **HTML Extract** → Get Title
   - Selector: `title`

4. **NocoDB** → Create Row
   - Table: saved_links
   - Columns:
     - url: `{{ $('Webhook').item.json.url }}`
     - title: `{{ $json.title }}`
     - saved_at: `{{ new Date().toISOString() }}`
     - source: "iPhone"

5. **Respond to Webhook**
   ```json
   {
     "status": "saved",
     "title": "{{ $('HTML Extract').item.json.title }}",
     "id": "{{ $('NocoDB').item.json.id }}"
   }
   ```

---

## 🎮 Workflow 8: Focus Mode Tracker

### Nodes:

1. **Webhook** → POST `/webhook/focus-mode`
   - Receives: mode (start/end), type (work/personal)

2. **Switch** → Based on action
   - start → Log start time
   - end → Log end time + calculate duration

3. **PostgreSQL** → Insert/Update
   ```sql
   -- Start:
   INSERT INTO focus_sessions (type, start_time, device)
   VALUES ('{{ $json.type }}', NOW(), 'iPhone')

   -- End:
   UPDATE focus_sessions
   SET end_time = NOW(),
       duration = EXTRACT(EPOCH FROM (NOW() - start_time))
   WHERE id = (SELECT MAX(id) FROM focus_sessions WHERE type = '{{ $json.type }}')
   ```

4. **Code** → Calculate Stats
   ```javascript
   // Hvis det er slut på work session
   if ($json.action === 'end') {
     const duration = $json.duration / 3600; // timer
     return [{
       json: {
         message: `Work session complete! Duration: ${duration.toFixed(1)} timer 🎉`,
         stats: `Total fokus i dag: ${$json.totalToday} timer`
       }
     }];
   }
   ```

5. **Pushover** → Send Stats

---

## 📊 Workflow 9: Dashboard Analytics

### Nodes:

1. **Schedule Trigger** → Daily at 23:00

2. **PostgreSQL** → Query Statistics
   ```sql
   SELECT
     COUNT(*) as visits,
     COUNT(DISTINCT user_id) as unique_users,
     DATE(created_at) as date
   FROM analytics
   WHERE DATE(created_at) = CURRENT_DATE
   GROUP BY DATE(created_at)
   ```

3. **PostgreSQL** → Query Service Usage
   ```sql
   SELECT service, COUNT(*) as usage_count
   FROM service_logs
   WHERE DATE(created_at) = CURRENT_DATE
   GROUP BY service
   ORDER BY usage_count DESC
   ```

4. **Code** → Format Report
   ```javascript
   const analytics = $('PostgreSQL').first().json;
   const services = $('PostgreSQL1').all();

   return [{
     json: {
       title: "📊 Daily Report",
       date: new Date().toLocaleDateString('da-DK'),
       visits: analytics.visits,
       topService: services[0].json.service,
       summary: `${analytics.visits} visits • ${services.length} services used`
     }
   }];
   ```

5. **Pushover** → Send Daily Report

---

## 🔐 Workflow 10: Security Monitor

### Nodes:

1. **Webhook** → POST `/webhook/security-check`

2. **Docker** → Check Running Containers
   ```bash
   docker ps --format "{{.Names}}: {{.Status}}"
   ```

3. **HTTP Request** → Check Services
   - n8n.kobber.me
   - nocodb.kobber.me
   - cloud.kobber.me
   - home.kobber.me

4. **IF** → All Services Up?
   - True → All good
   - False → Send alert

5. **PostgreSQL** → Log Status
   ```sql
   INSERT INTO security_checks (timestamp, all_services_up, details)
   VALUES (NOW(), {{ $json.allUp }}, '{{ $json.details }}')
   ```

6. **Pushover** → Alert if Down
   - Only if services are down
   - Priority: High
   - Sound: Alert

---

## 🚀 Getting Started

### Setup Database Tables:

```sql
-- Battery logs
CREATE TABLE battery_logs (
  id SERIAL PRIMARY KEY,
  battery_level INTEGER,
  device VARCHAR(50),
  location_lat DECIMAL(10, 8),
  location_lon DECIMAL(11, 8),
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Home arrivals
CREATE TABLE home_arrivals (
  id SERIAL PRIMARY KEY,
  arrival_time TIMESTAMP DEFAULT NOW(),
  user VARCHAR(50)
);

-- Focus sessions
CREATE TABLE focus_sessions (
  id SERIAL PRIMARY KEY,
  type VARCHAR(20),
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  duration INTEGER,
  device VARCHAR(50)
);

-- Saved links
CREATE TABLE saved_links (
  id SERIAL PRIMARY KEY,
  url TEXT,
  title TEXT,
  saved_at TIMESTAMP DEFAULT NOW(),
  source VARCHAR(50)
);

-- Backups log
CREATE TABLE backups (
  id SERIAL PRIMARY KEY,
  date TIMESTAMP DEFAULT NOW(),
  file_count INTEGER,
  status VARCHAR(20)
);
```

### Test Webhooks:

```bash
# Test from terminal
curl -X POST https://n8n.kobber.me/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello from terminal!"}'

# Test battery low
curl -X POST https://n8n.kobber.me/webhook/battery-low \
  -H "Content-Type: application/json" \
  -d '{"battery": 15, "device": "iPhone", "location": {"latitude": 55.6761, "longitude": 12.5683}}'
```

---

## 💡 Best Practices

1. **Error Handling:** Altid tilføj error handling nodes
2. **Logging:** Log alle webhook calls til database
3. **Authentication:** Overvej API keys for sensitive endpoints
4. **Rate Limiting:** Protect against spam
5. **Testing:** Test alle workflows grundigt før iOS integration

---

**Nu er du klar til at bygge avancerede iOS automations! 🚀**
