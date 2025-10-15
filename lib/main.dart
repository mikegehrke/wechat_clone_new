// ============================================
// 📱 MAIN.DART - Der Einstiegspunkt der App
// ============================================
// Das ist die WICHTIGSTE Datei!
// Hier startet die gesamte Flutter App.
// ============================================

// ============================================
// 📦 IMPORTS (Pakete die wir brauchen)
// ============================================

// IMPORT #1: Flutter Material Design
// Was macht das? 
// - Gibt uns alle UI-Komponenten (Button, Text, Container, etc.)
// - Material Design = Google's Design-System (wie iOS hat Cupertino)
import 'package:flutter/material.dart';

// IMPORT #2: Provider (State Management)
// Was macht das?
// - Erlaubt uns, Daten zwischen verschiedenen Screens zu teilen
// - z.B. User-Daten müssen überall verfügbar sein
// - MVVM braucht das! ViewModel kommuniziert mit View über Provider
import 'package:provider/provider.dart';

// IMPORT #3: Firebase Core
// Was macht das?
// - Das MUSS zuerst importiert werden, bevor wir Firebase nutzen!
// - Ist die Basis für alle Firebase-Services
import 'package:firebase_core/firebase_core.dart';

// IMPORT #4: Firebase Options
// Was macht das?
// - Enthält die Konfiguration für Firebase
// - API Keys, Project ID, etc.
// - Diese Datei wird automatisch von Firebase generiert
import 'firebase_options.dart';

// ============================================
// 🚀 MAIN FUNCTION - Hier startet ALLES!
// ============================================

// Die main() Funktion ist der ALLERERSTE Code der ausgeführt wird!
// async = Diese Funktion kann auf Dinge warten (z.B. Firebase initialisieren)
void main() async {
  // ------------------------------------------
  // SCHRITT 1: Flutter initialisieren
  // ------------------------------------------
  // Was macht das?
  // - Flutter muss vorbereitet werden, BEVOR wir async Operationen machen
  // - Ohne das würde die App crashen!
  // - Muss IMMER als erstes kommen, wenn wir async in main() nutzen
  WidgetsFlutterBinding.ensureInitialized();
  
  // ------------------------------------------
  // SCHRITT 2: Firebase initialisieren
  // ------------------------------------------
  // Was macht das?
  // - Verbindet unsere App mit Firebase
  // - Lädt die Konfiguration (API Keys, etc.)
  // - await = Warte, bis Firebase fertig initialisiert ist
  
  try {
    // Versuche Firebase zu initialisieren
    // options = Welche Firebase Konfiguration nutzen wir?
    // DefaultFirebaseOptions.currentPlatform = 
    //   Automatisch die richtige Config für iOS, Android oder Web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Debug-Ausgabe: Zeige dass Firebase funktioniert
    // print() = Ausgabe in der Konsole (nur für Entwickler sichtbar)
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    // Falls Firebase NICHT funktioniert:
    // e = Die Fehlermeldung
    // stackTrace = Wo genau ist der Fehler passiert?
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
    
    // Wir lassen die App trotzdem laufen
    // (Später können wir eine Fehlermeldung anzeigen)
  }
  
  // ------------------------------------------
  // SCHRITT 3: App starten!
  // ------------------------------------------
  // Was macht das?
  // - runApp() = Flutter's Befehl "Zeige diese App an!"
  // - const MyApp() = Erstelle ein MyApp Widget (siehe unten)
  // - const = Sagt Flutter "das ändert sich nie, optimiere es!"
  runApp(const MyApp());
}

// ============================================
// 📱 MYAPP WIDGET - Die Haupt-App Klasse
// ============================================

// Was ist ein Widget?
// - ALLES in Flutter ist ein Widget!
// - Widget = Ein UI-Element (Button, Text, oder sogar die ganze App!)

// StatelessWidget = Ein Widget das sich NICHT ändert
// (im Gegensatz zu StatefulWidget, das sich ändern kann)
class MyApp extends StatelessWidget {
  // Constructor (Konstruktor)
  // Was macht das?
  // - Wird aufgerufen wenn wir "MyApp()" schreiben
  // - const = Diese Instanz ist konstant (optimiert Performance)
  // - super.key = Gibt den "key" an die Elternklasse weiter
  const MyApp({super.key});

