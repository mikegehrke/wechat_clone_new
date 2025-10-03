# API-Schlüssel Setup Anleitung

## 🔑 Benötigte API-Schlüssel

### 1. OpenAI API (für AI-Funktionen)
- **Website**: https://platform.openai.com/
- **Kosten**: $5-20/Monat je nach Nutzung
- **Funktionen**: Text-Generierung, Chat, Content-Moderation

**So bekommen Sie den Schlüssel:**
1. Registrieren Sie sich bei OpenAI
2. Gehen Sie zu "API Keys"
3. Klicken Sie "Create new secret key"
4. Kopieren Sie den Schlüssel (beginnt mit `sk-`)

### 2. Stability AI (für Bild-Generierung)
- **Website**: https://platform.stability.ai/
- **Kosten**: $10-30/Monat je nach Nutzung
- **Funktionen**: AI-Bild-Generierung mit Stable Diffusion

**So bekommen Sie den Schlüssel:**
1. Registrieren Sie sich bei Stability AI
2. Gehen Sie zu "API Keys"
3. Erstellen Sie einen neuen Schlüssel
4. Kopieren Sie den Schlüssel (beginnt mit `sk-`)

### 3. ElevenLabs (für Sprach-Generierung)
- **Website**: https://elevenlabs.io/
- **Kosten**: $5-22/Monat je nach Nutzung
- **Funktionen**: Text-zu-Sprache in verschiedenen Stimmen

**So bekommen Sie den Schlüssel:**
1. Registrieren Sie sich bei ElevenLabs
2. Gehen Sie zu Ihrem Profil → "API Key"
3. Kopieren Sie den Schlüssel

### 4. Stripe (für Zahlungen)
- **Website**: https://stripe.com/
- **Kosten**: 2.9% + 30¢ pro Transaktion
- **Funktionen**: Kreditkarten-Verarbeitung, Abonnements

**So bekommen Sie die Schlüssel:**
1. Registrieren Sie sich bei Stripe
2. Gehen Sie zu "Developers" → "API keys"
3. Kopieren Sie sowohl "Publishable key" als auch "Secret key"
4. **WICHTIG**: Verwenden Sie zuerst die Test-Schlüssel (beginnen mit `pk_test_` und `sk_test_`)

### 5. Google Maps (für Standort-Features)
- **Website**: https://console.cloud.google.com/
- **Kosten**: Meist kostenlos (erste 200$ pro Monat gratis)
- **Funktionen**: Karten, Geocoding, Places API

**So bekommen Sie den Schlüssel:**
1. Gehen Sie zur Google Cloud Console
2. Erstellen Sie ein neues Projekt
3. Aktivieren Sie "Maps JavaScript API" und "Places API"
4. Gehen Sie zu "Credentials" → "Create credentials" → "API key"

## 📝 Setup-Schritte

### Schritt 1: .env Datei erstellen
```bash
# Kopieren Sie die Beispiel-Datei:
cp .env.example .env
```

### Schritt 2: API-Schlüssel eintragen
Öffnen Sie die `.env` Datei und ersetzen Sie die Platzhalter mit Ihren echten Schlüsseln:

```bash
# Beispiel:
OPENAI_API_KEY=sk-proj-abc123def456...
STRIPE_PUBLISHABLE_KEY=pk_test_xyz789...
ELEVENLABS_API_KEY=a1b2c3d4e5f6...
```

### Schritt 3: App neu starten
```bash
flutter pub get
flutter run
```

## 🚨 Sicherheitshinweise

### ❌ NIEMALS machen:
- API-Schlüssel in Git committen
- Schlüssel in Screenshots teilen
- Schlüssel in öffentlichen Foren posten
- Production-Schlüssel in Test-Apps verwenden

### ✅ Immer machen:
- `.env` in `.gitignore` eintragen
- Test-Schlüssel für Entwicklung verwenden
- Schlüssel regelmäßig rotieren
- Ausgaben-Limits bei APIs setzen

## 🔧 Fehlerbehebung

### Problem: "API key not configured"
**Lösung**: Überprüfen Sie ob der Schlüssel in der `.env` Datei steht und die App neu gestartet wurde.

### Problem: "Invalid API key"
**Lösung**: Überprüfen Sie ob der Schlüssel korrekt kopiert wurde (keine Leerzeichen am Anfang/Ende).

### Problem: "Quota exceeded"
**Lösung**: Sie haben Ihr API-Limit erreicht. Überprüfen Sie Ihr Konto bei dem jeweiligen Anbieter.

## 💰 Kosten-Übersicht

| Service | Kostenloser Plan | Bezahlplan | Empfehlung |
|---------|------------------|------------|------------|
| OpenAI | $5 Guthaben | $20/Monat | Für Tests: $5 |
| Stability AI | Nein | $10/Monat | Für Tests: $10 |
| ElevenLabs | 10.000 Zeichen/Monat | $5/Monat | Kostenlos für Tests |
| Stripe | Ja (Test-Modus) | 2.9% pro Transaktion | Test-Modus für Entwicklung |
| Google Maps | $200/Monat gratis | Nach Nutzung | Meist kostenlos |

## 📞 Support

Bei Problemen:
1. Überprüfen Sie die `.env` Datei
2. Schauen Sie in die Debug-Konsole
3. Testen Sie die API-Schlüssel einzeln
4. Kontaktieren Sie den jeweiligen API-Anbieter

---

**Wichtig**: Starten Sie mit den kostenlosen/günstigen Optionen und erweitern Sie später bei Bedarf!