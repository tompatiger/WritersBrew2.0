import SwiftUI

public struct SelectionActionPalette: View {
    let selectedText: String
    var onRewrite: (String) -> Void
    var onAskGhostWriter: (String) -> Void
    var onDismiss: () -> Void
    
    @State private var isCustomPromptActive: Bool = false
    @State private var customPrompt: String = ""
    @State private var isHovered: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main Action Bar
            HStack(spacing: 8) {
                Label("Ghost Writer", systemImage: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                
                Divider()
                    .frame(height: 14)
                
                // Rewrite Menu
                Menu {
                    Button("Concise & Tight") {
                        onRewrite("Tighten the prose, remove unnecessary filler, and maximize impact.")
                    }
                    Button("Descriptive & Sensory") {
                        onRewrite("Deepen sensory immersion with evocative physical textures and atmospheric lighting.")
                    }
                    Button("Elevate Vocabulary & Style") {
                        onRewrite("Elevate sentence structure and vocabulary to literary elegance.")
                    }
                    Button("Dramatic & Emotional") {
                        onRewrite("Heighten emotional stakes and psychological tension.")
                    }
                    Divider()
                    Button("Custom Instruction...") {
                        withAnimation {
                            isCustomPromptActive = true
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.and.outline")
                        Text("Rewrite")
                    }
                    .font(.system(size: 11, weight: .medium))
                }
                .menuStyle(.borderlessButton)
                
                // Expand button
                Button {
                    onRewrite("Expand this moment with richer sensory and emotional subtext.")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                        Text("Expand")
                    }
                    .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                
                // Ask AI Chat button
                Button {
                    onAskGhostWriter(selectedText)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Ask Ghost Writer")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Custom instruction field (if triggered)
            if isCustomPromptActive {
                Divider().opacity(0.3)
                
                HStack(spacing: 8) {
                    TextField("How should Ghost Writer rewrite this?", text: $customPrompt)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .onSubmit {
                            submitCustomPrompt()
                        }
                    
                    Button("Go") {
                        submitCustomPrompt()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .liquidGlassCard(cornerRadius: 14, opacity: 0.92)
        .shadow(color: Color.black.opacity(0.2), radius: 14, x: 0, y: 6)
        .frame(maxWidth: 480)
    }
    
    private func submitCustomPrompt() {
        let trimmed = customPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onRewrite(trimmed)
        customPrompt = ""
        isCustomPromptActive = false
    }
}