  // ------------------------------------------
  // BUILD METHOD - Baut die UI
  // ------------------------------------------
  // Diese Methode wird aufgerufen um die UI zu zeichnen
  // @override = Wir überschreiben die Methode von StatelessWidget
  // Widget = Diese Methode gibt ein Widget zurück
  // BuildContext context = Informationen über Position im Widget-Baum
  @override
  Widget build(BuildContext context) {
    // ------------------------------------------
    // MULTI PROVIDER - State Management Setup
    // ------------------------------------------
    // Was macht das?
    // - MultiProvider = Ermöglicht mehrere Provider gleichzeitig
    // - Provider = Macht Daten überall in der App verfügbar
    return MultiProvider(
      // Liste von Providern:
      providers: [
        // Provider #1: Auth Provider (wird später erstellt)
        // Was macht der?
        // - Verwaltet Login/Logout
        // - Speichert aktuellen User
        // - Prüft ob User eingeloggt ist
        
        // ChangeNotifierProvider = Sagt Flutter "wenn sich was ändert, update die UI"
        // create: (_) => AuthProvider() = Erstelle einen neuen AuthProvider
        // Der _ bedeutet "context brauchen wir hier nicht"
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // HINWEIS: Auskommentiert, weil wir AuthProvider noch nicht haben!
        // Wir erstellen das später in Lektion 7
      ],
      
      // ------------------------------------------
      // MATERIAL APP - Die App-Konfiguration
      // ------------------------------------------
      // child = Das Kind-Widget von MultiProvider
      child: MaterialApp(
        // ------------------------------------------
        // APP TITLE
        // ------------------------------------------
        // Der Name der App (wird in der Task-Liste angezeigt)
        title: 'WeChat Clone',
        
        // ------------------------------------------
        // DEBUG BANNER
        // ------------------------------------------
        // Was macht das?
        // - Versteckt das "DEBUG" Banner oben rechts
        // - false = Kein Banner anzeigen
        debugShowCheckedModeBanner: false,
        
        // ------------------------------------------
        // THEME - Das Design/Aussehen der App
        // ------------------------------------------
        // Was ist ein Theme?
        // - Definiert Farben, Schriftarten, Button-Styles, etc.
        // - Einmal definieren, überall nutzen!
        theme: ThemeData(
          // ------------------------------------------
          // PRIMARY COLOR - Haupt-Farbe der App
          // ------------------------------------------
          // WeChat's typisches Grün: #07C160
          // 0xFF = Volle Deckkraft (Alpha-Kanal)
          // 07C160 = Hex-Farbcode (Rot-Grün-Blau)
          primaryColor: const Color(0xFF07C160),
          
          // ------------------------------------------
          // COLOR SCHEME - Farbschema
          // ------------------------------------------
          // Was macht das?
          // - Generiert automatisch alle Farben (hell, dunkel, etc.)
          // - seedColor = Die Basis-Farbe
          // - brightness = Hell oder Dunkel?
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF07C160), // WeChat Grün
            brightness: Brightness.light,        // Helles Theme
          ),
          
          // ------------------------------------------
          // MATERIAL 3
          // ------------------------------------------
          // Was ist das?
          // - Material 3 = Google's neuestes Design-System
          // - Modernere Buttons, schönere Animationen, etc.
          useMaterial3: true,
          
          // ------------------------------------------
          // APP BAR THEME - Design für obere Leiste
          // ------------------------------------------
          // AppBar = Die Leiste oben (mit Titel und Buttons)
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,      // Weißer Hintergrund
            foregroundColor: Colors.black,      // Schwarzer Text
            elevation: 0,                       // Kein Schatten
          ),
          
          // ------------------------------------------
          // BUTTON THEME - Design für Buttons
          // ------------------------------------------
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160), // Grüner Hintergrund
              foregroundColor: Colors.white,             // Weißer Text
              
