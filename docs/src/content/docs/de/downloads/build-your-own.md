---
title: Baue dein eigenes
---

1. Installiere Git und Flutter (Beta)
2. Repository klonen
3. Navigiere zum App-Verzeichnis
4. Benutze das Flutter-Werkzeug, um die Anwendung zu kompilieren
   - `flutter build apk`
   - `flutter build appbundle`
   - `flutter build web`
   - `flutter build linux`
   - `flutter build windows`
   - `flutter build ios --release --no-codesign`\
     danach erstellen Sie einen Ordner namens "Payload", kopieren Sie Runner.app dorthin und zippen Sie den Payload-Ordner. Dann benennen Sie ".zip" in ".ipa" um.
5. Die kompilierten Dateien befinden sich im Build-Verzeichnis
