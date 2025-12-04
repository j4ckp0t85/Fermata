#!/bin/bash
set -e

# Script per compilare il modulo whisper usando Docker
# Questo evita i problemi di toolchain su Windows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🐳 Building whisper module in Docker..."
echo "Project directory: $PROJECT_DIR"

# Verifica che Docker sia in esecuzione
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Build dell'immagine Docker se necessario
echo "📦 Building Docker image..."
docker build -t fermata-builder "$SCRIPT_DIR"

# Compila il modulo whisper
echo "🔨 Compiling whisper native libraries..."
docker run --rm \
    -v "$PROJECT_DIR:/workspace" \
    -w /workspace \
    fermata-builder \
    bash -c "
        set -e
        echo '📋 Configuring Gradle...'
        
        # Compila solo le librerie native del modulo whisper
        echo '🔧 Building whisper native libraries...'
        ./gradlew :whisper:externalNativeBuildRelease
        
        echo '✅ Build completed successfully!'
        echo '📁 Native libraries location:'
        find modules/whisper/.cxx/Release -name '*.so' -type f
    "

# Copia le librerie compilate nella directory jniLibs
echo "📋 Copying compiled libraries to jniLibs..."
JNILIBS_DIR="$PROJECT_DIR/modules/whisper/src/main/jniLibs"
mkdir -p "$JNILIBS_DIR"

# Copia per ogni ABI
for ABI in arm64-v8a armeabi-v7a x86 x86_64; do
    SO_FILE=$(find "$PROJECT_DIR/modules/whisper/.cxx/Release" -path "*/$ABI/*.so" -name "libwhisper_jni.so" 2>/dev/null | head -1)
    if [ -n "$SO_FILE" ]; then
        mkdir -p "$JNILIBS_DIR/$ABI"
        cp "$SO_FILE" "$JNILIBS_DIR/$ABI/"
        echo "  ✓ Copied $ABI/libwhisper_jni.so"
    fi
done

echo ""
echo "✅ Done! Native libraries are ready."
echo "📱 You can now use Android Studio normally for debugging."
echo ""
echo "💡 Tip: Run this script again only when you need to rebuild native code."
