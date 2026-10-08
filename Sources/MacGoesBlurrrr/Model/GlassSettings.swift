import SwiftUI
import Combine
import ServiceManagement

@MainActor
public final class GlassSettings: ObservableObject {
    public static let shared = GlassSettings()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let isBlurActive = "GlassScreen_isBlurActive"
        static let selectedPresetId = "GlassScreen_selectedPresetId"
        static let blurRadius = "GlassScreen_blurRadius"
        static let tintOpacity = "GlassScreen_tintOpacity"
        static let whiteFrostIntensity = "GlassScreen_whiteFrostIntensity"
        static let grainIntensity = "GlassScreen_grainIntensity"
        static let specularIntensity = "GlassScreen_specularIntensity"
        static let vignetteIntensity = "GlassScreen_vignetteIntensity"
        static let isClickThrough = "GlassScreen_isClickThrough"
        static let coverDock = "GlassScreen_coverDock"
        static let blurMenu = "GlassScreen_blurMenu"
        static let allMonitors = "GlassScreen_allMonitors"
        static let launchAtLogin = "GlassScreen_launchAtLogin"
        static let randomizeOnShortcut = "GlassScreen_randomizeOnShortcut"
        static let autoBlurOnIdle = "GlassScreen_autoBlurOnIdle"
        static let idleTimeoutMinutes = "GlassScreen_idleTimeoutMinutes"
        static let idlePresetId = "GlassScreen_idlePresetId"
    }

    @Published public var autoBlurOnIdle: Bool {
        didSet { defaults.set(autoBlurOnIdle, forKey: Keys.autoBlurOnIdle) }
    }

    @Published public var idleTimeoutMinutes: Double {
        didSet { defaults.set(idleTimeoutMinutes, forKey: Keys.idleTimeoutMinutes) }
    }

    @Published public var idlePresetId: String {
        didSet { defaults.set(idlePresetId, forKey: Keys.idlePresetId) }
    }

    @Published public var isAutoBlurredByIdle: Bool = false

    @Published public var randomizeOnShortcut: Bool {
        didSet { defaults.set(randomizeOnShortcut, forKey: Keys.randomizeOnShortcut) }
    }

    @Published public var isBlurActive: Bool {
        didSet { defaults.set(isBlurActive, forKey: Keys.isBlurActive) }
    }

    @Published public var selectedPresetId: String {
        didSet {
            defaults.set(selectedPresetId, forKey: Keys.selectedPresetId)
            objectWillChange.send()
        }
    }

    @Published public var blurRadius: Double {
        didSet { defaults.set(blurRadius, forKey: Keys.blurRadius) }
    }

    @Published public var tintOpacity: Double {
        didSet { defaults.set(tintOpacity, forKey: Keys.tintOpacity) }
    }

    @Published public var whiteFrostIntensity: Double {
        didSet { defaults.set(whiteFrostIntensity, forKey: Keys.whiteFrostIntensity) }
    }

    @Published public var grainIntensity: Double {
        didSet { defaults.set(grainIntensity, forKey: Keys.grainIntensity) }
    }

    @Published public var specularIntensity: Double {
        didSet { defaults.set(specularIntensity, forKey: Keys.specularIntensity) }
    }

    @Published public var vignetteIntensity: Double {
        didSet { defaults.set(vignetteIntensity, forKey: Keys.vignetteIntensity) }
    }

    @Published public var isClickThrough: Bool {
        didSet { defaults.set(isClickThrough, forKey: Keys.isClickThrough) }
    }

    @Published public var coverDock: Bool {
        didSet { defaults.set(coverDock, forKey: Keys.coverDock) }
    }

    @Published public var blurMenu: Bool {
        didSet {
            defaults.set(blurMenu, forKey: Keys.blurMenu)
            objectWillChange.send()
        }
    }

    @Published public var allMonitors: Bool {
        didSet { defaults.set(allMonitors, forKey: Keys.allMonitors) }
    }

    @Published public var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            applyLaunchAtLogin(launchAtLogin)
        }
    }

    public func applyLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("Failed to update Launch at Login: \(error)")
            }
        }
    }

    @Published public var selectedCategory: PresetCategory = .all

    public var currentPreset: GlassPreset {
        GlassPreset.allPresets.first(where: { $0.id == selectedPresetId }) ?? GlassPreset.defaultPreset
    }

    private init() {
        let savedActive = defaults.bool(forKey: Keys.isBlurActive)
        let savedPresetId = defaults.string(forKey: Keys.selectedPresetId) ?? GlassPreset.defaultPreset.id
        let preset = GlassPreset.allPresets.first(where: { $0.id == savedPresetId }) ?? GlassPreset.defaultPreset

        self.isBlurActive = savedActive
        self.selectedPresetId = savedPresetId

        self.blurRadius = defaults.object(forKey: Keys.blurRadius) != nil ? defaults.double(forKey: Keys.blurRadius) : preset.defaultBlurRadius
        self.tintOpacity = defaults.object(forKey: Keys.tintOpacity) != nil ? defaults.double(forKey: Keys.tintOpacity) : preset.defaultTintOpacity
        self.whiteFrostIntensity = defaults.object(forKey: Keys.whiteFrostIntensity) != nil ? defaults.double(forKey: Keys.whiteFrostIntensity) : preset.defaultWhiteFrost
        self.grainIntensity = defaults.object(forKey: Keys.grainIntensity) != nil ? defaults.double(forKey: Keys.grainIntensity) : preset.defaultGrainIntensity
        self.specularIntensity = defaults.object(forKey: Keys.specularIntensity) != nil ? defaults.double(forKey: Keys.specularIntensity) : preset.defaultSpecularIntensity
        self.vignetteIntensity = defaults.object(forKey: Keys.vignetteIntensity) != nil ? defaults.double(forKey: Keys.vignetteIntensity) : preset.defaultVignetteIntensity

        self.isClickThrough = defaults.object(forKey: Keys.isClickThrough) != nil ? defaults.bool(forKey: Keys.isClickThrough) : true
        self.coverDock = defaults.object(forKey: Keys.coverDock) != nil ? defaults.bool(forKey: Keys.coverDock) : true
        self.blurMenu = defaults.object(forKey: Keys.blurMenu) != nil ? defaults.bool(forKey: Keys.blurMenu) : true
        self.allMonitors = defaults.object(forKey: Keys.allMonitors) != nil ? defaults.bool(forKey: Keys.allMonitors) : true
        if defaults.object(forKey: Keys.launchAtLogin) != nil {
            self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        } else {
            self.launchAtLogin = true
            defaults.set(true, forKey: Keys.launchAtLogin)
        }
        self.randomizeOnShortcut = defaults.object(forKey: Keys.randomizeOnShortcut) != nil ? defaults.bool(forKey: Keys.randomizeOnShortcut) : true
        self.autoBlurOnIdle = defaults.object(forKey: Keys.autoBlurOnIdle) != nil ? defaults.bool(forKey: Keys.autoBlurOnIdle) : true
        self.idleTimeoutMinutes = defaults.object(forKey: Keys.idleTimeoutMinutes) != nil ? defaults.double(forKey: Keys.idleTimeoutMinutes) : 2.0
        self.idlePresetId = defaults.string(forKey: Keys.idlePresetId) ?? "current"
    }

    public func selectPreset(_ preset: GlassPreset) {
        selectedPresetId = preset.id
        blurRadius = preset.defaultBlurRadius
        tintOpacity = preset.defaultTintOpacity
        whiteFrostIntensity = preset.defaultWhiteFrost
        grainIntensity = preset.defaultGrainIntensity
        specularIntensity = preset.defaultSpecularIntensity
        vignetteIntensity = preset.defaultVignetteIntensity
    }

    @discardableResult
    public func selectPreset(byIdOrName query: String) -> Bool {
        let q = query.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "-", with: "_")
        if let match = GlassPreset.allPresets.first(where: {
            $0.id.lowercased() == q ||
            $0.name.lowercased().replacingOccurrences(of: " ", with: "_") == q ||
            $0.id.lowercased().contains(q) ||
            $0.name.lowercased().contains(q)
        }) {
            selectPreset(match)
            return true
        }
        return false
    }

    public func selectRandomPreset(excludingCurrent: Bool = true) {
        let presets = GlassPreset.allPresets
        guard !presets.isEmpty else { return }

        let candidates: [GlassPreset]
        if excludingCurrent && presets.count > 1 {
            candidates = presets.filter { $0.id != selectedPresetId }
        } else {
            candidates = presets
        }

        if let chosen = (candidates.isEmpty ? presets : candidates).randomElement() {
            selectPreset(chosen)
        }
    }

    public func triggerShortcutBlur() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if isBlurActive {
                isBlurActive = false
            } else {
                if randomizeOnShortcut {
                    selectRandomPreset(excludingCurrent: true)
                }
                isBlurActive = true
            }
        }
    }

    public func shuffleToRandomPreset() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectRandomPreset(excludingCurrent: true)
            if !isBlurActive {
                isBlurActive = true
            }
        }
    }

    public func resetToPresetDefaults() {
        selectPreset(currentPreset)
    }

    public func toggleBlur(randomizeIfActivating: Bool = false) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if isBlurActive {
                isBlurActive = false
            } else {
                if randomizeIfActivating && randomizeOnShortcut {
                    selectRandomPreset(excludingCurrent: true)
                }
                isBlurActive = true
            }
        }
    }
}
