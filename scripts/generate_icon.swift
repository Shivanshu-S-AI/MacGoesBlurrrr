import AppKit

func drawGlassIcon(size: CGFloat) -> CGImage? {
    let s = size
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: Int(s),
        height: Int(s),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let rect = CGRect(x: 0, y: 0, width: s, height: s)

    // Outer margin for macOS squircle shadow/padding
    let margin = s * 0.08
    let squircleRect = rect.insetBy(dx: margin, dy: margin)
    let cornerRadius = squircleRect.width * 0.224 // Apple continuous squircle radius ratio

    let squirclePath = CGPath(
        roundedRect: squircleRect,
        cornerWidth: cornerRadius,
        cornerHeight: cornerRadius,
        transform: nil
    )

    // Shadow
    ctx.saveGState()
    ctx.setShadow(
        offset: CGSize(width: 0, height: -s * 0.04),
        blur: s * 0.08,
        color: NSColor.black.withAlphaComponent(0.45).cgColor
    )
    ctx.addPath(squirclePath)
    ctx.setFillColor(NSColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Base Squircle Background Gradient
    ctx.saveGState()
    ctx.addPath(squirclePath)
    ctx.clip()

    let baseColors = [
        NSColor(red: 0.07, green: 0.11, blue: 0.20, alpha: 1.0).cgColor,
        NSColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 1.0).cgColor
    ] as CFArray
    let baseGrad = CGGradient(colorsSpace: colorSpace, colors: baseColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(
        baseGrad,
        start: CGPoint(x: squircleRect.midX, y: squircleRect.maxY),
        end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
        options: []
    )

    // Glowing Ambient Orbs behind glass
    let cyanOrbCenter = CGPoint(x: squircleRect.minX + squircleRect.width * 0.35, y: squircleRect.minY + squircleRect.height * 0.65)
    let cyanColors = [
        NSColor(red: 0.02, green: 0.78, blue: 0.95, alpha: 0.65).cgColor,
        NSColor(red: 0.02, green: 0.78, blue: 0.95, alpha: 0.0).cgColor
    ] as CFArray
    let cyanGrad = CGGradient(colorsSpace: colorSpace, colors: cyanColors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(
        cyanGrad,
        startCenter: cyanOrbCenter,
        startRadius: 0,
        endCenter: cyanOrbCenter,
        endRadius: squircleRect.width * 0.45,
        options: []
    )

    let magentaOrbCenter = CGPoint(x: squircleRect.minX + squircleRect.width * 0.68, y: squircleRect.minY + squircleRect.height * 0.32)
    let magentaColors = [
        NSColor(red: 0.92, green: 0.22, blue: 0.62, alpha: 0.55).cgColor,
        NSColor(red: 0.92, green: 0.22, blue: 0.62, alpha: 0.0).cgColor
    ] as CFArray
    let magentaGrad = CGGradient(colorsSpace: colorSpace, colors: magentaColors, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(
        magentaGrad,
        startCenter: magentaOrbCenter,
        startRadius: 0,
        endCenter: magentaOrbCenter,
        endRadius: squircleRect.width * 0.45,
        options: []
    )

    // Central Frosted Aperture Lens Ring
    let center = CGPoint(x: squircleRect.midX, y: squircleRect.midY)
    let outerRadius = squircleRect.width * 0.28
    let innerRadius = squircleRect.width * 0.16

    // Lens Outer Ring
    ctx.setLineWidth(s * 0.022)
    let lensBorderColors = [
        NSColor(white: 1.0, alpha: 0.6).cgColor,
        NSColor(white: 1.0, alpha: 0.1).cgColor
    ] as CFArray
    let lensBorderGrad = CGGradient(colorsSpace: colorSpace, colors: lensBorderColors, locations: [0.0, 1.0])!
    ctx.saveGState()
    ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(
        lensBorderGrad,
        start: CGPoint(x: center.x - outerRadius, y: center.y + outerRadius),
        end: CGPoint(x: center.x + outerRadius, y: center.y - outerRadius),
        options: []
    )
    ctx.restoreGState()

    // Frosted Lens Disc
    ctx.saveGState()
    ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.clip()
    let discColors = [
        NSColor(white: 1.0, alpha: 0.22).cgColor,
        NSColor(white: 1.0, alpha: 0.08).cgColor
    ] as CFArray
    let discGrad = CGGradient(colorsSpace: colorSpace, colors: discColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(
        discGrad,
        start: CGPoint(x: center.x, y: center.y + outerRadius),
        end: CGPoint(x: center.x, y: center.y - outerRadius),
        options: []
    )
    ctx.restoreGState()

    // Inner Glowing Core
    ctx.saveGState()
    ctx.addArc(center: center, radius: innerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    let coreColors = [
        NSColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 0.9).cgColor,
        NSColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 0.4).cgColor
    ] as CFArray
    let coreGrad = CGGradient(colorsSpace: colorSpace, colors: coreColors, locations: [0.0, 1.0])!
    ctx.clip()
    ctx.drawRadialGradient(
        coreGrad,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: innerRadius,
        options: []
    )
    ctx.restoreGState()

    // Specular Highlight across top edge of squircle
    let sheenColors = [
        NSColor(white: 1.0, alpha: 0.45).cgColor,
        NSColor(white: 1.0, alpha: 0.0).cgColor
    ] as CFArray
    let sheenGrad = CGGradient(colorsSpace: colorSpace, colors: sheenColors, locations: [0.0, 1.0])!
    ctx.saveGState()
    ctx.setLineWidth(s * 0.015)
    ctx.addPath(squirclePath)
    ctx.replacePathWithStrokedPath()
    ctx.clip()
    ctx.drawLinearGradient(
        sheenGrad,
        start: CGPoint(x: squircleRect.midX, y: squircleRect.maxY),
        end: CGPoint(x: squircleRect.midX, y: squircleRect.midY),
        options: []
    )
    ctx.restoreGState()

    ctx.restoreGState() // Squircle clip

    return ctx.makeImage()
}

// Generate iconset
let iconsetPath = "Resources/AppIcon.iconset"
let fileManager = FileManager.default
try? fileManager.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in sizes {
    if let img = drawGlassIcon(size: size) {
        let rep = NSBitmapImageRep(cgImage: img)
        let pngData = rep.representation(using: .png, properties: [:])
        let dest = "\(iconsetPath)/\(filename)"
        try? pngData?.write(to: URL(fileURLWithPath: dest))
        print("Generated \(filename) (\(Int(size))x\(Int(size)))")
    }
}
print("Iconset generation complete!")
