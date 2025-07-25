import Cocoa
import Network

// MARK: - Configuration Storage
class VPNConfig {
    static let shared = VPNConfig()
    
    private let defaults = UserDefaults.standard
    
    var vpnName: String {
        get { defaults.string(forKey: "vpnName") ?? "Home VPN" }
        set { defaults.set(newValue, forKey: "vpnName") }
    }
    
    var connectedIcon: String {
        get { defaults.string(forKey: "connectedIcon") ?? "house.fill" }
        set { defaults.set(newValue, forKey: "connectedIcon") }
    }
    
    var disconnectedIcon: String {
        get { defaults.string(forKey: "disconnectedIcon") ?? "house" }
        set { defaults.set(newValue, forKey: "disconnectedIcon") }
    }
    
    private init() {}
}

// MARK: - Configuration Window Controller
class ConfigurationWindowController: NSWindowController {
    private var vpnPopup: NSPopUpButton!
    private var connectedIconPopup: NSPopUpButton!
    private var disconnectedIconPopup: NSPopUpButton!
    private var previewConnected: NSImageView!
    private var previewDisconnected: NSImageView!
    
    // Icon options with display names
    private let iconOptions: [(name: String, symbol: String)] = [
        ("House", "house"),
        ("House Filled", "house.fill"),
        ("Shield", "shield"),
        ("Shield Filled", "shield.fill"),
        ("Lock Circle", "lock.circle"),
        ("Lock Circle Filled", "lock.circle.fill"),
        ("Network", "network"),
        ("Network Slash", "network.slash"),
        ("Eye Slash", "eye.slash"),
        ("Eye Slash Filled", "eye.slash.fill"),
        ("Record Circle", "record.circle"),
        ("Record Circle Filled", "record.circle.fill"),
        ("Globe", "globe"),
        ("Globe with Chevron", "globe.badge.chevron.backward"),
        ("Wifi", "wifi"),
        ("Antenna", "antenna.radiowaves.left.and.right")
    ]
    
    override func loadWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "VPN Icon Configuration"
        window.center()
        
