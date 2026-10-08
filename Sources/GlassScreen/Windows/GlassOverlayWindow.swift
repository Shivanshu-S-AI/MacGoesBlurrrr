import AppKit

@MainActor
public final class GlassOverlayWindow: NSWindow {
    public let glassContentView: GlassContentView
    public let targetScreen: NSScreen

    public init(screen: NSScreen, frame: NSRect) {
        self.targetScreen = screen
        self.glassContentView = GlassContentView(frame: NSRect(origin: .zero, size: frame.size))

        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Level 26 sits directly above menu bar (24) and status items (25) to veil them.
        // Level 23 sits directly beneath menu bar (24) to leave it untouched.
        self.level = GlassSettings.shared.blurMenu ? NSWindow.Level(rawValue: 26) : NSWindow.Level(rawValue: 23)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.contentView = glassContentView

        glassContentView.onDoubleClicked = {
            Task { @MainActor in
                GlassSettings.shared.toggleBlur()
            }
        }
    }

    public func updateAppearance(settings: GlassSettings) {
        let preset = settings.currentPreset
        self.ignoresMouseEvents = settings.isClickThrough

        let targetLevel = settings.blurMenu ? NSWindow.Level(rawValue: 26) : NSWindow.Level(rawValue: 23)
        if self.level != targetLevel {
            self.level = targetLevel
            self.orderFrontRegardless()
        }

        // Apply dynamic CGS WindowServer blur radius directly to window compositor
        let cgsSuccess = CGSBlurBridge.shared.setBlurRadius(for: self, radius: settings.blurRadius)

        // Update glass content layers with vibrant colors and translucent frost
        glassContentView.apply(preset: preset, settings: settings, cgsBlurActive: cgsSuccess)
    }

    public func animateFadeIn(duration: TimeInterval = 0.25) {
        self.alphaValue = 0.0
        self.orderFront(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().alphaValue = 1.0
        }
    }

    public func animateFadeOut(duration: TimeInterval = 0.20, completion: (@MainActor @Sendable () -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            Task { @MainActor in
                self.orderOut(nil)
                completion?()
            }
        })
    }
}
