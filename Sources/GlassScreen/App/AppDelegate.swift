import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static let notificationToggle = Notification.Name("com.pleasedontlook.glassscreen.toggle")
    public static let notificationBlur = Notification.Name("com.pleasedontlook.glassscreen.blur")
    public static let notificationUnblur = Notification.Name("com.pleasedontlook.glassscreen.unblur")
    public static let notificationPreset = Notification.Name("com.pleasedontlook.glassscreen.preset")
    public static let notificationRandomPreset = Notification.Name("com.pleasedontlook.glassscreen.random")
    public static let notificationShowUI = Notification.Name("com.pleasedontlook.glassscreen.showUI")
    public static let notificationBlurMenu = Notification.Name("com.pleasedontlook.glassscreen.blurMenu")
    public static let notificationQuit = Notification.Name("com.pleasedontlook.glassscreen.quit")

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as menu bar accessory (no dock icon, stays unobtrusive)
        NSApp.setActivationPolicy(.accessory)

        // Setup Menu Bar Extra
        MenuBarController.shared.setup()

        // Setup Global HotKeys
        // ⌥⌘B: blurs with random style or unblurs
        HotKeyService.shared.onHotKeyTriggered = {
            GlassSettings.shared.triggerShortcutBlur()
        }
        // ⌥⇧⌘B: instant shuffle to new random style
        HotKeyService.shared.onShuffleHotKeyTriggered = {
            GlassSettings.shared.shuffleToRandomPreset()
        }
        HotKeyService.shared.registerDefaultHotKey()

        // Setup IPC & Distributed Notifications
        setupDistributedNotifications()

        // Setup Apple URL Scheme handler
        setupURLHandler()

        // Initial overlay setup
        GlassOverlayController.shared.syncWithSettings()

        // Setup Intelligent Idle Detection Service (Auto-Blur & Wake on input)
        IdleBlurService.shared.start()
    }

    private func setupDistributedNotifications() {
        let center = DistributedNotificationCenter.default()

        center.addObserver(forName: AppDelegate.notificationToggle, object: nil, queue: .main) { _ in
            Task { @MainActor in
                GlassSettings.shared.triggerShortcutBlur()
            }
        }

        center.addObserver(forName: AppDelegate.notificationRandomPreset, object: nil, queue: .main) { _ in
            Task { @MainActor in
                GlassSettings.shared.shuffleToRandomPreset()
            }
        }

        center.addObserver(forName: AppDelegate.notificationBlur, object: nil, queue: .main) { _ in
            Task { @MainActor in
                GlassSettings.shared.isBlurActive = true
            }
        }

        center.addObserver(forName: AppDelegate.notificationUnblur, object: nil, queue: .main) { _ in
            Task { @MainActor in
                GlassSettings.shared.isBlurActive = false
            }
        }

        center.addObserver(forName: AppDelegate.notificationPreset, object: nil, queue: .main) { note in
            if let presetName = note.userInfo?["name"] as? String {
                Task { @MainActor in
                    GlassSettings.shared.selectPreset(byIdOrName: presetName)
                }
            }
        }

        center.addObserver(forName: AppDelegate.notificationShowUI, object: nil, queue: .main) { _ in
            Task { @MainActor in
                MenuBarController.shared.togglePopover(nil)
            }
        }

        center.addObserver(forName: AppDelegate.notificationBlurMenu, object: nil, queue: .main) { note in
            let enabled = note.userInfo?["enabled"] as? Bool
            Task { @MainActor in
                if let enabled = enabled {
                    GlassSettings.shared.blurMenu = enabled
                } else {
                    GlassSettings.shared.blurMenu.toggle()
                }
            }
        }

        center.addObserver(forName: AppDelegate.notificationQuit, object: nil, queue: .main) { _ in
            Task { @MainActor in
                NSApp.terminate(nil)
            }
        }
    }

    private func setupURLHandler() {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    @objc private func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else { return }

        let host = url.host?.lowercased() ?? url.path.lowercased()

        if host.contains("random") || host.contains("shuffle") {
            GlassSettings.shared.shuffleToRandomPreset()
        } else if host.contains("toggle") {
            GlassSettings.shared.triggerShortcutBlur()
        } else if host.contains("blur-menu") || host.contains("menu") {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItem = components.queryItems?.first(where: { $0.name == "enabled" || $0.name == "blur" }),
               let value = queryItem.value {
                GlassSettings.shared.blurMenu = (value.lowercased() == "true" || value == "1" || value == "yes")
            } else {
                GlassSettings.shared.blurMenu.toggle()
            }
        } else if host.contains("blur") {
            GlassSettings.shared.isBlurActive = true
        } else if host.contains("unblur") {
            GlassSettings.shared.isBlurActive = false
        } else if host.contains("preset") {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItem = components.queryItems?.first(where: { $0.name == "name" || $0.name == "id" }),
               let value = queryItem.value {
                GlassSettings.shared.selectPreset(byIdOrName: value)
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        IdleBlurService.shared.stop()
        HotKeyService.shared.unregister()
        GlassOverlayController.shared.hideOverlays()
    }
}
