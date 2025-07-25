import Cocoa
import Network

// MARK: - Configuration
// Update these values for your setup
struct VPNConfig {
    static let vpnName = "Home VPN"  // Change this to your VPN name
    static let bundleIdentifier = "com.yourname.vpnicon"
    
    // Menu bar icons - you can customize these!
    static let connectedIcon = "house.fill"     // Icon when VPN is connected
    static let disconnectedIcon = "house"       // Icon when VPN is disconnected
    
    // Alternative icon options:
    // Shield: "shield.fill" / "shield"
    // Lock: "lock.circle.fill" / "lock.circle"  
    // Network: "network" / "network.slash"
    // Privacy: "eye.slash.fill" / "eye.slash"
    // Dot: "record.circle.fill" / "record.circle"
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    
    // Icons for different states with proper styling
    private let connectedIcon: NSImage? = {
        let image = NSImage(systemSymbolName: VPNConfig.connectedIcon, accessibilityDescription: "VPN Connected")
        image?.isTemplate = true
        return image
    }()
    
    private let disconnectedIcon: NSImage? = {
        let image = NSImage(systemSymbolName: VPNConfig.disconnectedIcon, accessibilityDescription: "VPN Disconnected")
        image?.isTemplate = true
        return image
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Configure the button
        if let button = statusItem.button {
            button.image = disconnectedIcon
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
        }
        
        // Start monitoring VPN status
        startMonitoring()
        
        // Hide dock icon (menu bar only app)
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .leftMouseUp {
            // Left click - show menu
            showMenu()
        } else if event.type == .rightMouseUp {
            // Right click - toggle VPN
            toggleVPN()
        }
    }
    
    @objc private func toggleVPN() {
        toggleVPNDirect()
    }
    
    private func toggleVPNDirect() {
        let vpnName = VPNConfig.vpnName
        
        // Check current status first
        let statusTask = Process()
        let statusPipe = Pipe()
        statusTask.standardOutput = statusPipe
        statusTask.launchPath = "/usr/sbin/networksetup"
        statusTask.arguments = ["-showpppoestatus", vpnName]
        
        do {
            try statusTask.run()
            statusTask.waitUntilExit()
            
            let data = statusPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            // Toggle based on current status
            let toggleTask = Process()
            toggleTask.launchPath = "/usr/sbin/networksetup"
            
            if output.trimmingCharacters(in: .whitespacesAndNewlines) == "connected" {
                // Disconnect
                toggleTask.arguments = ["-disconnectpppoeservice", vpnName]
            } else {
                // Connect
                toggleTask.arguments = ["-connectpppoeservice", vpnName]
            }
            
            try toggleTask.run()
            toggleTask.waitUntilExit()
            
            // Update icon after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.updateIcon()
            }
            
        } catch {
            // Silent error handling
        }
    }
    
    private func showMenu() {
        let menu = NSMenu()
        
        let statusMenuItem = NSMenuItem(title: isVPNConnected() ? "Connected" : "Disconnected", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let toggleItem = NSMenuItem(title: isVPNConnected() ? "Disconnect" : "Connect", action: #selector(toggleVPN), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    private func startMonitoring() {
        // Check VPN status every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateIcon()
        }
        updateIcon() // Initial update
    }
    
    private func updateIcon() {
        // Do the VPN check on a background queue since it involves network operations
        DispatchQueue.global(qos: .background).async {
            let connected = self.isVPNConnected()
            
            // Update UI on main queue
            DispatchQueue.main.async {
                guard let button = self.statusItem.button else { return }
                
                if connected {
                    button.image = self.connectedIcon
                } else {
                    button.image = self.disconnectedIcon
                }
            }
        }
    }
    
    private func isVPNConnected() -> Bool {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-showpppoestatus", VPNConfig.vpnName]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            let isConnected = output.trimmingCharacters(in: .whitespacesAndNewlines) == "connected"
            return isConnected
        } catch {
            return false
        }
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// This replaces @main
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
