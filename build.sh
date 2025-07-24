#!/bin/bash

APP_NAME="VPN Icon"
BUNDLE_ID="com.yourname.vpnicon"
INSTALL_PATH="/Applications"

echo "🔨 Building $APP_NAME..."

# Clean previous builds
rm -rf .build
rm -rf "$APP_NAME.app"

# Build with Swift Package Manager
swift build --configuration release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "📦 Creating app bundle..."

# Create app bundle structure
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

# Copy executable (Swift Package Manager creates it with the package name)
cp ".build/release/VPN Icon" "$APP_NAME.app/Contents/MacOS/"

# Copy Info.plist
cp "Info.plist" "$APP_NAME.app/Contents/"

# Copy app icon
cp "Resources/VPN Icon.icns" "$APP_NAME.app/Contents/Resources/"

# Make executable
chmod +x "$APP_NAME.app/Contents/MacOS/VPN Icon"

echo "✅ Build complete!"
echo "🚀 To run: open '$APP_NAME.app'"
echo "📁 To install: sudo cp -r '$APP_NAME.app' '$INSTALL_PATH/'"

# Offer to install automatically
read -p "Install to $INSTALL_PATH now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo cp -r "$APP_NAME.app" "$INSTALL_PATH/"
    echo "✅ Installed to $INSTALL_PATH/$APP_NAME.app"
    echo "🚀 Launch with: open '$INSTALL_PATH/$APP_NAME.app'"
fi
