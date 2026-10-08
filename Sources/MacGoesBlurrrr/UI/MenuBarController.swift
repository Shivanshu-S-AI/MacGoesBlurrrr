import AppKit
import SwiftUI
import Combine

@MainActor
public final class MenuBarController: NSObject, NSPopoverDelegate {
    public static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
    }

    public func setup() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem = statusItem

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateStatusIcon(isActive: GlassSettings.shared.isBlurActive)
        }

        // Setup Popover
        let popover = NSPopover()
        let popoverSize = NSSize(width: 380, height: 580)
        popover.contentSize = popoverSize
        popover.behavior = .transient
        popover.animates = true

        let hostingController = NSHostingController(rootView: PopoverContentView())
        hostingController.preferredContentSize = popoverSize
        popover.contentViewController = hostingController
        popover.delegate = self
        self.popover = popover

        // Observe settings changes
        GlassSettings.shared.$isBlurActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.updateStatusIcon(isActive: isActive)
            }
            .store(in: &cancellables)

        GlassSettings.shared.$selectedPresetId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusIcon(isActive: GlassSettings.shared.isBlurActive)
            }
            .store(in: &cancellables)
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        // Option-Click or Right-Click instantly toggles blur!
        if event.modifierFlags.contains(.option) || event.type == .rightMouseUp {
            GlassSettings.shared.triggerShortcutBlur()
            return
        }

        // Normal left-click toggles Popover
        togglePopover(sender)
    }

    public func togglePopover(_ sender: Any?) {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    public func updateStatusIcon(isActive: Bool) {
        guard let button = statusItem?.button else { return }

        let preset = GlassSettings.shared.currentPreset
        let primaryColor = preset.tintColors.first?.nsColor ?? NSColor.systemCyan

        let icon = createVectorStatusIcon(isActive: isActive, accentColor: primaryColor)
        button.image = icon
        button.toolTip = isActive ? "MacGoesBlurrrr (\(preset.name)) • ⌥⌘B to unblur, ⌥⇧⌘B to shuffle" : "MacGoesBlurrrr (Clear) • ⌥⌘B to blur (random style), ⌥-Click to toggle"
    }

    private func createVectorStatusIcon(isActive: Bool, accentColor: NSColor) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            // Outer Frosted Glass Ring
            let circleRect = NSRect(x: 2.0, y: 2.0, width: 14.0, height: 14.0)
            let path = NSBezierPath(ovalIn: circleRect)
            path.lineWidth = 1.5

            if isActive {
                // Active Glowing State matching preset color
                accentColor.setStroke()
                path.stroke()

                // Radiant Core
                let innerRect = NSRect(x: 5.5, y: 5.5, width: 7.0, height: 7.0)
                let innerPath = NSBezierPath(ovalIn: innerRect)
                accentColor.withAlphaComponent(0.85).setFill()
                innerPath.fill()

                // Micro Specular Spark
                let spark = NSBezierPath(ovalIn: NSRect(x: 9.0, y: 9.0, width: 2.0, height: 2.0))
                NSColor.white.setFill()
                spark.fill()
            } else {
                // Inactive Elegant Outlined Lens
                NSColor.labelColor.setStroke()
                path.stroke()

                // Center aperture dot
                let dotRect = NSRect(x: 7.5, y: 7.5, width: 3.0, height: 3.0)
                let dot = NSBezierPath(ovalIn: dotRect)
                NSColor.labelColor.withAlphaComponent(0.6).setFill()
                dot.fill()
            }
            return true
        }

        image.isTemplate = !isActive
        return image
    }
}