        self.window = window
        setupUI()
        loadCurrentSettings()
    }
    
    private func setupUI() {
        guard let window = window else { return }
        
        let contentView = NSView()
        window.contentView = contentView
        
        // VPN Selection
        let vpnLabel = NSTextField(labelWithString: "VPN Connection:")
        vpnLabel.font = NSFont.boldSystemFont(ofSize: 13)
        
        vpnPopup = NSPopUpButton()
        vpnPopup.target = self
        vpnPopup.action = #selector(vpnSelectionChanged)
        loadVPNServices()
        
        let refreshButton = NSButton(title: "Refresh", target: self, action: #selector(refreshVPNList))
        refreshButton.bezelStyle = .rounded
        
        // Connected Icon Selection
        let connectedLabel = NSTextField(labelWithString: "Connected Icon:")
        connectedLabel.font = NSFont.boldSystemFont(ofSize: 13)
        
        connectedIconPopup = NSPopUpButton()
        connectedIconPopup.target = self
        connectedIconPopup.action = #selector(connectedIconChanged)
        setupIconPopup(connectedIconPopup)
        
        previewConnected = NSImageView()
        previewConnected.imageScaling = .scaleProportionallyUpOrDown
        
        // Disconnected Icon Selection
        let disconnectedLabel = NSTextField(labelWithString: "Disconnected Icon:")
        disconnectedLabel.font = NSFont.boldSystemFont(ofSize: 13)
        
        disconnectedIconPopup = NSPopUpButton()
        disconnectedIconPopup.target = self
        disconnectedIconPopup.action = #selector(disconnectedIconChanged)
        setupIconPopup(disconnectedIconPopup)
        
        previewDisconnected = NSImageView()
        previewDisconnected.imageScaling = .scaleProportionallyUpOrDown
        
        // Buttons
        let saveButton = NSButton(title: "Save", target: self, action: #selector(saveConfiguration))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelConfiguration))
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        
        // Layout
        contentView.addSubview(vpnLabel)
        contentView.addSubview(vpnPopup)
        contentView.addSubview(refreshButton)
        contentView.addSubview(connectedLabel)
        contentView.addSubview(connectedIconPopup)
        contentView.addSubview(previewConnected)
        contentView.addSubview(disconnectedLabel)
        contentView.addSubview(disconnectedIconPopup)
        contentView.addSubview(previewDisconnected)
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)
        
        // Disable autoresizing masks
        [vpnLabel, vpnPopup, refreshButton, connectedLabel, connectedIconPopup, previewConnected,
         disconnectedLabel, disconnectedIconPopup, previewDisconnected, saveButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Auto Layout
        NSLayoutConstraint.activate([
            // VPN Section
            vpnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            vpnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            vpnPopup.topAnchor.constraint(equalTo: vpnLabel.bottomAnchor, constant: 8),
            vpnPopup.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            vpnPopup.widthAnchor.constraint(equalToConstant: 300),
            
            refreshButton.centerYAnchor.constraint(equalTo: vpnPopup.centerYAnchor),
            refreshButton.leadingAnchor.constraint(equalTo: vpnPopup.trailingAnchor, constant: 10),
            
            // Connected Icon Section
            connectedLabel.topAnchor.constraint(equalTo: vpnPopup.bottomAnchor, constant: 30),
            connectedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            connectedIconPopup.topAnchor.constraint(equalTo: connectedLabel.bottomAnchor, constant: 8),
            connectedIconPopup.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            connectedIconPopup.widthAnchor.constraint(equalToConstant: 200),
            
            previewConnected.centerYAnchor.constraint(equalTo: connectedIconPopup.centerYAnchor),
            previewConnected.leadingAnchor.constraint(equalTo: connectedIconPopup.trailingAnchor, constant: 20),
            previewConnected.widthAnchor.constraint(equalToConstant: 24),
            previewConnected.heightAnchor.constraint(equalToConstant: 24),
            
            // Disconnected Icon Section
            disconnectedLabel.topAnchor.constraint(equalTo: connectedIconPopup.bottomAnchor, constant: 20),
            disconnectedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            disconnectedIconPopup.topAnchor.constraint(equalTo: disconnectedLabel.bottomAnchor, constant: 8),
            disconnectedIconPopup.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            disconnectedIconPopup.widthAnchor.constraint(equalToConstant: 200),
            
            previewDisconnected.centerYAnchor.constraint(equalTo: disconnectedIconPopup.centerYAnchor),
            previewDisconnected.leadingAnchor.constraint(equalTo: disconnectedIconPopup.trailingAnchor, constant: 20),
            previewDisconnected.widthAnchor.constraint(equalToConstant: 24),
            previewDisconnected.heightAnchor.constraint(equalToConstant: 24),
            
            // Buttons
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -10)
        ])
    }
    
    private func setupIconPopup(_ popup: NSPopUpButton) {
        popup.removeAllItems()
        for (name, _) in iconOptions {
            popup.addItem(withTitle: name)
        }
    }
    
    private func loadVPNServices() {
        vpnPopup.removeAllItems()
        
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-listallnetworkservices"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            let services = output.components(separatedBy: .newlines)
                .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0 != "An asterisk (*) denotes that a network service is disabled." }
            
            for service in services {
                vpnPopup.addItem(withTitle: service)
            }
            
            if vpnPopup.numberOfItems == 0 {
                vpnPopup.addItem(withTitle: "No VPN services found")
            }
            
        } catch {
            vpnPopup.addItem(withTitle: "Error loading VPN services")
        }
    }
    
    private func loadCurrentSettings() {
        let config = VPNConfig.shared
        
        // Select current VPN
        vpnPopup.selectItem(withTitle: config.vpnName)
        
        // Select current icons
        if let connectedIndex = iconOptions.firstIndex(where: { $0.symbol == config.connectedIcon }) {
            connectedIconPopup.selectItem(at: connectedIndex)
        }
        
        if let disconnectedIndex = iconOptions.firstIndex(where: { $0.symbol == config.disconnectedIcon }) {
            disconnectedIconPopup.selectItem(at: disconnectedIndex)
        }
        
        updatePreviews()
    }
    
    private func updatePreviews() {
        let connectedIndex = connectedIconPopup.indexOfSelectedItem
        if connectedIndex >= 0 && connectedIndex < iconOptions.count {
            let symbol = iconOptions[connectedIndex].symbol
            let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
            image?.isTemplate = true
            previewConnected.image = image
        }
        
        let disconnectedIndex = disconnectedIconPopup.indexOfSelectedItem
        if disconnectedIndex >= 0 && disconnectedIndex < iconOptions.count {
            let symbol = iconOptions[disconnectedIndex].symbol
            let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
            image?.isTemplate = true
            previewDisconnected.image = image
        }
    }
    
    @objc private func vpnSelectionChanged() {
        // Nothing to do here, just update on save
    }
    
    @objc private func refreshVPNList() {
        loadVPNServices()
    }
    
    @objc private func connectedIconChanged() {
        updatePreviews()
    }
    
    @objc private func disconnectedIconChanged() {
        updatePreviews()
    }
    
    @objc private func saveConfiguration() {
        let config = VPNConfig.shared
        
        if let selectedVPN = vpnPopup.selectedItem?.title,
           selectedVPN != "No VPN services found" && selectedVPN != "Error loading VPN services" {
            config.vpnName = selectedVPN
        }
        
        let connectedIndex = connectedIconPopup.indexOfSelectedItem
        if connectedIndex >= 0 && connectedIndex < iconOptions.count {
            config.connectedIcon = iconOptions[connectedIndex].symbol
        }
        
        let disconnectedIndex = disconnectedIconPopup.indexOfSelectedItem
        if disconnectedIndex >= 0 && disconnectedIndex < iconOptions.count {
            config.disconnectedIcon = iconOptions[disconnectedIndex].symbol
        }
        
        // Notify the app delegate to update
        NotificationCenter.default.post(name: .configurationChanged, object: nil)
        
        window?.close()
    }
    
    @objc private func cancelConfiguration() {
        window?.close()
    }
}

