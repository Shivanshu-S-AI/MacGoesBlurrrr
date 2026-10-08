import AppKit

let args = CommandLine.arguments

func printUsage() {
    print("""
    🤫 Mac My Business - macOS Menu Bar Frosted Glass Privacy Shield

    Usage:
      MacMyBusiness [options]
      mmb [options]

    Options:
      --toggle             Toggle frosted glass privacy shield on / off
      --blur               Turn privacy veil ON
      --unblur             Turn privacy veil OFF
      --random, --shuffle  Switch to a random glass style
      --preset <name>      Switch to a glassmorphism preset (e.g. obsidian, cyberpunk, frost)
      --list-presets       List all available presets
      --blur-menu [on|off] Toggle or set macOS menu bar blurring
      --no-blur-menu       Disable macOS menu bar blurring
      --status             Print current shield state
      --quit               Quit the running Mac My Business app
      -h, --help           Show this help message

    Global Keyboard Shortcut:
      ⌥⌘B  (Option + Command + B) to toggle privacy shield (picks random style on activation)
      ⌥⇧⌘B (Option + Shift + Command + B) to instantly shuffle style
    """)
}

func sendNotification(name: String, userInfo: [String: Any]? = nil) {
    DistributedNotificationCenter.default().postNotificationName(
        NSNotification.Name(name),
        object: nil,
        userInfo: userInfo,
        deliverImmediately: true
    )
}

if args.contains("-h") || args.contains("--help") {
    printUsage()
    exit(0)
}

if args.contains("--list-presets") {
    print("\n💎 Available Glassmorphism Presets:")
    for preset in GlassPreset.allPresets {
        print("  • \(preset.name.padding(toLength: 22, withPad: " ", startingAt: 0)) [\(preset.id)] - \(preset.tagline)")
    }
    print("")
    exit(0)
}

if args.contains("--toggle") {
    sendNotification(name: "com.macmybusiness.app.toggle")
    print("Sent toggle signal to Mac My Business.")
    exit(0)
}

if args.contains("--blur") {
    sendNotification(name: "com.macmybusiness.app.blur")
    print("Sent veil ON signal to Mac My Business.")
    exit(0)
}

if args.contains("--unblur") {
    sendNotification(name: "com.macmybusiness.app.unblur")
    print("Sent veil OFF signal to Mac My Business.")
    exit(0)
}

if args.contains("--random") || args.contains("--shuffle") {
    sendNotification(name: "com.macmybusiness.app.random")
    print("Sent shuffle to random preset signal to Mac My Business.")
    exit(0)
}

if let presetIdx = args.firstIndex(of: "--preset"), presetIdx + 1 < args.count {
    let presetName = args[presetIdx + 1]
    sendNotification(name: "com.macmybusiness.app.preset", userInfo: ["name": presetName])
    print("Sent switch to preset '\(presetName)' signal to Mac My Business.")
    exit(0)
}

if args.contains("--blur-menu") {
    if let idx = args.firstIndex(of: "--blur-menu"), idx + 1 < args.count {
        let val = args[idx + 1].lowercased()
        let enable = (val == "true" || val == "on" || val == "1" || val == "yes")
        sendNotification(name: "com.macmybusiness.app.blurMenu", userInfo: ["enabled": enable])
        print("Sent blur menu bar \(enable ? "ON" : "OFF") signal to Mac My Business.")
    } else {
        sendNotification(name: "com.macmybusiness.app.blurMenu")
        print("Sent toggle blur menu bar signal to Mac My Business.")
    }
    exit(0)
}

if args.contains("--no-blur-menu") {
    sendNotification(name: "com.macmybusiness.app.blurMenu", userInfo: ["enabled": false])
    print("Sent blur menu bar OFF signal to Mac My Business.")
    exit(0)
}

if args.contains("--quit") {
    sendNotification(name: "com.macmybusiness.app.quit")
    print("Sent quit signal to Mac My Business.")
    exit(0)
}

if args.contains("--status") {
    let isActive = UserDefaults.standard.bool(forKey: "GlassScreen_isBlurActive")
    let preset = UserDefaults.standard.string(forKey: "GlassScreen_selectedPresetId") ?? "sakura_pink"
    let blurMenu = UserDefaults.standard.object(forKey: "GlassScreen_blurMenu") != nil ? UserDefaults.standard.bool(forKey: "GlassScreen_blurMenu") : true
    let autoIdle = UserDefaults.standard.object(forKey: "GlassScreen_autoBlurOnIdle") != nil ? UserDefaults.standard.bool(forKey: "GlassScreen_autoBlurOnIdle") : true
    let timeout = UserDefaults.standard.double(forKey: "GlassScreen_idleTimeoutMinutes")
    let timeoutStr = timeout > 0 ? "\(timeout)m" : "2m"
    let idleStyle = UserDefaults.standard.string(forKey: "GlassScreen_idlePresetId") ?? "current"
    print("Mac My Business Status: \(isActive ? "VEIL ACTIVE 🟢" : "CLEAR ⚪️") | Preset: [\(preset)] | Menu Blur: \(blurMenu ? "ON" : "OFF") | Auto-Idle: \(autoIdle ? "ON (\(timeoutStr), style: \(idleStyle))" : "OFF")")
    exit(0)
}

// Check for single instance
let currentPID = ProcessInfo.processInfo.processIdentifier
let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.macmybusiness.app")
let otherInstances = runningApps.filter { $0.processIdentifier != currentPID }

if !otherInstances.isEmpty {
    // Already running, show UI
    sendNotification(name: "com.macmybusiness.app.showUI")
    print("Mac My Business is already running in menu bar. Opened control panel.")
    exit(0)
}

// Start normal application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
