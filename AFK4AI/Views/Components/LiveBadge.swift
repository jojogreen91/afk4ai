import SwiftUI

struct LiveBadge: View {
    let color: Color
    @State private var isBlinking = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(isBlinking ? 0.8 : 0.0), radius: 4)
                .opacity(isBlinking ? 1.0 : 0.3)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isBlinking
                )
            Text("LIVE")
                .font(Theme.mono(9, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.6))
        .clipShape(Capsule())
        .onAppear {
            isBlinking = true
        }
    }
}
