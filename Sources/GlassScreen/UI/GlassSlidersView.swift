import SwiftUI

public struct GlassSlidersView: View {
    @ObservedObject var settings: GlassSettings

    public init(settings: GlassSettings) {
        self.settings = settings
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Live Shader Preview
            liveGlassPreviewCard

            // Sliders Container
            VStack(spacing: 12) {
                HStack {
                    Text("Parameter Controls")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                }

                // Slider: Blur Radius
                sliderRow(
                    icon: "drop.fill",
                    title: "Blur Strength",
                    value: $settings.blurRadius,
                    range: 10...100,
                    unit: "px",
                    displayMultiplier: 1.0,
                    accentColor: .cyan
                )

                // Slider: White Frost Foundation (The signature white milky frost)
                sliderRow(
                    icon: "snowflake",
                    title: "White Frost Base",
                    value: $settings.whiteFrostIntensity,
                    range: 0.0...0.70,
                    unit: "%",
                    displayMultiplier: 140.0,
                    accentColor: .teal
                )

                // Slider: Tint Opacity (Color wash vibrancy)
                sliderRow(
                    icon: "paintpalette.fill",
                    title: "Color Vibrancy",
                    value: $settings.tintOpacity,
                    range: 0.05...0.95,
                    unit: "%",
                    displayMultiplier: 100.0,
                    accentColor: .pink
                )

                // Slider: Frosted Grain
                sliderRow(
                    icon: "aqi.medium",
                    title: "Frosted Texture",
                    value: $settings.grainIntensity,
                    range: 0.0...0.25,
                    unit: "%",
                    displayMultiplier: 400.0,
                    accentColor: .orange
                )

                // Slider: Specular Sheen
                sliderRow(
                    icon: "sparkles",
                    title: "Bevel Light Sheen",
                    value: $settings.specularIntensity,
                    range: 0.0...0.45,
                    unit: "%",
                    displayMultiplier: 200.0,
                    accentColor: .yellow
                )

                // Slider: Vignette Depth
                sliderRow(
                    icon: "circle.dashed",
                    title: "Edge Depth",
                    value: $settings.vignetteIntensity,
                    range: 0.0...0.40,
                    unit: "%",
                    displayMultiplier: 250.0,
                    accentColor: .indigo
                )
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

    private func sliderRow(
        icon: String,
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        unit: String,
        displayMultiplier: Double,
        accentColor: Color
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 14)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(value.wrappedValue * displayMultiplier))\(unit)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Capsule())
            }

            Slider(value: value, in: range)
                .tint(accentColor)
                .controlSize(.small)
        }
    }

    private var liveGlassPreviewCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Simulated gradient glass background
            LinearGradient(
                colors: settings.currentPreset.tintColors.map { $0.swiftUIColor.opacity(max(0.2, settings.tintOpacity)) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Translucent White Frost simulation
            Color.white.opacity(settings.whiteFrostIntensity * 0.35)

            // Specular sheen along top edge
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(max(0.1, settings.specularIntensity * 2.0)), Color.white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 4)
                Spacer()
            }

            // Vignette shading
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(settings.vignetteIntensity * 1.5), lineWidth: 4)
                .blur(radius: 4)

            // Content overlay
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: settings.currentPreset.iconName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)

                        Text(settings.currentPreset.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)

                        Text("Preview")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .shadow(color: Color.black.opacity(0.5), radius: 2, y: 1)

                    Text("Live Glass Shader Simulation")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: Color.black.opacity(0.5), radius: 1, y: 1)
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        settings.resetToPresetDefaults()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 9, weight: .bold))
                        Text("Reset")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(12)
        }
        .frame(height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, y: 2)
    }
}
