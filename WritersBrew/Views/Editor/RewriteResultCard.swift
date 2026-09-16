import SwiftUI

public struct RewriteResultCard: View {
    let originalText: String
    let rewrittenText: String
    var onReplace: () -> Void
    var onInsertBelow: () -> Void
    var onDismiss: () -> Void
    
    @State private var isShowingDiff: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("AI Rewrite Suggestion", systemImage: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider().opacity(0.3)
            
            // Generated Text
            Text(rewrittenText)
                .font(.system(.body, design: .serif))
                .lineSpacing(4)
                .padding(10)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onReplace) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.swap")
                        Text("Replace Selection")
                    }
                    .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button(action: onInsertBelow) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.doc")
                        Text("Insert Below")
                    }
                    .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(rewrittenText, forType: .string)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Copy to clipboard")
            }
        }
        .padding(14)
        .liquidGlassCard(cornerRadius: 14, opacity: 0.94)
        .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 8)
        .frame(maxWidth: 480)
    }
}
