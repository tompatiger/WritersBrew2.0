import SwiftUI

// MARK: - Liquid Glass View Modifiers

public struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16.0
    var opacity: CGFloat = 0.75
    
    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

public struct LiquidGlassPillModifier: ViewModifier {
    var isSelected: Bool = false
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(Color.accentColor.opacity(0.25)) : AnyShapeStyle(.ultraThinMaterial))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.accentColor.opacity(0.6) : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
            }
    }
}

public struct LiquidGlassBubbleModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
            .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
    }
}

// MARK: - View Extension

extension View {
    public func liquidGlassCard(cornerRadius: CGFloat = 16.0, opacity: CGFloat = 0.85) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    public func liquidGlassPill(isSelected: Bool = false) -> some View {
        self.modifier(LiquidGlassPillModifier(isSelected: isSelected))
    }
    
    public func liquidGlassBubble() -> some View {
        self.modifier(LiquidGlassBubbleModifier())
    }
}
