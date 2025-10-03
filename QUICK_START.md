# 🚀 Super App - Quick Start Guide

## ✅ Backend läuft bereits!

Das Backend ist bereits gestartet und läuft auf **Port 5001**!

- **Health Check**: http://localhost:5001/health ✅
- **Status**: Running with in-memory storage (Development Mode)

## 📱 Flutter App starten

### 1. Terminal öffnen und zum Projekt navigieren:
```bash
cd /workspace
```

### 2. Flutter Dependencies installieren (falls noch nicht geschehen):
```bash
flutter pub get
```

### 3. App starten:

#### Für Android:
```bash
flutter run
```

#### Für iOS (nur auf macOS):
```bash
flutter run
```

#### Für Web:
```bash
flutter run -d chrome
```

## 🧪 Test-Funktionalitäten

### 1. Registrierung testen:
- Öffne die App
- Gehe zu "Register with Phone"
- Verwende eine beliebige Telefonnummer (z.B. +491234567890)
- **OTP wird in der Konsole angezeigt!** (Development Mode)

### 2. Login testen:
- Nach der Registrierung kannst du dich mit derselben Nummer einloggen
- Passwort: das bei der Registrierung verwendete

### 3. Chat testen:
- Nach dem Login kannst du Chats erstellen
- Nachrichten werden in Echtzeit übertragen (WebSockets)

## 📝 Wichtige Informationen

### Backend-Endpunkte:
- **API Base URL**: http://localhost:5001/api
- **WebSocket URL**: ws://localhost:5001
- **Health Check**: http://localhost:5001/health

### Verfügbare Features (Development Mode):
✅ Authentifizierung (Phone/OTP)
✅ User Profile
✅ Chat (Basic)
✅ WebSocket-Verbindung
⚠️ Andere Features sind Platzhalter

### Development-Besonderheiten:
- **In-Memory Storage**: Daten gehen beim Neustart verloren
- **OTP in Response**: OTP wird direkt zurückgegeben (nur für Dev)
- **Keine echten SMS**: OTP wird in der Konsole geloggt
- **Vereinfachte Authentifizierung**: Passwörter werden nicht gehasht

## 🔧 Troubleshooting

### Backend neu starten:
```bash
# Backend stoppen
pkill -f "node server-dev.js"

# Backend neu starten
cd /workspace/backend
PORT=5001 node server-dev.js
```

### Flutter-App neu laden:
- Drücke `r` im Terminal für Hot Reload
- Drücke `R` für Full Restart

### Logs anzeigen:
```bash
# Backend Logs
tail -f /workspace/backend/server.log

# Flutter Logs
flutter logs
```

## 🎯 Nächste Schritte

1. **MongoDB & Redis installieren** für persistente Datenspeicherung
2. **Echte Credentials hinzufügen** für:
   - Twilio (SMS)
   - Email Service
   - Stripe (Payments)
   - Cloudinary (File Storage)
3. **Production Server verwenden** (server.js statt server-dev.js)

## 📱 Demo-Accounts

Da wir In-Memory-Storage verwenden, musst du bei jedem Backend-Neustart neue Accounts erstellen.

**Test-Nummer für Demo:**
- Phone: +491234567890
- Username: wird automatisch generiert
- Password: test123 (selbst wählen bei Registrierung)

## 🎉 Viel Spaß mit der Super App!

Die App kombiniert Features von WhatsApp, Instagram, TikTok, Amazon, Uber Eats, Tinder und mehr - alles in einer App!