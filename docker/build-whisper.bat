@echo off
REM Script per Windows per compilare il modulo whisper usando Docker

setlocal enabledelayedexpansion

echo Building whisper module in Docker...

REM Verifica che Docker sia in esecuzione
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker Desktop.
    exit /b 1
)

REM Ottieni la directory del progetto (rimuovi trailing backslash)
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set PROJECT_DIR=%SCRIPT_DIR%\..
cd /d "%PROJECT_DIR%"

echo Building Docker image...
docker build -t fermata-builder "%SCRIPT_DIR%"
if errorlevel 1 (
    echo Error: Failed to build Docker image
    exit /b 1
)

echo Compiling whisper native libraries...
docker run --rm -v "%CD%:/workspace" -w /workspace fermata-builder bash -c "dos2unix gradlew 2>/dev/null || sed -i 's/\r$//' gradlew && chmod +x gradlew && echo 'storeFile=res/fermata.jks' > local.properties && echo 'keyAlias=fermata' >> local.properties && echo 'keyPassword=fermata' >> local.properties && echo 'storePassword=fermata' >> local.properties && ./gradlew :whisper:externalNativeBuildAutoRelease --no-daemon && find modules/whisper/.cxx -name '*.so' -type f"
if errorlevel 1 (
    echo Error: Failed to compile native libraries
    exit /b 1
)

echo Copying compiled libraries to jniLibs...
set JNILIBS_DIR=%PROJECT_DIR%\modules\whisper\src\main\jniLibs
if not exist "%JNILIBS_DIR%" mkdir "%JNILIBS_DIR%"

REM Copia le librerie per ogni ABI
set COPIED=0
for %%A in (arm64-v8a armeabi-v7a x86 x86_64) do (
    set "SO_FILE=%PROJECT_DIR%\modules\whisper\build\intermediates\cmake\autoRelease\obj\%%A\libwhisper_jni.so"
    if exist "!SO_FILE!" (
        if not exist "%JNILIBS_DIR%\%%A" mkdir "%JNILIBS_DIR%\%%A"
        copy "!SO_FILE!" "%JNILIBS_DIR%\%%A\" >nul
        echo   Copied %%A/libwhisper_jni.so
        set COPIED=1
    )
)

if "%COPIED%"=="0" (
    echo Warning: No .so files were found to copy
    echo Check the Docker build output above for errors
)

echo.
echo Done! Native libraries are ready.
echo You can now use Android Studio normally for debugging.
echo.
echo Tip: Run this script again only when you need to rebuild native code.

endlocal
