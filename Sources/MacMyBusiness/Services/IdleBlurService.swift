import AppKit
import CoreGraphics
import Combine
import SwiftUI

@MainActor
public final class IdleBlurService: ObservableObject {
    public static let shared = IdleBlurService()

    private var idleCheckTimer: Timer?
    private var wakePollingTimer: Timer?
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    private var initialMousePosition: NSPoint = .zero
    private var cancellables = Set<AnyCancellable>()

    @Published public private(set) var currentIdleSeconds: Double = 0.0

    private init() {
        setupSettingsObserver()
    }

    private func setupSettingsObserver() {
        GlassSettings.shared.$autoBlurOnIdle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                if enabled {
                    self?.startIdleTimer()
                } else {
                    self?.stopIdleTimer()
                    self?.stopWakeMonitoring()
                }
            }
            .store(in: &cancellables)

        GlassSettings.shared.$isBlurActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBlurActive in
                guard let self = self else { return }
                // If blur was deactivated externally (e.g. via hotkey or popover), clean up idle wake state
                if !isBlurActive && GlassSettings.shared.isAutoBlurredByIdle {
                    GlassSettings.shared.isAutoBlurredByIdle = false
                    self.stopWakeMonitoring()
                }
            }
            .store(in: &cancellables)
    }

    public func start() {
        if GlassSettings.shared.autoBlurOnIdle {
            startIdleTimer()
        }
    }

    public func stop() {
        stopIdleTimer()
        stopWakeMonitoring()
    }

    private func startIdleTimer() {
        stopIdleTimer()
        // Check system idle time once every second
        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkIdleState()
            }
        }
    }

    private func stopIdleTimer() {
        idleCheckTimer?.invalidate()
        idleCheckTimer = nil
    }

    private func checkIdleState() {
        let settings = GlassSettings.shared
        guard settings.autoBlurOnIdle else { return }

        // CoreGraphics system-wide idle time without requiring Accessibility permissions
        let idleCombined = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        let idleHid = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
        let idleSeconds = min(idleCombined, idleHid)
        self.currentIdleSeconds = idleSeconds

        let timeoutSeconds = settings.idleTimeoutMinutes * 60.0

        // If screen is currently clear and idle exceeded the user timeout:
        if !settings.isBlurActive && idleSeconds >= timeoutSeconds {
            triggerAutoBlur()
        }
    }

    private func triggerAutoBlur() {
        let settings = GlassSettings.shared
        guard !settings.isBlurActive else { return }

        settings.isAutoBlurredByIdle = true

        // Apply desired idle style
        if settings.idlePresetId == "random" {
            settings.selectRandomPreset(excludingCurrent: true)
        } else if settings.idlePresetId == "current" {
            // Keep the user's currently selected desired style
        } else if let preset = GlassPreset.allPresets.first(where: { $0.id == settings.idlePresetId }) {
            settings.selectPreset(preset)
        }

        settings.isBlurActive = true

        startWakeMonitoring()
    }

    private func startWakeMonitoring() {
        stopWakeMonitoring()

        initialMousePosition = NSEvent.mouseLocation

        // 1. Global event monitor: captures mouse movement, clicks, scrolling, keys
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [
                .mouseMoved,
                .leftMouseDown,
                .rightMouseDown,
                .otherMouseDown,
                .scrollWheel,
                .keyDown,
                .flagsChanged
            ]
        ) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleUserInputEvent(event)
            }
        }

        // 2. Local event monitor: catches events sent to GlassScreen windows
        localEventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [
                .mouseMoved,
                .leftMouseDown,
                .rightMouseDown,
                .otherMouseDown,
                .scrollWheel,
                .keyDown,
                .flagsChanged
            ]
        ) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleUserInputEvent(event)
            }
            return event
        }

        // 3. Ultra-fast polling timer (every 60ms) to ensure zero-latency detection across mouse & HID
        wakePollingTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkWakeConditions()
            }
        }
    }

    private func stopWakeMonitoring() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        wakePollingTimer?.invalidate()
        wakePollingTimer = nil
    }

    private func handleUserInputEvent(_ event: NSEvent) {
        let settings = GlassSettings.shared
        guard settings.isAutoBlurredByIdle && settings.isBlurActive else { return }

        // For mouse movement, filter micro-jitter (< 4.0 points) so desk vibrations don't accidentally wake
        if event.type == .mouseMoved {
            let currentPos = NSEvent.mouseLocation
            let dx = currentPos.x - initialMousePosition.x
            let dy = currentPos.y - initialMousePosition.y
            if hypot(dx, dy) < 4.0 {
                return
            }
        }

        wakeFromIdleBlur()
    }

    private func checkWakeConditions() {
        let settings = GlassSettings.shared
        guard settings.isAutoBlurredByIdle && settings.isBlurActive else {
            stopWakeMonitoring()
            return
        }

        // Check if mouse moved beyond threshold
        let currentPos = NSEvent.mouseLocation
        let dx = currentPos.x - initialMousePosition.x
        let dy = currentPos.y - initialMousePosition.y
        if hypot(dx, dy) >= 4.0 {
            wakeFromIdleBlur()
            return
        }

        // Check if a system-wide HID event just occurred (< 0.12s ago)
        let idleCombined = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        let idleHid = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
        let recentIdle = min(idleCombined, idleHid)
        if recentIdle < 0.12 {
            wakeFromIdleBlur()
            return
        }
    }

    public func wakeFromIdleBlur() {
        stopWakeMonitoring()

        let settings = GlassSettings.shared
        settings.isAutoBlurredByIdle = false
        if settings.isBlurActive {
            withAnimation(.easeInOut(duration: 0.25)) {
                settings.isBlurActive = false
            }
        }
    }
}
