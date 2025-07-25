// Configuration template
// Copy this to config.swift and customize your settings

struct VPNConfig {
    static let vpnName = "Your VPN Name Here"  // Find with: networksetup -listallnetworkservices
    static let bundleIdentifier = "com.yourname.vpnicon"
    
    // Menu bar icons - customize these SF Symbols!
    static let connectedIcon = "house.fill"     // Icon when VPN is connected
    static let disconnectedIcon = "house"       // Icon when VPN is disconnected
    
    // Popular alternatives:
    // Shield: "shield.fill" / "shield"
    // Lock: "lock.circle.fill" / "lock.circle"  
    // Network: "network" / "network.slash"
    // Privacy: "eye.slash.fill" / "eye.slash"
    // Dot: "record.circle.fill" / "record.circle"
    // Globe: "globe" / "globe.badge.chevron.backward"
}
