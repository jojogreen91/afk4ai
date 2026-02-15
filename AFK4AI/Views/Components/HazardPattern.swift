import SwiftUI

struct HazardPattern: View {
    var color: Color = Color(hex: 0xFF4D00)
    var width: CGFloat = 60
    var stripeWidth: CGFloat = 15

    var body: some View {
        Canvas { context, size in
            let stripeCount = Int(size.width / stripeWidth) + 2
            for i in 0..<stripeCount {
                let x = CGFloat(i) * stripeWidth * 2 - size.height
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height + stripeWidth, y: size.height))
                path.addLine(to: CGPoint(x: x + stripeWidth, y: 0))
                path.closeSubpath()
                context.fill(path, with: .color(color))
            }
        }
        .frame(width: width)
        .clipped()
    }
}

struct ScanlineOverlay: View {
    var lineSpacing: CGFloat = 4
    var opacity: Double = 0.15

    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.addRect(CGRect(x: 0, y: y, width: size.width, height: lineSpacing / 2))
                context.fill(path, with: .color(.black.opacity(0.25)))
                y += lineSpacing
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}

struct GlowDot: View {
    var color: Color = Color(hex: 0x00FF41)
    var size: CGFloat = 8
    var animate: Bool = false

    @State private var isGlowing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.8), radius: isGlowing ? 6 : 4)
            .onAppear {
                if animate {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        isGlowing = true
                    }
                }
            }
    }
}

struct KeyBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.mono(12, weight: .bold))
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    var color: Color = Color(hex: 0xFF4D00)

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(title.uppercased())
                .font(Theme.display(11, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
        }
    }
}
