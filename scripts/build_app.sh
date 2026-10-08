#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🔨 Building GlassScreen (Release)..."
swift build -c release

APP_NAME="GlassScreen.app"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 Assembling $APP_NAME bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp ".build/release/GlassScreen" "$MACOS_DIR/GlassScreen"
chmod +x "$MACOS_DIR/GlassScreen"
cp ".build/release/GlassScreen" "$PROJECT_DIR/glass"
chmod +x "$PROJECT_DIR/glass"

# Copy Info.plist
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

# Copy AppIcon if present
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# Code sign ad-hoc
echo "🔏 Code-signing application bundle..."
codesign -s - --force --deep "$APP_BUNDLE"

echo "✅ Successfully built $APP_BUNDLE!"
echo "👉 You can launch it with: open \"$APP_BUNDLE\""
echo "👉 Or copy to Applications: cp -R \"$APP_BUNDLE\" /Applications/"
