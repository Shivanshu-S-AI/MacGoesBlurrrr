import AppKit
import Combine

@MainActor
public final class GlassOverlayController {
    public static let shared = GlassOverlayController()

    private var windows: [GlassOverlayWindow] = []
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupObservers()
    }

    private func setupObservers() {
        // Observe display changes (monitors plugged/unplugged, resolution changes)
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreensChanged()
            }
        }

        // Observe Settings changes
        let settings = GlassSettings.shared
        settings.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.syncWithSettings()
                }
            }
            .store(in: &cancellables)
    }

    public func syncWithSettings() {
        let settings = GlassSettings.shared
        if settings.isBlurActive {
            showOverlays()
        } else {
            hideOverlays()
        }
    }

    public func showOverlays() {
        let settings = GlassSettings.shared
        let targetScreens = settings.allMonitors ? NSScreen.screens : [NSScreen.main ?? NSScreen.screens[0]]

        // If windows count or screens changed, rebuild windows
        if windows.count != targetScreens.count {
            destroyAllWindows()
            for screen in targetScreens {
                let frame = calculateOverlayFrame(for: screen, coverDock: settings.coverDock, blurMenu: settings.blurMenu)
                let window = GlassOverlayWindow(screen: screen, frame: frame)
                window.updateAppearance(settings: settings)
                window.animateFadeIn()
                windows.append(window)
            }
        } else {
            // Update existing windows
            for (index, window) in windows.enumerated() {
                if index < targetScreens.count {
                    let screen = targetScreens[index]
                    let frame = calculateOverlayFrame(for: screen, coverDock: settings.coverDock, blurMenu: settings.blurMenu)
                    window.setFrame(frame, display: true)
                    window.updateAppearance(settings: settings)
                    if window.alphaValue < 1.0 {
                        window.animateFadeIn()
                    }
                }
            }
        }
    }

    public func hideOverlays() {
        for window in windows {
            window.animateFadeOut()
        }
    }

    private func handleScreensChanged() {
        let settings = GlassSettings.shared
        if settings.isBlurActive {
            destroyAllWindows()
            showOverlays()
        }
    }

    private func destroyAllWindows() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
    }

    private func calculateOverlayFrame(for screen: NSScreen, coverDock: Bool, blurMenu: Bool) -> NSRect {
        // If blurMenu is enabled, extend up to the top of the physical display (screen.frame.maxY).
        // Otherwise, stop beneath the macOS menu bar (screen.visibleFrame.maxY).
        let topY = blurMenu ? screen.frame.maxY : screen.visibleFrame.maxY
        let bottomY = coverDock ? screen.frame.minY : screen.visibleFrame.minY
        let height = max(0, topY - bottomY)

        return NSRect(
            x: screen.frame.minX,
            y: bottomY,
            width: screen.frame.width,
            height: height
        )
    }
}
