import Foundation
import AppKit

public enum PresetCategory: String, Codable, Sendable, CaseIterable, Identifiable {
    case all = "All"
    case pastel = "Pastel Frost"
    case white = "White Glass"
    case vibrant = "Vibrant"
    case dark = "Obsidian"

    public var id: String { rawValue }
}

public struct GlassPreset: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let tagline: String
    public let category: PresetCategory
    public let iconName: String
    public let isDarkAppearance: Bool
    public let materialRawValue: Int
    public let defaultBlurRadius: Double
    public let tintColors: [GlassColor]
    public let gradientAngle: Double // degrees
    public let defaultTintOpacity: Double
    public let defaultWhiteFrost: Double
    public let defaultGrainIntensity: Double
    public let defaultSpecularIntensity: Double
    public let defaultVignetteIntensity: Double

    public var material: NSVisualEffectView.Material {
        NSVisualEffectView.Material(rawValue: materialRawValue) ?? .underWindowBackground
    }

    public init(
        id: String,
        name: String,
        tagline: String,
        category: PresetCategory,
        iconName: String,
        isDarkAppearance: Bool,
        material: NSVisualEffectView.Material = .underWindowBackground,
        blurRadius: Double,
        tintColors: [GlassColor],
        gradientAngle: Double = 135,
        tintOpacity: Double = 0.90,
        whiteFrost: Double = 0.30,
        grainIntensity: Double = 0.06,
        specularIntensity: Double = 0.15,
        vignetteIntensity: Double = 0.10
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.category = category
        self.iconName = iconName
        self.isDarkAppearance = isDarkAppearance
        self.materialRawValue = material.rawValue
        self.defaultBlurRadius = blurRadius
        self.tintColors = tintColors
        self.gradientAngle = gradientAngle
        self.defaultTintOpacity = tintOpacity
        self.defaultWhiteFrost = whiteFrost
        self.defaultGrainIntensity = grainIntensity
        self.defaultSpecularIntensity = specularIntensity
        self.defaultVignetteIntensity = vignetteIntensity
    }

    // Curated catalog with translucent light colors and authentic frost
    public static let allPresets: [GlassPreset] = [
        // MARK: - Light Pastel Collection (Vibrant light translucent colors)

        // 1. Sakura Pink Frost
        GlassPreset(
            id: "sakura_pink",
            name: "Sakura Pink",
            tagline: "Cherry blossom pink wash over silky frosted screen",
            category: .pastel,
            iconName: "heart.fill",
            isDarkAppearance: false,
            blurRadius: 48,
            tintColors: [
                GlassColor(hex: "#FF2A85", alpha: 0.30),
                GlassColor(hex: "#FF65A3", alpha: 0.28)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 2. Mint Matcha Frost (Light Green)
        GlassPreset(
            id: "mint_serenity",
            name: "Mint Matcha",
            tagline: "Refreshing light seafoam and matcha green frosted glass",
            category: .pastel,
            iconName: "leaf.fill",
            isDarkAppearance: false,
            blurRadius: 48,
            tintColors: [
                GlassColor(hex: "#00D084", alpha: 0.28),
                GlassColor(hex: "#6EE7B7", alpha: 0.26)
            ],
            gradientAngle: 140,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 3. Glacier Sky Frost (Light Blue)
        GlassPreset(
            id: "glacier_blue",
            name: "Glacier Sky",
            tagline: "Crisp airy baby sky blue with crystalline ice frost",
            category: .pastel,
            iconName: "snowflake",
            isDarkAppearance: false,
            blurRadius: 50,
            tintColors: [
                GlassColor(hex: "#0284C7", alpha: 0.28),
                GlassColor(hex: "#38BDF8", alpha: 0.26)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 4. Lavender Lilac Frost (Pastel Purple)
        GlassPreset(
            id: "lavender_dream",
            name: "Lavender Lilac",
            tagline: "Dreamy soft wisteria and lilac pastel frosted glass",
            category: .pastel,
            iconName: "moon.fill",
            isDarkAppearance: false,
            blurRadius: 50,
            tintColors: [
                GlassColor(hex: "#7C3AED", alpha: 0.28),
                GlassColor(hex: "#A78BFA", alpha: 0.26)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 5. Peach Sunrise Frost
        GlassPreset(
            id: "peach_sorbet",
            name: "Peach Sunrise",
            tagline: "Warm pastel apricot and peach morning glow through frosted glass",
            category: .pastel,
            iconName: "sun.horizon.fill",
            isDarkAppearance: false,
            blurRadius: 46,
            tintColors: [
                GlassColor(hex: "#EA580C", alpha: 0.28),
                GlassColor(hex: "#FB923C", alpha: 0.26)
            ],
            gradientAngle: 120,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 6. Lemon Chiffon Frost (Light Yellow)
        GlassPreset(
            id: "lemon_chiffon",
            name: "Lemon Chiffon",
            tagline: "Soft morning sunlight and buttercup pastel yellow frost",
            category: .pastel,
            iconName: "sun.max.fill",
            isDarkAppearance: false,
            blurRadius: 46,
            tintColors: [
                GlassColor(hex: "#CA8A04", alpha: 0.26),
                GlassColor(hex: "#FACC15", alpha: 0.24)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.32,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // 7. Prismatic Rainbow Opal
        GlassPreset(
            id: "prismatic_rainbow",
            name: "Prismatic Opal",
            tagline: "Iridescent pastel rainbow: pink, lilac, sky blue & mint shimmer",
            category: .pastel,
            iconName: "sparkles",
            isDarkAppearance: false,
            blurRadius: 52,
            tintColors: [
                GlassColor(hex: "#FF2A85", alpha: 0.28),
                GlassColor(hex: "#7C3AED", alpha: 0.28),
                GlassColor(hex: "#0284C7", alpha: 0.28),
                GlassColor(hex: "#00D084", alpha: 0.28)
            ],
            gradientAngle: 145,
            tintOpacity: 0.92,
            whiteFrost: 0.28,
            grainIntensity: 0.08,
            specularIntensity: 0.24,
            vignetteIntensity: 0.08
        ),

        // 8. Coral Blossom Frost
        GlassPreset(
            id: "coral_blush",
            name: "Coral Blossom",
            tagline: "Luminous soft coral and champagne pink frosted glass",
            category: .pastel,
            iconName: "drop.fill",
            isDarkAppearance: false,
            blurRadius: 48,
            tintColors: [
                GlassColor(hex: "#F43F5E", alpha: 0.28),
                GlassColor(hex: "#FB7185", alpha: 0.26)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.30,
            grainIntensity: 0.06,
            specularIntensity: 0.20,
            vignetteIntensity: 0.08
        ),

        // MARK: - White Frosted Glass Collection

        // 9. Pure Crystal Frost
        GlassPreset(
            id: "crystal_frost",
            name: "Pure Crystal Frost",
            tagline: "Quintessential Apple architectural white frosted glass",
            category: .white,
            iconName: "square.grid.2x2.fill",
            isDarkAppearance: false,
            blurRadius: 48,
            tintColors: [
                GlassColor(hex: "#FFFFFF", alpha: 0.20),
                GlassColor(hex: "#F8FAFC", alpha: 0.16)
            ],
            gradientAngle: 135,
            tintOpacity: 0.85,
            whiteFrost: 0.40,
            grainIntensity: 0.06,
            specularIntensity: 0.22,
            vignetteIntensity: 0.06
        ),

        // 10. Frosted Pearl
        GlassPreset(
            id: "frosted_pearl",
            name: "Frosted Pearl",
            tagline: "Milky opal diffusion with soft velvety tactile texture",
            category: .white,
            iconName: "circle.circle.fill",
            isDarkAppearance: false,
            blurRadius: 60,
            tintColors: [
                GlassColor(hex: "#FFFFFF", alpha: 0.24),
                GlassColor(hex: "#E2E8F0", alpha: 0.20)
            ],
            gradientAngle: 135,
            tintOpacity: 0.85,
            whiteFrost: 0.45,
            grainIntensity: 0.08,
            specularIntensity: 0.18,
            vignetteIntensity: 0.08
        ),

        // MARK: - Vibrant Collection

        // 11. Neon Synthwave
        GlassPreset(
            id: "neon_cyberpunk",
            name: "Neon Synthwave",
            tagline: "Electric cyan and hot magenta neon reflections through rain glass",
            category: .vibrant,
            iconName: "bolt.fill",
            isDarkAppearance: true,
            blurRadius: 52,
            tintColors: [
                GlassColor(hex: "#00F0FF", alpha: 0.30),
                GlassColor(hex: "#FF007F", alpha: 0.30)
            ],
            gradientAngle: 135,
            tintOpacity: 0.90,
            whiteFrost: 0.08,
            grainIntensity: 0.09,
            specularIntensity: 0.26,
            vignetteIntensity: 0.14
        ),

        // 12. Aurora Borealis
        GlassPreset(
            id: "aurora_borealis",
            name: "Aurora Borealis",
            tagline: "Ethereal emerald teal and cosmic violet dancing veil",
            category: .vibrant,
            iconName: "sparkles",
            isDarkAppearance: true,
            blurRadius: 56,
            tintColors: [
                GlassColor(hex: "#10B981", alpha: 0.30),
                GlassColor(hex: "#8B5CF6", alpha: 0.30)
            ],
            gradientAngle: 150,
            tintOpacity: 0.90,
            whiteFrost: 0.08,
            grainIntensity: 0.08,
            specularIntensity: 0.22,
            vignetteIntensity: 0.14
        ),

        // MARK: - Obsidian & Dark Collection

        // 13. Obsidian Stealth
        GlassPreset(
            id: "obsidian_stealth",
            name: "Obsidian Stealth",
            tagline: "Deep charcoal matte acrylic with ultra-high contrast",
            category: .dark,
            iconName: "moon.stars.fill",
            isDarkAppearance: true,
            blurRadius: 58,
            tintColors: [
                GlassColor(hex: "#0F172A", alpha: 0.55),
                GlassColor(hex: "#020617", alpha: 0.70)
            ],
            gradientAngle: 145,
            tintOpacity: 0.90,
            whiteFrost: 0.0,
            grainIntensity: 0.05,
            specularIntensity: 0.10,
            vignetteIntensity: 0.22
        ),

        // 14. Privacy Shield
        GlassPreset(
            id: "privacy_shield",
            name: "Privacy Shield",
            tagline: "Ultra-dense obfuscation veil for cafes, travel, and meetings",
            category: .dark,
            iconName: "shield.checkerboard",
            isDarkAppearance: true,
            blurRadius: 90,
            tintColors: [
                GlassColor(hex: "#0B0F19", alpha: 0.82),
                GlassColor(hex: "#030712", alpha: 0.90)
            ],
            gradientAngle: 180,
            tintOpacity: 0.95,
            whiteFrost: 0.0,
            grainIntensity: 0.12,
            specularIntensity: 0.08,
            vignetteIntensity: 0.30
        )
    ]

    public static var defaultPreset: GlassPreset {
        allPresets[0] // Sakura Pink
    }
}
