#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "=========================================="
echo "🚀 Building MacGoesBlurrrr & Creating .dmg"
echo "=========================================="

# 1. Compile Release App Bundle
"$PROJECT_DIR/scripts/build_app.sh"

APP_NAME="MacGoesBlurrrr.app"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: $APP_BUNDLE does not exist!"
    exit 1
fi

DMG_VOLNAME="MacGoesBlurrrr"
VERSION=$(defaults read "$APP_BUNDLE/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
FINAL_DMG="$BUILD_DIR/MacGoesBlurrrr-${VERSION}.dmg"
GENERIC_DMG="$BUILD_DIR/MacGoesBlurrrr.dmg"
STAGING_DIR="$BUILD_DIR/dmg_staging"
TEMP_DMG="$BUILD_DIR/temp_MacGoesBlurrrr.dmg"

echo "📦 Preparing DMG staging directory..."
rm -rf "$STAGING_DIR" "$TEMP_DMG" "$FINAL_DMG" "$GENERIC_DMG"
mkdir -p "$STAGING_DIR"

# Copy App to staging
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

# Create Applications symlink for drag-and-drop install
ln -s /Applications "$STAGING_DIR/Applications"

# Volume Icon
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$STAGING_DIR/.VolumeIcon.icns"
    SetFile -c icnC "$STAGING_DIR/.VolumeIcon.icns" 2>/dev/null || true
    SetFile -a C "$STAGING_DIR" 2>/dev/null || true
fi

echo "💽 Creating disk image..."

# Attempt styled DMG layout via temporary writable DMG and AppleScript
USE_FALLBACK=0

# Create temporary RW DMG
hdiutil create -srcfolder "$STAGING_DIR" -volname "$DMG_VOLNAME" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW -size 120M "$TEMP_DMG" >/dev/null 2>&1 || USE_FALLBACK=1

if [ $USE_FALLBACK -eq 0 ]; then
    # Mount RW DMG
    MOUNT_LINE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" 2>/dev/null | grep "/Volumes/$DMG_VOLNAME" || true)
    MOUNT_DIR=$(echo "$MOUNT_LINE" | awk '{print $NF}')

    if [ -n "$MOUNT_DIR" ] && [ -d "$MOUNT_DIR" ]; then
        if [ -f "$MOUNT_DIR/.VolumeIcon.icns" ]; then
            SetFile -a C "$MOUNT_DIR" 2>/dev/null || true
        fi

        # Try configuring Finder window layout
        echo "🎨 Customizing DMG window layout & icon alignment..."
        osascript <<APPLESCRIPT 2>/dev/null || true
tell application "Finder"
    tell disk "$DMG_VOLNAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {300, 150, 840, 500}
        set viewOptions to the icon view options of container window
        set icon size of viewOptions to 96
        set arrangement of viewOptions to not arranged
        try
            set position of item "$APP_NAME" of container window to {135, 175}
        end try
        try
            set position of item "Applications" of container window to {405, 175}
        end try
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT

        # Sync and unmount
        sync || true
        hdiutil detach "$MOUNT_DIR" -quiet || hdiutil detach "$MOUNT_DIR" -force -quiet || true
        sleep 1

        # Convert to compressed read-only DMG
        echo "🗜 Compressing into final release DMG..."
        hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG" >/dev/null
        rm -f "$TEMP_DMG"
    else
        USE_FALLBACK=1
    fi
fi

# Fallback direct creation if RW mounting/osascript failed
if [ $USE_FALLBACK -eq 1 ] || [ ! -f "$FINAL_DMG" ]; then
    echo "⚠️ Falling back to direct UDZO creation..."
    rm -f "$TEMP_DMG"
    hdiutil create -volname "$DMG_VOLNAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$FINAL_DMG" >/dev/null
fi

# Create convenient GlassScreen.dmg alias / hardlink
cp "$FINAL_DMG" "$GENERIC_DMG"

# Clean up staging
rm -rf "$STAGING_DIR"

echo "=========================================="
echo "🎉 DMG successfully built!"
echo "📁 Versioned DMG: $FINAL_DMG"
echo "📁 Latest DMG:    $GENERIC_DMG"
echo "Size: $(ls -lh "$FINAL_DMG" | awk '{print $5}')"
echo "=========================================="
