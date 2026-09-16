import SwiftUI

public struct VoiceSkillView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var voiceEngine = VoiceLearningEngine.shared
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Living Voice Skill", systemImage: "person.crop.circle.badge.waveform")
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Summary Banner
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Personal Voice Model")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("WritersBrew adapts to your voice as you write and accept or reject AI suggestions. Fine-tune your rhythm and vocabulary parameters below.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                        
                        HStack(spacing: 16) {
                            statItem(label: "Accepted", value: "\(voiceEngine.currentVoiceSkill.acceptedSuggestionsCount)")
                            statItem(label: "Rejected", value: "\(voiceEngine.currentVoiceSkill.rejectedSuggestionsCount)")
                            statItem(label: "Acceptance Rate", value: "\(Int(voiceEngine.currentVoiceSkill.acceptanceRate * 100))%")
                            statItem(label: "Analyzed Words", value: "\(voiceEngine.currentVoiceSkill.totalWordsAnalyzed)")
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                    .liquidGlassCard()
                    
                    // Sliders Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Style & Tone Tuning")
                            .font(.system(size: 13, weight: .bold))
                        
                        sliderRow(
                            title: "Vocabulary Erudition",
                            lowLabel: "Plainspoken",
                            highLabel: "Literary",
                            value: $voiceEngine.currentVoiceSkill.vocabularySophistication
                        )
                        
                        sliderRow(
                            title: "Sentence Rhythm",
                            lowLabel: "Staccato & Punchy",
                            highLabel: "Flowing & Periodic",
                            value: $voiceEngine.currentVoiceSkill.sentenceRhythmPacing
                        )
                        
                        sliderRow(
                            title: "Emotional Resonance",
                            lowLabel: "Detached / Stoic",
                            highLabel: "Warm / Lyrical",
                            value: $voiceEngine.currentVoiceSkill.emotionalWarmth
                        )
                        
                        sliderRow(
                            title: "Sensory Density",
                            lowLabel: "Conceptual",
                            highLabel: "Tactile & Visceral",
                            value: $voiceEngine.currentVoiceSkill.sensoryDensity
                        )
                    }
                    
                    // Distinctive Vocabulary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Learned Distinctive Vocabulary")
                            .font(.system(size: 13, weight: .bold))
                        
                        Text("Words Ghost Writer has observed you love incorporating:")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(voiceEngine.currentVoiceSkill.distinctiveVocabulary, id: \.self) { word in
                                Text(word)
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Avoided Clichés
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Strictly Avoided Clichés")
                            .font(.system(size: 13, weight: .bold))
                        
                        FlowLayout(spacing: 8) {
                            ForEach(voiceEngine.currentVoiceSkill.avoidedClichés, id: \.self) { cliché in
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.red)
                                    Text(cliché)
                                        .font(.system(size: 11))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    
                    // Custom Directives
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Direct Author Instructions")
                            .font(.system(size: 13, weight: .bold))
                        
                        TextEditor(text: $voiceEngine.currentVoiceSkill.customDirectives)
                            .font(.system(size: 12.5))
                            .frame(height: 70)
                            .padding(8)
                            .background(Color.primary.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Reset Button
                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            voiceEngine.resetToDefaults()
                        } label: {
                            Label("Reset Voice Skill to Factory Defaults", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.red)
                        .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .frame(width: 580, height: 620)
        .background(.ultraThinMaterial)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
    
    private func sliderRow(title: String, lowLabel: String, highLabel: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: value, in: 0.0...1.0)
            
            HStack {
                Text(lowLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(highLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Simple FlowLayout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 500
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            maxHeightInRow = max(maxHeightInRow, size.height)
            currentX += size.width + spacing
        }
        height = currentY + maxHeightInRow
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var maxHeightInRow: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            maxHeightInRow = max(maxHeightInRow, size.height)
            currentX += size.width + spacing
        }
    }
}
