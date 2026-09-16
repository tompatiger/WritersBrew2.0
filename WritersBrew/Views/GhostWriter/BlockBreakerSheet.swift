import SwiftUI

public struct BlockBreakerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let documentContext: String
    let style: StyleProfile
    let voice: VoiceSkill?
    let characters: [BrewCharacter]
    let onInsertProse: (String) -> Void
    
    @State private var isLoading: Bool = true
    @State private var generatedPaths: String = ""
    @State private var selectedTab: Int = 0
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Overcome Writer's Block", systemImage: "bolt.shield.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(20)
            
            Divider()
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Synthesizing narrative paths & psychological subversions...")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Ghost Writer identified three divergent directions to reignite your momentum:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text(generatedPaths)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(6)
                            .padding(16)
                            .liquidGlassCard()
                        
                        HStack {
                            Button {
                                loadPaths()
                            } label: {
                                Label("Regenerate Fresh Sparks", systemImage: "arrow.triangle.2.circlepath")
                            }
                            
                            Spacer()
                            
                            Button {
                                onInsertProse(generatedPaths)
                                dismiss()
                            } label: {
                                Label("Append to Scratchpad", systemImage: "arrow.down.doc")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 580, height: 460)
        .background(.ultraThinMaterial)
        .onAppear {
            loadPaths()
        }
    }
    
    private func loadPaths() {
        isLoading = true
        Task {
            do {
                let paths = try await AIService.shared.breakWritersBlock(
                    documentContext: documentContext,
                    style: style,
                    voice: voice,
                    characters: characters
                )
                await MainActor.run {
                    self.generatedPaths = paths
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.generatedPaths = "Error generating sparks: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
