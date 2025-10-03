# Firebase Authentication Setup ✅

## ✅ Was bereits aktiviert ist (Firebase Console):
- ✅ E-Mail/Passwort
- ✅ Telefon
- ✅ Google
- ✅ Apple

## ✅ Was bereits implementiert ist (Code):

### 1. **E-Mail/Passwort Login** ✅
```dart
// Login
final user = await AuthService().loginWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Registrierung
await AuthService().register(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
  displayName: 'Display Name',
  phoneNumber: '+49123456789',
);
```

### 2. **Phone Authentication (OTP)** ✅
```dart
// OTP senden
final verificationId = await AuthService().sendOTP('+49123456789');

// OTP verifizieren
final success = await AuthService().verifyOTP(verificationId, '123456');

// Login mit Phone
final user = await AuthService().loginWithPhone(
  phoneNumber: '+49123456789',
  otpCode: '$verificationId:123456',
);
```

### 3. **Google Sign-In** ✅ NEU!
```dart
// Google Login (One-Tap)
final user = await AuthService().loginWithGoogle();
```

### 4. **Apple Sign-In** ✅ NEU!
```dart
// Apple Login (nur iOS/macOS)
final user = await AuthService().loginWithApple();
```

---

## 📦 Neue Packages hinzugefügt:

```yaml
dependencies:
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0
```

**Installieren:**
```bash
flutter pub get
```

---

## 🔧 Google Sign-In Konfiguration

### Android (android/app/build.gradle.kts):
Bereits konfiguriert mit `firebase_auth`, keine Extra-Schritte nötig!

### iOS (ios/Runner/Info.plist):
Füge hinzu:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reversed client ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Finde deine REVERSED_CLIENT_ID:**
1. Öffne `ios/Runner/GoogleService-Info.plist`
2. Suche nach `REVERSED_CLIENT_ID`
3. Kopiere den Wert

---

## 🍎 Apple Sign-In Konfiguration

### iOS (Xcode):
1. Öffne `ios/Runner.xcworkspace` in Xcode
2. Wähle Runner Target
3. Gehe zu **Signing & Capabilities**
4. Klicke **+ Capability**
5. Füge **Sign in with Apple** hinzu

### Capabilities (ios/Runner/Runner.entitlements):
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

## 🎯 Wie benutzt man die Logins in der App?

### Beispiel Login Page:

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // E-Mail Login
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await _authService.loginWithEmail(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  // Navigation zur Home Page
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              },
              child: Text('Login with Email'),
            ),
            
            SizedBox(height: 20),
            
            // Google Sign-In Button
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final user = await _authService.loginWithGoogle();
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google Sign-In failed: $e')),
                  );
                }
              },
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            
            // Apple Sign-In Button (nur iOS)
            if (Platform.isIOS || Platform.isMacOS)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final user = await _authService.loginWithApple();
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Apple Sign-In failed: $e')),
                    );
                  }
                },
                icon: Icon(Icons.apple),
                label: Text('Sign in with Apple'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔐 Phone Authentication Setup

### Firebase Console:
1. Gehe zu **Authentication > Sign-in method**
2. Aktiviere **Phone** (bereits aktiviert ✅)
3. Füge Test Phone Numbers hinzu (optional):
   - Nummer: `+49123456789`
   - Code: `123456`

### Android SHA-1 Fingerprint:
Für Phone Auth auf Android brauchst du SHA-1:

```bash
cd android
./gradlew signingReport
```

Kopiere den **SHA-1** und füge ihn in Firebase Console hinzu:
- **Project Settings > Your Apps > Android App > Add Fingerprint**

---

## 📱 Testen der Logins

### 1. E-Mail/Passwort:
```dart
// Registrierung
await AuthService().register(
  email: 'test@example.com',
  password: 'Test123!',
  username: 'testuser',
  displayName: 'Test User',
  phoneNumber: '+491234567890',
);

// Login
await AuthService().loginWithEmail(
  email: 'test@example.com',
  password: 'Test123!',
);
```

### 2. Google:
```dart
// Einfach Button klicken
await AuthService().loginWithGoogle();
```

### 3. Apple:
```dart
// Nur auf iOS/macOS
await AuthService().loginWithApple();
```

### 4. Phone:
```dart
// OTP senden
final verificationId = await AuthService().sendOTP('+491234567890');

// Warte auf SMS...

// OTP eingeben
await AuthService().verifyOTP(verificationId, '123456');
```

---

## ✅ Logout

```dart
await AuthService().logout();
```

Dies loggt aus:
- ✅ Firebase Auth
- ✅ Google Sign-In
- ✅ Local Storage

---

## 🔍 User Status prüfen

```dart
final authService = AuthService();

// Ist eingeloggt?
if (authService.isLoggedIn) {
  final user = authService.currentUser;
  print('User: ${user?.displayName}');
}
```

---

## 🚨 Wichtige Hinweise

### Sicherheit:
1. **Niemals** Firebase Config in Git committen
2. **Immer** `.env` für API Keys nutzen
3. **Firestore Rules** setzen:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### Production:
1. Aktiviere **App Check** in Firebase
2. Setze **Rate Limiting** für Auth
3. Aktiviere **Multi-Factor Authentication**

---

## 📝 Zusammenfassung

| Login Methode | Status | Code Ready |
|--------------|--------|------------|
| E-Mail/Passwort | ✅ Aktiviert | ✅ Implementiert |
| Telefon (OTP) | ✅ Aktiviert | ✅ Implementiert |
| Google | ✅ Aktiviert | ✅ Implementiert |
| Apple | ✅ Aktiviert | ✅ Implementiert |

**ALLE Login-Methoden sind jetzt einsatzbereit!** 🎉

Nächster Schritt:
```bash
flutter pub get
flutter run
```
