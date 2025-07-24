# VPN Icon

A clean and minimal macOS menu bar app for controlling VPN connections with a simple house icon interface.

## Features

- **Clean house icon** that changes between empty (disconnected) and filled (connected)
- **Left click**: Show status menu with connection info
- **Right click**: Toggle VPN connection instantly
- **System integration**: Direct control via macOS networksetup
- **Minimal footprint**: Lightweight app that runs silently in the menu bar
- **Auto-detection**: Monitors VPN status every 2 seconds

## Screenshots

The app shows a house outline when disconnected and a filled house when connected, perfectly integrated with your menu bar theme.

## Installation

### Option 1: Download Release
1. Download the latest release from the [Releases page](../../releases)
2. Move `VPN Icon.app` to your Applications folder
3. Add to Login Items in System Settings for automatic startup

### Option 2: Build from Source

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/vpn-icon.git
   cd vpn-icon
   ```

2. **Configure your VPN name** in `Sources/main.swift`:
   ```swift
   struct VPNConfig {
       static let vpnName = "Your VPN Name Here"  // Change this to match your VPN
   }
   ```

3. **Build and install:**
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
   
   Choose `y` when prompted to install to Applications.

4. **Set up auto-start:**
   - System Settings → General → Login Items
   - Add "VPN Icon" to open at login

## Configuration

### Finding Your VPN Name

To find the exact name of your VPN service:

```bash
networksetup -listallnetworkservices
```

Look for your VPN in the list and use that exact name in the `VPNConfig.vpnName` setting.

### Customizing Icons

The app uses SF Symbols for the menu bar icons. You can change them in `Sources/main.swift`:

```swift
// Current: house / house.fill
private let connectedIcon = NSImage(systemSymbolName: "house.fill", ...)
private let disconnectedIcon = NSImage(systemSymbolName: "house", ...)

// Alternative options:
// shield / shield.fill
// lock.circle / lock.circle.fill  
// network / network.slash
```

## Requirements

- macOS 12.0 or later
- Swift 5.9+
- VPN configured in System Settings/Network Preferences
- Xcode Command Line Tools for building from source

## How It Works

The app uses macOS's built-in `networksetup` command to:
- Check VPN connection status via `-showpppoestatus`
- Connect VPNs using `-connectpppoeservice`
- Disconnect VPNs using `-disconnectpppoeservice`

This provides reliable system-level integration without requiring additional permissions or third-party dependencies.

## Development

### Project Structure

```
vpn-icon/
├── Sources/
│   └── main.swift           # Main application code
├── Resources/
│   └── VPN Icon.icns        # App icon (from Wireless Diagnostics)
├── Package.swift            # Swift Package Manager config
├── Info.plist              # App metadata and permissions
├── build.sh                # Build and installation script
└── README.md               # This file
```

### Building for Development

```bash
# Quick test run
swift run

# Build release version
swift build --configuration release

# Create app bundle
./build.sh
```

## Troubleshooting

### VPN Not Toggling
- Verify your VPN name matches exactly (case-sensitive)
- Check that your VPN is configured in System Settings
- Ensure the app has necessary permissions

### Menu Bar Icon Not Updating
- The app checks status every 2 seconds
- Try right-clicking to force a manual toggle
- Check Activity Monitor to ensure the app is running

### Permission Issues
- Some VPN operations may require accessibility permissions
- System Settings → Privacy & Security → Accessibility
- Add "VPN Icon" or Terminal (if running via `swift run`)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- App icon: Wireless Diagnostics.app (Apple Inc.)
- Menu bar icons: SF Symbols (Apple Inc.)
- Built with Swift and love ❤️

---

**Note**: This app is designed for personal use with VPN services configured through macOS System Settings. It works with most standard VPN protocols (IKEv2, L2TP, PPTP) but may not work with all third-party VPN clients that don't integrate with the system.