import SwiftUI

public struct ProactiveSuggestionBubble: View {
    let suggestion: String
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    @State private var isHovered: Bool = false
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 14, weight: .semibold))
            
            Text(suggestion)
                .font(.system(.body, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .frame(maxWidth: 380, alignment: .leading)
            
            HStack(spacing: 6) {
                Button(action: onAccept) {
                    HStack(spacing: 4) {
                        Text("Accept")
                            .font(.system(size: 11, weight: .semibold))
                        Text("⇥")
                            .font(.system(size: 10, weight: .bold))
                            .opacity(0.7)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.85))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Dismiss suggestion (Esc)")
            }
        }
        .liquidGlassBubble()
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isHovered)
        .onHover { isHovered = $0 }
    }
}
