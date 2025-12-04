# Whisper Module - Docker Build

## Quick Start

Per compilare le librerie native del modulo whisper usando Docker:

```bash
# Windows
docker\build-whisper.bat

# Linux/Mac
docker/build-whisper.sh
```

## Perché Docker?

La compilazione dei shader Vulkan su Windows presenta problemi con il toolchain NDK. Usando Docker:
- ✅ Compilazione affidabile in ambiente Linux
- ✅ Debug completo in Android Studio su Windows
- ✅ Nessuna configurazione complessa

## Come Funziona

1. **Docker compila** le librerie `.so` per tutte le architetture (arm64-v8a, armeabi-v7a, x86, x86_64)
2. **Script copia** i file in `modules/whisper/src/main/jniLibs/`
3. **Gradle usa** le librerie pre-compilate invece di compilare con CMake
4. **Android Studio** funziona normalmente per debug e sviluppo

## Quando Ricompilare

Esegui lo script Docker solo quando modifichi:
- Codice C++ in `modules/whisper/src/main/cpp/`
- Dipendenze native (whisper.cpp, ggml, ecc.)

Per modifiche Java/Kotlin, usa normalmente Android Studio.

## Requisiti

- Docker Desktop installato e in esecuzione
- Connessione internet (prima volta, per scaricare immagine base)

## Troubleshooting

**"Docker is not running"**: Avvia Docker Desktop

**"No pre-built libraries found"**: Esegui `docker\build-whisper.bat` prima di compilare in Android Studio

**Librerie non aggiornate**: Elimina `modules/whisper/src/main/jniLibs/` e riesegui lo script Docker
