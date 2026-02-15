import Foundation
import CoreGraphics

struct WindowInfo: Identifiable, Hashable {
    let id: CGWindowID
    let windowID: CGWindowID
    let ownerName: String
    let windowName: String
    let bounds: CGRect

    var displayName: String {
        if windowName.isEmpty {
            return ownerName
        }
        return "\(ownerName) — \(windowName)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(windowID)
    }

    static func == (lhs: WindowInfo, rhs: WindowInfo) -> Bool {
        lhs.windowID == rhs.windowID
    }
}
