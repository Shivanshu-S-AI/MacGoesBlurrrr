import AppKit

public final class NoiseGenerator: @unchecked Sendable {
    public static let shared = NoiseGenerator()

    private var cachedPatternColor: NSColor?
    private var cachedImage: NSImage?

    private init() {}

    public func getNoiseImage(size: Int = 128) -> NSImage {
        if let cached = cachedImage { return cached }

        let width = size
        let height = size
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for i in 0..<(width * height) {
            let offset = i * 4
            // Subtle frosted grain: neutral luminance with micro-scattering alpha
            let lum = UInt8.random(in: 200...255)
            let alpha = UInt8.random(in: 15...55)
            pixels[offset] = lum     // R
            pixels[offset + 1] = lum // G
            pixels[offset + 2] = lum // B
            pixels[offset + 3] = alpha // A
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ), let cgImage = context.makeImage() else {
            let fallback = NSImage(size: NSSize(width: size, height: size))
            return fallback
        }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
        self.cachedImage = nsImage
        return nsImage
    }

    public func getNoisePatternColor(size: Int = 128) -> NSColor {
        if let cached = cachedPatternColor { return cached }
        let img = getNoiseImage(size: size)
        let pattern = NSColor(patternImage: img)
        self.cachedPatternColor = pattern
        return pattern
    }
}