// MARK: - Main App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var configWindowController: ConfigurationWindowController?
    
    // Icons for different states - will be updated from config
    private var connectedIcon: NSImage? {
        let image = NSImage(systemSymbolName: VPNConfig.shared.connectedIcon, accessibilityDescription: "VPN Connected")
        image?.isTemplate = true
        return image
    }
    
    private var disconnectedIcon: NSImage? {
        let image = NSImage(systemSymbolName: VPNConfig.shared.disconnectedIcon, accessibilityDescription: "VPN Disconnected")
        image?.isTemplate = true
        return image
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Configure the button
        updateStatusItemIcon()
        if let button = statusItem.button {
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
        }
        
        // Listen for configuration changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configurationChanged),
            name: .configurationChanged,
            object: nil
        )
        
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
    
    @objc private func showConfiguration() {
        if configWindowController == nil {
            configWindowController = ConfigurationWindowController()
        }
        configWindowController?.loadWindow()
        configWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func configurationChanged() {
        updateStatusItemIcon()
        updateIcon()
    }
    
    private func updateStatusItemIcon() {
        if let button = statusItem.button {
            button.image = disconnectedIcon
        }
    }
    
    private func toggleVPNDirect() {
        let vpnName = VPNConfig.shared.vpnName
        
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
        
        let configItem = NSMenuItem(title: "Configure...", action: #selector(showConfiguration), keyEquivalent: "")
        configItem.target = self
        menu.addItem(configItem)
        
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
        task.arguments = ["-showpppoestatus", VPNConfig.shared.vpnName]
        
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

// MARK: - Extensions
extension Notification.Name {
    static let configurationChanged = Notification.Name("configurationChanged")
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// This replaces @main
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
