import AppKit

public final class CGSBlurBridge: @unchecked Sendable {
    public static let shared = CGSBlurBridge()

    private typealias CGSConnectionID = UInt32
    private typealias CGSWindowID = Int
    private typealias CGSMainConnectionIDFunc = @convention(c) () -> CGSConnectionID
    private typealias CGSSetWindowBackgroundBlurRadiusFunc = @convention(c) (CGSConnectionID, CGSWindowID, Int32) -> Int32

    private var getMainConn: CGSMainConnectionIDFunc?
    private var setBlur: CGSSetWindowBackgroundBlurRadiusFunc?
    private var isAvailable: Bool = false

    private init() {
        if let handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY) {
            if let connSym = dlsym(handle, "CGSMainConnectionID"),
               let blurSym = dlsym(handle, "CGSSetWindowBackgroundBlurRadius") {
                getMainConn = unsafeBitCast(connSym, to: CGSMainConnectionIDFunc.self)
                setBlur = unsafeBitCast(blurSym, to: CGSSetWindowBackgroundBlurRadiusFunc.self)
                isAvailable = true
            }
        }
    }

    @MainActor
    @discardableResult
    public func setBlurRadius(for window: NSWindow, radius: Double) -> Bool {
        guard isAvailable, let getMainConn = getMainConn, let setBlur = setBlur else {
            return false
        }
        let conn = getMainConn()
        let intRadius = Int32(clamping: Int(radius))
        let result = setBlur(conn, window.windowNumber, intRadius)
        return result == 0
    }
}
