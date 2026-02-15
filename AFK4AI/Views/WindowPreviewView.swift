import SwiftUI

// WindowPreviewView is now integrated into LockScreenView's terminal mirror.
// This file is kept for potential standalone usage.

struct WindowPreviewView: View {
    let image: NSImage

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
