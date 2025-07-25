# VPN Icon

Simple macOS menu bar app to control your VPN with one click.

## Installation

**Download:** Get the latest version from [Releases](../../releases)

1. Download `VPN-Icon-v2.0.zip`
2. Extract and drag `VPN Icon.app` to Applications
3. Launch the app

**Build from source:**
```bash
git clone https://github.com/globuzzz2000/vpn-icon.git
cd vpn-icon
./build.sh
```

## Usage

1. **First time:** Left-click menu bar icon → "Configure..."
2. **Select your VPN** from the dropdown (auto-detected)
3. **Choose icons** from 16 available options
4. **Save** your settings

**Daily use:**
- **Right-click:** Toggle VPN on/off
- **Left-click:** Show status menu

## Features

- GUI configuration (no code editing)
- Auto-detects VPN services
- 16 customizable SF Symbol icons
- Persistent settings
- Lightweight and fast

## Requirements

- macOS 12+
- VPN configured in System Settings
- Works with IKEv2, L2TP, PPTP

## Project Structure

```
vpn-icon/
├── Sources/
│   └── main.swift           # Complete app with GUI config
├── Resources/
│   └── VPN Icon.icns        # App icon
├── Package.swift            # Swift Package Manager
├── Info.plist              # App metadata
├── build.sh                # Build script
└── README.md               # This file
```

## Development

```bash
# Test run
swift run

# Build release
./build.sh

# The app uses:
# - UserDefaults for settings storage
# - NSStatusItem for menu bar integration
# - networksetup commands for VPN control
# - Native Cocoa UI for configuration
```

## License

MIT License - See [LICENSE](LICENSE) for details.