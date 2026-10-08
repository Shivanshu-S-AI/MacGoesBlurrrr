import SwiftUI

public enum PopoverTab: String, CaseIterable, Identifiable {
    case presets = "Styles"
    case customize = "Studio"
    case settings = "Settings"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .presets: return "sparkles"
        case .customize: return "slider.horizontal.3"
        case .settings: return "gearshape.fill"
        }
    }
}

public struct PopoverContentView: View {
    @ObservedObject var settings = GlassSettings.shared
    @State private var selectedTab: PopoverTab = .presets

    public init() {}

    public var filteredPresets: [GlassPreset] {
        if settings.selectedCategory == .all {
            return GlassPreset.allPresets
        }
        return GlassPreset.allPresets.filter { $0.category == settings.selectedCategory }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header (Always Visible)
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()
                .opacity(0.35)

            // MARK: - Segmented Navigation Bar
            tabSelectorView
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            Divider()
                .opacity(0.25)

            // MARK: - Tab Views (Fixed Scrollable Body)
            Group {
                switch selectedTab {
                case .presets:
                    presetsTabView
                case .customize:
                    customizeTabView
                case .settings:
                    settingsTabView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .opacity(0.35)

            // MARK: - Footer (Always Visible)
            footerView
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .frame(width: 380, height: 580)
        .background(
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                // Subtle ambient chromatic glow from active preset
                LinearGradient(
                    colors: settings.currentPreset.tintColors.map { $0.swiftUIColor.opacity(0.12) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .center, spacing: 10) {
            // App Branding Icon with dynamic glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: settings.isBlurActive ?
                            settings.currentPreset.tintColors.map { $0.swiftUIColor } :
                            [Color.primary.opacity(0.12), Color.primary.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                    .shadow(
                        color: settings.isBlurActive ?
                            (settings.currentPreset.tintColors.first?.swiftUIColor.opacity(0.6) ?? Color.clear) :
                            Color.clear,
                        radius: 8,
                        x: 0,
                        y: 0
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(settings.isBlurActive ? .white : .secondary)
            }

            // Title & Status
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("MacGoesBlurrrr")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)

                    // Current Preset Badge
                    Text(settings.currentPreset.name)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(settings.currentPreset.tintColors.first?.swiftUIColor ?? .cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1.5)
                        .background(
                            (settings.currentPreset.tintColors.first?.swiftUIColor ?? .cyan).opacity(0.15)
                        )
                        .clipShape(Capsule())
                }

                HStack(spacing: 5) {
                    Circle()
                        .fill(settings.isBlurActive ? Color.teal : Color.secondary.opacity(0.6))
                        .frame(width: 6, height: 6)

                    Text(settings.isBlurActive ? "Screen Blurred" : "Screen Clear")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(settings.isBlurActive ? .teal : .secondary)

                    Text("• ⌥⌘B")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Header Action Buttons
            HStack(spacing: 6) {
                // 🎲 Shuffle / Random Button (Icon Only)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        settings.shuffleToRandomPreset()
                    }
                }) {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.primary.opacity(0.07))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .help("Shuffle to a random glass style (⌥⇧⌘B)")

                // Main Blur/Unblur Toggle Button (Icon Only)
                Button(action: {
                    settings.toggleBlur()
                }) {
                    Image(systemName: settings.isBlurActive ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(settings.isBlurActive ? .white : .primary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    settings.isBlurActive ?
                                    LinearGradient(
                                        colors: settings.currentPreset.tintColors.map { $0.swiftUIColor },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.primary.opacity(0.10), Color.primary.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(
                                    settings.isBlurActive ?
                                    Color.white.opacity(0.35) :
                                    Color.primary.opacity(0.14),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: settings.isBlurActive ? Color.black.opacity(0.2) : Color.clear,
                            radius: 4,
                            y: 1
                        )
                }
                .buttonStyle(.plain)
                .help(settings.isBlurActive ? "Unblur screen (⌥⌘B)" : "Blur screen (⌥⌘B)")
            }
        }
    }

    // MARK: - Tab Selector Bar
    private var tabSelectorView: some View {
        HStack(spacing: 6) {
            ForEach(PopoverTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    }
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                isSelected ?
                                Color.accentColor :
                                Color.primary.opacity(0.04)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Tab 1: Presets & Styles
    private var presetsTabView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 14) {
                // Quick Color Swatches Bar
                quickColorBarView

                // Category Filter Pills
                categoryFilterView

                // Presets Grid
                presetsGridView
            }
            .padding(14)
        }
    }

    // MARK: - Quick Color Swatches Bar
    private var quickColorBarView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Instant Color Swatches")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    swatchButton(title: "Pink", color: Color(red: 1.0, green: 0.16, blue: 0.52), presetId: "sakura_pink")
                    swatchButton(title: "Mint", color: Color(red: 0.0, green: 0.82, blue: 0.52), presetId: "mint_serenity")
                    swatchButton(title: "Sky", color: Color(red: 0.01, green: 0.52, blue: 0.78), presetId: "glacier_blue")
                    swatchButton(title: "Lilac", color: Color(red: 0.49, green: 0.23, blue: 0.93), presetId: "lavender_dream")
                    swatchButton(title: "Peach", color: Color(red: 0.92, green: 0.35, blue: 0.05), presetId: "peach_sorbet")
                    swatchButton(title: "Lemon", color: Color(red: 0.79, green: 0.54, blue: 0.02), presetId: "lemon_chiffon")
                    swatchButton(title: "Opal", color: Color.purple, presetId: "prismatic_rainbow", isRainbow: true)
                    swatchButton(title: "Frost", color: Color.white, presetId: "crystal_frost")
                    swatchButton(title: "Dark", color: Color(red: 0.06, green: 0.09, blue: 0.16), presetId: "obsidian_stealth")
                }
                .padding(.vertical, 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private func swatchButton(title: String, color: Color, presetId: String, isRainbow: Bool = false) -> some View {
        let isSelected = settings.selectedPresetId == presetId

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                settings.selectPreset(byIdOrName: presetId)
                if !settings.isBlurActive {
                    settings.isBlurActive = true
                }
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isRainbow {
                        AngularGradient(
                            colors: [.pink, .purple, .blue, .green, .yellow, .orange, .pink],
                            center: .center
                        )
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(color)
                    }

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(title == "Frost" || title == "Lemon" ? .black : .white)
                    }
                }
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.primary.opacity(0.18), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: color.opacity(0.35), radius: 3, y: 1)

                Text(title)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Filter Pills
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(PresetCategory.allCases) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            settings.selectedCategory = category
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.system(size: 10, weight: settings.selectedCategory == category ? .bold : .medium))
                            .foregroundColor(settings.selectedCategory == category ? .white : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(settings.selectedCategory == category ? Color.accentColor : Color.primary.opacity(0.04))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Presets Grid
    private var presetsGridView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Catalog (\(filteredPresets.count))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(filteredPresets) { preset in
                    PresetCardView(
                        preset: preset,
                        isSelected: settings.selectedPresetId == preset.id,
                        onSelect: {
                            settings.selectPreset(preset)
                            if !settings.isBlurActive {
                                settings.isBlurActive = true
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Tab 2: Customize / Studio
    private var customizeTabView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 14) {
                GlassSlidersView(settings: settings)
            }
            .padding(14)
        }
    }

    // MARK: - Tab 3: Settings & Preferences
    private var settingsTabView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 14) {
                // Intelligent Idle Auto-Blur Card
                idleAutoBlurCardView

                // Shortcuts & Automation Card
                shortcutsCardView

                // Screen & Behavior Card
                screenBehaviorCardView

                // Gestures & Tips Card
                tipsCardView

                // App Info & Quit Card
                aboutCardView
            }
            .padding(14)
        }
    }

    // MARK: - Intelligent Idle Auto-Blur Card
    private var idleAutoBlurCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intelligent Idle Auto-Blur")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                // Main Toggle
                Toggle(isOn: $settings.autoBlurOnIdle) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Auto-Blur When Idle")
                                .font(.system(size: 11, weight: .semibold))
                            if settings.autoBlurOnIdle {
                                Circle()
                                    .fill(Color.teal)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        Text("Blurs screen automatically after inactivity; wakes on any mouse/key input")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                if settings.autoBlurOnIdle {
                    Divider().opacity(0.2)

                    // Timeout Picker Row
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Inactivity Timeout")
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Text(formatTimeout(settings.idleTimeoutMinutes))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        // Fast selection buttons
                        HStack(spacing: 5) {
                            timeoutButton(title: "30s", minutes: 0.5)
                            timeoutButton(title: "1m", minutes: 1.0)
                            timeoutButton(title: "2m", minutes: 2.0)
                            timeoutButton(title: "5m", minutes: 5.0)
                            timeoutButton(title: "10m", minutes: 10.0)
                            timeoutButton(title: "15m", minutes: 15.0)
                        }
                    }

                    Divider().opacity(0.2)

                    // Desired Idle Blur Style Selector
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Idle Blur Style")
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Text(idleStyleName)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(idleStyleColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(idleStyleColor.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        Menu {
                            Button(action: {
                                withAnimation { settings.idlePresetId = "current" }
                            }) {
                                HStack {
                                    Text("📍 Current Active Style (\(settings.currentPreset.name))")
                                    if settings.idlePresetId == "current" {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }

                            Button(action: {
                                withAnimation { settings.idlePresetId = "random" }
                            }) {
                                HStack {
                                    Text("🎲 Random Style (Shuffle)")
                                    if settings.idlePresetId == "random" {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }

                            Divider()

                            ForEach(GlassPreset.allPresets) { preset in
                                Button(action: {
                                    withAnimation { settings.idlePresetId = preset.id }
                                }) {
                                    HStack {
                                        Text("\(preset.name) (\(preset.category.rawValue))")
                                        if settings.idlePresetId == preset.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                idleStyleIcon
                                    .frame(width: 16)

                                Text(idleStyleLabel)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.primary.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.primary.opacity(0.10), lineWidth: 1)
                            )
                        }
                        .menuStyle(.borderlessButton)
                    }

                    Divider().opacity(0.2)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(.teal)
                        Text("Instant wake-up: moving mouse or typing removes blur immediately")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func timeoutButton(title: String, minutes: Double) -> some View {
        let isSelected = abs(settings.idleTimeoutMinutes - minutes) < 0.05
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                settings.idleTimeoutMinutes = minutes
            }
        }) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
    }

    private func formatTimeout(_ minutes: Double) -> String {
        if minutes < 1.0 {
            return "\(Int(minutes * 60)) seconds"
        } else if minutes == 1.0 {
            return "1 minute"
        } else {
            return "\(Int(minutes)) minutes"
        }
    }

    private var idleStyleName: String {
        if settings.idlePresetId == "random" {
            return "Random"
        } else if settings.idlePresetId == "current" {
            return "Current (\(settings.currentPreset.name))"
        } else if let preset = GlassPreset.allPresets.first(where: { $0.id == settings.idlePresetId }) {
            return preset.name
        } else {
            return "Current"
        }
    }

    private var idleStyleColor: Color {
        if settings.idlePresetId == "random" {
            return .cyan
        } else if settings.idlePresetId == "current" {
            return settings.currentPreset.tintColors.first?.swiftUIColor ?? .cyan
        } else if let preset = GlassPreset.allPresets.first(where: { $0.id == settings.idlePresetId }) {
            return preset.tintColors.first?.swiftUIColor ?? .cyan
        } else {
            return .cyan
        }
    }

    private var idleStyleLabel: String {
        if settings.idlePresetId == "random" {
            return "🎲 Random Style on Timeout"
        } else if settings.idlePresetId == "current" {
            return "📍 Current Style: \(settings.currentPreset.name)"
        } else if let preset = GlassPreset.allPresets.first(where: { $0.id == settings.idlePresetId }) {
            return "\(preset.name) (\(preset.category.rawValue))"
        } else {
            return "📍 Current Style: \(settings.currentPreset.name)"
        }
    }

    @ViewBuilder
    private var idleStyleIcon: some View {
        if settings.idlePresetId == "random" {
            Image(systemName: "dice.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.cyan)
        } else if settings.idlePresetId == "current" {
            Image(systemName: settings.currentPreset.iconName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(settings.currentPreset.tintColors.first?.swiftUIColor ?? .cyan)
        } else if let preset = GlassPreset.allPresets.first(where: { $0.id == settings.idlePresetId }) {
            Image(systemName: preset.iconName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(preset.tintColors.first?.swiftUIColor ?? .cyan)
        } else {
            Image(systemName: "sparkles")
                .font(.system(size: 11))
                .foregroundColor(.cyan)
        }
    }

    // MARK: - Shortcuts Card
    private var shortcutsCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Keyboard Shortcuts")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                // Toggle: Randomize on Shortcut
                Toggle(isOn: $settings.randomizeOnShortcut) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Randomize Style on ⌥⌘B")
                                .font(.system(size: 11, weight: .semibold))
                            hotkeyBadge("⌥⌘B")
                        }
                        Text("Pick a fresh random style every time screen blurs")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                Divider().opacity(0.2)

                // Row: Instant Shuffle Hotkey
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Instant Style Shuffle")
                                .font(.system(size: 11, weight: .semibold))
                            hotkeyBadge("⌥⇧⌘B")
                        }
                        Text("Cycle to another random style immediately while blurred")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - Screen & Behavior Card
    private var screenBehaviorCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Screen & Behavior")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                // Click-Through Mode
                Toggle(isOn: $settings.isClickThrough) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Click-Through Mode")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Interact with background apps while screen is blurred")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                Divider().opacity(0.2)

                // Blur Menu Bar
                Toggle(isOn: $settings.blurMenu) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Blur Menu Bar")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Extend frosted glass over the macOS Menu Bar")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                Divider().opacity(0.2)

                // Cover Dock
                Toggle(isOn: $settings.coverDock) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cover Dock")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Extend frosted glass over the macOS Dock")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                Divider().opacity(0.2)

                // All Displays
                Toggle(isOn: $settings.allMonitors) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("All Connected Displays")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Blur external monitors simultaneously")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)

                Divider().opacity(0.2)

                // Launch at Login
                Toggle(isOn: $settings.launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Start on Mac Startup")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Automatically open MacGoesBlurrrr when Mac boots")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .controlSize(.mini)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - Tips Card
    private var tipsCardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gestures & Tips")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.cyan)
                        .frame(width: 16)
                    Text("Double-click blurred screen to unblur (when Click-Through is off)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }

                HStack(spacing: 8) {
                    Image(systemName: "cursorarrow.rays")
                        .font(.system(size: 11))
                        .foregroundColor(.purple)
                        .frame(width: 16)
                    Text("Option-Click menu bar icon to toggle blur immediately")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - About Card
    private var aboutCardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Information")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                HStack {
                    Text("MacGoesBlurrrr")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                    Text("Version 1.0.0 (Apple Silicon)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Divider().opacity(0.2)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                            .font(.system(size: 11, weight: .bold))
                        Text("Quit MacGoesBlurrrr")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.red.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - Footer View
    private var footerView: some View {
        HStack {
            HStack(spacing: 4) {
                hotkeyBadge("⌥⌘B")
                Text("to blur (random style)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func hotkeyBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(Color.primary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}