              // Button-Form:
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Abgerundete Ecken
              ),
              
              // Button-Größe:
              padding: const EdgeInsets.symmetric(
                horizontal: 24, // Links/Rechts Abstand
                vertical: 12,   // Oben/Unten Abstand
              ),
            ),
          ),
        ),
        
        // ------------------------------------------
        // HOME - Der Start-Screen
        // ------------------------------------------
        // Was wird als erstes angezeigt?
        // Scaffold = Basis-Struktur eines Screens
        //   (mit AppBar, Body, BottomNavigationBar, etc.)
        home: Scaffold(
          // ------------------------------------------
          // APP BAR - Obere Leiste
          // ------------------------------------------
          appBar: AppBar(
            title: const Text('WeChat Clone'),
            centerTitle: true, // Titel in der Mitte
          ),
          
          // ------------------------------------------
          // BODY - Haupt-Inhalt
          // ------------------------------------------
          body: const Center(
            child: Column(
              // mainAxisAlignment = Vertikale Ausrichtung
              // MainAxisAlignment.center = Alles in der Mitte
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ------------------------------------------
                // ICON
                // ------------------------------------------
                Icon(
                  Icons.chat_bubble_outline,    // Chat-Blasen Icon
                  size: 80,                     // Größe: 80 Pixel
                  color: Color(0xFF07C160),     // WeChat Grün
                ),
                
                // ------------------------------------------
                // ABSTAND
                // ------------------------------------------
                // SizedBox = Unsichtbare Box (für Abstände)
                SizedBox(height: 24), // 24 Pixel Abstand nach unten
                
                // ------------------------------------------
                // TEXT
                // ------------------------------------------
                Text(
                  'Willkommen, Herr Schüler! 🎓',
                  style: TextStyle(
                    fontSize: 24,              // Schriftgröße
                    fontWeight: FontWeight.bold, // Fett
                    color: Colors.black87,     // Dunkelgrau
                  ),
                ),
                
                // Abstand
                SizedBox(height: 16),
                
                // Untertitel
                Text(
                  'Deine WeChat Clone App ist bereit!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                // Abstand
                SizedBox(height: 32),
                
                // ------------------------------------------
                // INFO-TEXT
                // ------------------------------------------
                Padding(
                  // padding = Innen-Abstand
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '📚 Als nächstes:\n'
                    '1. Firebase konfigurieren\n'
                    '2. User Model erstellen\n'
                    '3. Login Screen bauen\n'
                    '4. Chat implementieren',
                    textAlign: TextAlign.center, // Zentriert
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5, // Zeilenhöhe
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ------------------------------------------
          // FLOATING ACTION BUTTON - Schwebender Button
          // ------------------------------------------
          // Der runde Button unten rechts
          floatingActionButton: FloatingActionButton(
            // Was passiert bei Klick?
            onPressed: () {
              // Zeige eine Nachricht
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bereit zum Lernen! 🚀'),
                  backgroundColor: Color(0xFF07C160),
                ),
              );
            },
            backgroundColor: const Color(0xFF07C160),
            child: const Icon(Icons.add), // Plus-Icon
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🎓 ZUSAMMENFASSUNG - Was hast du gelernt?
// ============================================
// ✅ main() = Einstiegspunkt der App
// ✅ async/await = Auf Dinge warten (z.B. Firebase)
// ✅ WidgetsFlutterBinding.ensureInitialized() = Flutter vorbereiten
// ✅ Firebase.initializeApp() = Firebase starten
// ✅ runApp() = App anzeigen
// ✅ StatelessWidget = Widget das sich nicht ändert
// ✅ MaterialApp = App-Konfiguration (Theme, Title, etc.)
// ✅ ThemeData = Design definieren (Farben, Buttons, etc.)
// ✅ Scaffold = Basis-Struktur eines Screens
// ✅ AppBar = Obere Leiste
// ✅ Body = Haupt-Inhalt
// ✅ const = Performance-Optimierung
// ============================================

// ============================================
// 🔥 NÄCHSTE SCHRITTE
// ============================================
// 1. Diese Datei speichern
// 2. Firebase Options konfigurieren
// 3. User Model erstellen
// 4. Auth Provider erstellen
// 5. Login Screen bauen
// ============================================
