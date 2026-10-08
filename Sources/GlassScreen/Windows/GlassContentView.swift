import AppKit
import QuartzCore

public final class GlassContentView: NSView {
    // Fallback AppKit visual effect view (only shown if WindowServer direct blur is unavailable)
    private let fallbackVisualEffectView = NSVisualEffectView()

    // Layer stack for authentic translucent glassmorphism
    private let whiteFrostLayer = CAGradientLayer()     // Translucent White Frost Diffusion
    private let tintGradientLayer = CAGradientLayer()   // Vibrant Chromatic Pastel & Color Tint
    private let noiseView = NSView()                    // Micro-Grain Frosted Texture
    private let specularSheenLayer = CAGradientLayer()  // Top Bevel Specular Sheen
    private let vignetteLayer = CAGradientLayer()       // Edge Optical Depth

    // Interactive Privacy Pill HUD
    private let lockPillView = NSVisualEffectView()
    private let lockPillLabel = NSTextField(labelWithString: "🔒 Privacy Shield Active  •  Double-click or ⌥⌘B to unblur")
    private var pillDismissTimer: Timer?

    public var onDoubleClicked: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayersAndSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayersAndSubviews()
    }

    private func setupLayersAndSubviews() {
        wantsLayer = true

        // 1. Fallback Visual Effect View (hidden by default to avoid opaque whiteouts)
        fallbackVisualEffectView.blendingMode = .behindWindow
        fallbackVisualEffectView.state = .active
        fallbackVisualEffectView.material = .underWindowBackground
        fallbackVisualEffectView.autoresizingMask = [.width, .height]
        fallbackVisualEffectView.frame = bounds
        fallbackVisualEffectView.isHidden = true
        addSubview(fallbackVisualEffectView)

        // 2. White Frosted Diffusion Layer (Soft translucent milky wash, NOT opaque!)
        whiteFrostLayer.frame = bounds
        whiteFrostLayer.needsDisplayOnBoundsChange = true
        whiteFrostLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        whiteFrostLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer?.addSublayer(whiteFrostLayer)

        // 3. Vibrant Chromatic Tint / Gradient Layer (Pink, Mint, Light Blue, Lavender, etc.)
        tintGradientLayer.frame = bounds
        tintGradientLayer.needsDisplayOnBoundsChange = true
        layer?.addSublayer(tintGradientLayer)

        // 4. Frosted Micro-Grain Texture View
        noiseView.wantsLayer = true
        noiseView.autoresizingMask = [.width, .height]
        noiseView.frame = bounds
        noiseView.layer?.backgroundColor = NoiseGenerator.shared.getNoisePatternColor().cgColor
        addSubview(noiseView)

        // 5. Specular Bevel Sheen (Ambient light refraction along the top glass pane)
        specularSheenLayer.frame = NSRect(x: 0, y: bounds.height - 3, width: bounds.width, height: 3)
        specularSheenLayer.colors = [
            NSColor(white: 1.0, alpha: 0.40).cgColor,
            NSColor(white: 1.0, alpha: 0.0).cgColor
        ]
        layer?.addSublayer(specularSheenLayer)

        // 6. Subtle Vignette
        vignetteLayer.frame = bounds
        vignetteLayer.colors = [
            NSColor(white: 0.0, alpha: 0.0).cgColor,
            NSColor(white: 0.0, alpha: 0.20).cgColor
        ]
        vignetteLayer.locations = [0.80, 1.0]
        layer?.addSublayer(vignetteLayer)

        // 7. Privacy Shield Floating Pill
        setupLockPill()
    }

    private func setupLockPill() {
        lockPillView.wantsLayer = true
        lockPillView.material = .hudWindow
        lockPillView.blendingMode = .withinWindow
        lockPillView.state = .active
        lockPillView.layer?.cornerRadius = 16
        lockPillView.layer?.masksToBounds = true
        lockPillView.layer?.borderColor = NSColor(white: 1.0, alpha: 0.25).cgColor
        lockPillView.layer?.borderWidth = 1.0
        lockPillView.alphaValue = 0.0

        lockPillLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        lockPillLabel.textColor = .white
        lockPillLabel.alignment = .center

        lockPillView.addSubview(lockPillLabel)
        addSubview(lockPillView)
    }

    public override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fallbackVisualEffectView.frame = bounds
        whiteFrostLayer.frame = bounds
        tintGradientLayer.frame = bounds
        noiseView.frame = bounds
        specularSheenLayer.frame = NSRect(x: 0, y: bounds.height - 2, width: bounds.width, height: 2)
        vignetteLayer.frame = bounds

        let pillWidth: CGFloat = 380
        let pillHeight: CGFloat = 36
        lockPillView.frame = NSRect(
            x: (bounds.width - pillWidth) / 2,
            y: 40,
            width: pillWidth,
            height: pillHeight
        )
        lockPillLabel.frame = NSRect(x: 16, y: 8, width: pillWidth - 32, height: 20)
        CATransaction.commit()
    }

    public func apply(preset: GlassPreset, settings: GlassSettings, cgsBlurActive: Bool) {
        if settings.isAutoBlurredByIdle {
            lockPillLabel.stringValue = "✨ Screen Asleep (\(preset.name))  •  Move mouse or press any key to wake"
        } else {
            lockPillLabel.stringValue = "✨ \(preset.name) Active  •  ⌥⌘B or Double-click to unblur"
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // If direct WindowServer blur is active, hide fallback view to prevent opaque whiteout
        fallbackVisualEffectView.isHidden = cgsBlurActive
        if !cgsBlurActive {
            fallbackVisualEffectView.material = preset.material
            let appearanceName: NSAppearance.Name = preset.isDarkAppearance ? .darkAqua : .aqua
            fallbackVisualEffectView.appearance = NSAppearance(named: appearanceName)
        }

        // 1. Translucent White Frost Foundation (Soft milky diffusion, NEVER solid white!)
        if preset.isDarkAppearance {
            // Minimal white for dark modes to keep blacks deep
            whiteFrostLayer.colors = [
                NSColor(white: 1.0, alpha: 0.02).cgColor,
                NSColor(white: 1.0, alpha: 0.01).cgColor
            ]
        } else {
            // Delicate translucent white frost (10% to 18% alpha)
            let frostAlpha = CGFloat(0.12 * max(0.2, settings.whiteFrostIntensity))
            whiteFrostLayer.colors = [
                NSColor(white: 1.0, alpha: frostAlpha * 1.25).cgColor,
                NSColor(white: 1.0, alpha: frostAlpha * 0.75).cgColor
            ]
        }
        whiteFrostLayer.opacity = 1.0

        // 2. Vibrant Chromatic Tint / Gradient (Pink, Mint, Light Blue, etc.)
        let cgColors = preset.tintColors.map { color in
            let effectiveAlpha = color.alpha * settings.tintOpacity
            return NSColor(
                srgbRed: color.red,
                green: color.green,
                blue: color.blue,
                alpha: effectiveAlpha
            ).cgColor
        }
        tintGradientLayer.colors = cgColors
        tintGradientLayer.opacity = 1.0

        let angleRad = preset.gradientAngle * .pi / 180.0
        let startPoint = CGPoint(x: 0.5 - 0.5 * cos(angleRad), y: 0.5 - 0.5 * sin(angleRad))
        let endPoint = CGPoint(x: 0.5 + 0.5 * cos(angleRad), y: 0.5 + 0.5 * sin(angleRad))
        tintGradientLayer.startPoint = startPoint
        tintGradientLayer.endPoint = endPoint

        // 3. Micro-Grain Frosted Glass Roughness
        noiseView.alphaValue = CGFloat(settings.grainIntensity * 1.8)

        // 4. Specular Top Bevel Sheen
        specularSheenLayer.opacity = Float(settings.specularIntensity * 2.0)

        // 5. Edge Vignette
        vignetteLayer.opacity = Float(settings.vignetteIntensity * 1.5)

        CATransaction.commit()
    }

    // Double-click & Click feedback when in Shield mode
    public override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClicked?()
        } else {
            showLockPillBriefly()
        }
    }

    private func showLockPillBriefly() {
        pillDismissTimer?.invalidate()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            lockPillView.animator().alphaValue = 1.0
        }

        pillDismissTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.35
                    self?.lockPillView.animator().alphaValue = 0.0
                }
            }
        }
    }
}
