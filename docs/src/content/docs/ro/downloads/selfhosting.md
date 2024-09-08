---
title: Selfhosting
---

![Stable release version](https://img.shields.io/badge/dynamic/yaml?color=c4840d\&label=Stable\&query=%24.version\&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fstable%2Fapp%2Fpubspec.yaml\&style=for-the-badge)
![Nightly release version](https://img.shields.io/badge/dynamic/yaml?color=f7d28c\&label=Nightly\&query=%24.version\&url=https%3A%2F%2Fraw.githubusercontent.com%2FLinwoodDev%2Fbutterfly%2Fnightly%2Fapp%2Fpubspec.yaml\&style=for-the-badge)

Este foarte uşor să îţi găzduieşti propriul server de fluturi.

## Server simplu

Instalați flutter și construiți aplicația folosind:

```bash
cd app
flutter pub get
flutter build web
```

Toate fișierele sunt în folderul `app/build/web`.

## Doctor

Clonați depozitul și construiți `Dockerfile` folosind: `docker construiește -t linwood-butterfly`.
Porniți serverul folosind: `docker run -p 8080:8080 -d linwood-butterfly`.
