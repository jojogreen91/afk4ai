import Foundation
import CoreGraphics

class InputBlocker {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // Called when user tries Cmd+Q while locked
    var onQuitAttempt: (() -> Void)?

    /// Returns true if event tap was created successfully
    @discardableResult
    func startBlocking() -> Bool {
        var eventMask: CGEventMask = 0
        eventMask |= (1 << CGEventType.keyDown.rawValue)
        eventMask |= (1 << CGEventType.keyUp.rawValue)
        eventMask |= (1 << CGEventType.leftMouseDown.rawValue)
        eventMask |= (1 << CGEventType.leftMouseUp.rawValue)
        eventMask |= (1 << CGEventType.rightMouseDown.rawValue)
        eventMask |= (1 << CGEventType.rightMouseUp.rawValue)
        eventMask |= (1 << CGEventType.mouseMoved.rawValue)
        eventMask |= (1 << CGEventType.scrollWheel.rawValue)
        eventMask |= (1 << CGEventType.flagsChanged.rawValue)

        let refcon = Unmanaged.passUnretained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }
                let blocker = Unmanaged<InputBlocker>.fromOpaque(refcon).takeUnretainedValue()
                return blocker.handleEvent(type: type, event: event)
            },
            userInfo: refcon
        )

        guard let eventTap = eventTap else {
            print("[AFK4AI] Failed to create event tap. Accessibility permission required.")
            return false
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)
        return true
    }

    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags

        if type == .keyDown || type == .keyUp {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            // Block ESC (keycode 53) — prevents fullscreen exit
            if keyCode == 53 {
                return nil
            }

            // Block Cmd+Q (keycode 12) — trigger auth instead of quit
            if flags.contains(.maskCommand) && keyCode == 12 {
                if type == .keyDown {
                    DispatchQueue.main.async { [weak self] in
                        self?.onQuitAttempt?()
                    }
                }
                return nil
            }

            // Block Cmd+W (keycode 13) — prevent window close
            if flags.contains(.maskCommand) && keyCode == 13 {
                return nil
            }

            // Block Cmd+H (keycode 4) — prevent hide
            if flags.contains(.maskCommand) && keyCode == 4 {
                return nil
            }

            // Block Cmd+M (keycode 46) — prevent minimize
            if flags.contains(.maskCommand) && keyCode == 46 {
                return nil
            }

            // Block Cmd+Tab (keycode 48) — prevent app switch
            if flags.contains(.maskCommand) && keyCode == 48 {
                return nil
            }

            // Allow Cmd+Option+Esc (Force Quit) — macOS can't reliably block this
            if flags.contains(.maskCommand) && flags.contains(.maskAlternate) && keyCode == 53 {
                return Unmanaged.passRetained(event)
            }

            // Block all other keys
            return nil
        }

        // Allow left mouse & mouse movement for UI interaction
        // (screenSaver-level fullscreen window captures all clicks)
        if type == .leftMouseDown || type == .leftMouseUp || type == .mouseMoved {
            return Unmanaged.passRetained(event)
        }

        // Block right mouse and scroll
        if type == .rightMouseDown || type == .rightMouseUp || type == .scrollWheel {
            return nil
        }

        return Unmanaged.passRetained(event)
    }

    func stopBlocking() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
        onQuitAttempt = nil
    }

    deinit {
        stopBlocking()
    }
}
