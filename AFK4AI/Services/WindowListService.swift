import Foundation
import CoreGraphics

class WindowListService {
    func getWindowList() -> [WindowInfo] {
        guard let windowList = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        var windows: [WindowInfo] = []
        for windowDict in windowList {
            guard let windowID = windowDict[kCGWindowNumber as String] as? CGWindowID,
                  let ownerName = windowDict[kCGWindowOwnerName as String] as? String,
                  let layer = windowDict[kCGWindowLayer as String] as? Int,
                  layer == 0 else {
                continue
            }

            // Skip our own app and system UI elements
            if ownerName == "AFK4AI" || ownerName == "Window Server" || ownerName == "SystemUIServer" {
                continue
            }

            let windowName = windowDict[kCGWindowName as String] as? String ?? ""

            var bounds = CGRect.zero
            if let boundsDict = windowDict[kCGWindowBounds as String] as? [String: Any] {
                let x = boundsDict["X"] as? CGFloat ?? 0
                let y = boundsDict["Y"] as? CGFloat ?? 0
                let width = boundsDict["Width"] as? CGFloat ?? 0
                let height = boundsDict["Height"] as? CGFloat ?? 0
                bounds = CGRect(x: x, y: y, width: width, height: height)
            }

            // Only include windows with meaningful size
            if bounds.width > 100 && bounds.height > 100 {
                let info = WindowInfo(
                    id: windowID,
                    windowID: windowID,
                    ownerName: ownerName,
                    windowName: windowName,
                    bounds: bounds
                )
                windows.append(info)
            }
        }

        return windows
    }
}
