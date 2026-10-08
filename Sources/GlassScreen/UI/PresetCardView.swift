import SwiftUI

public struct PresetCardView: View {
    public let preset: GlassPreset
    public let isSelected: Bool
    public let onSelect: () -> Void

    @State private var isHovered: Bool = false

    public init(preset: GlassPreset, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.preset = preset
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    private var cardBackground: Color {
        if isSelected {
            return preset.tintColors.first?.swiftUIColor.opacity(0.15) ?? Color.cyan.opacity(0.15)
        } else if isHovered {
            return Color.primary.opacity(0.06)
        } else {
            return Color.primary.opacity(0.03)
        }
    }

    private var cardBorderColor: Color {
        if isSelected {
            return preset.tintColors.first?.swiftUIColor ?? Color.cyan
        } else if isHovered {
            return Color.primary.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                // Miniature Glass Preview Swatch
                ZStack(alignment: .topTrailing) {
                    // Gradient glass simulation
                    LinearGradient(
                        colors: preset.tintColors.map { $0.swiftUIColor },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )

                    // SF Symbol badge
                    HStack {
                        Image(systemName: preset.iconName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                            .padding(4)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.cyan)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                                .padding(6)
                        }
                    }
                }

                // Label and category
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(preset.tagline)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(height: 26, alignment: .topLeading)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(cardBorderColor, lineWidth: isSelected ? 1.5 : 1)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
