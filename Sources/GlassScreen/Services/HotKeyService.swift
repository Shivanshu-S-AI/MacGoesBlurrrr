import AppKit
import Carbon

@MainActor
public final class HotKeyService {
    public static let shared = HotKeyService()

    private var hotKeyRef: EventHotKeyRef?
    private var shuffleHotKeyRef: EventHotKeyRef?
    public var onHotKeyTriggered: (() -> Void)?
    public var onShuffleHotKeyTriggered: (() -> Void)?

    private init() {
        setupEventHandler()
    }

    private func setupEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, eventRef, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if status == noErr && hotKeyID.signature == OSType(0x474C5353) { // 'GLSS'
                    Task { @MainActor in
                        if hotKeyID.id == 1 {
                            HotKeyService.shared.onHotKeyTriggered?()
                        } else if hotKeyID.id == 2 {
                            HotKeyService.shared.onShuffleHotKeyTriggered?()
                        }
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }

    public func registerDefaultHotKey() {
        unregister()

        // 1. Primary Toggle HotKey (⌥⌘B): blurs with random style or unblurs
        let hotKeyID1 = EventHotKeyID(signature: OSType(0x474C5353), id: 1)
        let status1 = RegisterEventHotKey(
            UInt32(kVK_ANSI_B),
            UInt32(cmdKey | optionKey),
            hotKeyID1,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        if status1 != noErr {
            print("Failed to register primary hotkey (⌥⌘B), status: \(status1)")
        }

        // 2. Instant Shuffle HotKey (⌥⇧⌘B): shuffles random style instantly
        let hotKeyID2 = EventHotKeyID(signature: OSType(0x474C5353), id: 2)
        let status2 = RegisterEventHotKey(
            UInt32(kVK_ANSI_B),
            UInt32(cmdKey | optionKey | shiftKey),
            hotKeyID2,
            GetApplicationEventTarget(),
            0,
            &shuffleHotKeyRef
        )
        if status2 != noErr {
            print("Failed to register shuffle hotkey (⌥⇧⌘B), status: \(status2)")
        }
    }

    public func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let ref = shuffleHotKeyRef {
            UnregisterEventHotKey(ref)
            shuffleHotKeyRef = nil
        }
    }
}
