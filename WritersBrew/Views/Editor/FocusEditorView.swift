import SwiftUI
import AppKit

public struct FocusEditorView: View {
    @Binding var document: BrewDocument
    @Binding var isFocusModeActive: Bool
    @Binding var showGhostWriterSidebar: Bool
    @Binding var showAnalyzerInspector: Bool
    
    @State private var activeBubbleSuggestion: String? = nil
    @State private var suggestionTask: Task<Void, Never>? = nil
    @State private var activeStyle: StyleProfile = .narrativeFiction
    @State private var currentReport: AnalysisReport = .empty
    
    // Selection & Highlight AI states
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var selectedText: String = ""
    @State private var activeRewriteResult: String? = nil
    @State private var isRewriting: Bool = false
    
    private var prefs = PreferencesStore.shared
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Canvas Background
            prefs.currentMood.canvasBackground
                .ignoresSafeArea()
            
            // Editor Scrolling Area
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 24) {
                        // Title Field
                        TextField("Document Title", text: $document.title)
                            .font(.system(size: prefs.editorFontSize + 12, weight: .bold, design: prefs.currentMood.preferredDesign))
                            .foregroundStyle(prefs.currentMood.textColor)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: prefs.editorMeasureWidth, alignment: .leading)
                            .opacity(isFocusModeActive ? 0.35 : 1.0)
                            .padding(.top, 40)
                            .animation(.easeInOut(duration: 0.25), value: isFocusModeActive)
                        
                        // Text Surface
                        ZStack(alignment: .topLeading) {
                            if document.content.isEmpty {
                                Text("The page is quiet. Begin writing or tap ⌥Space for Ghost Writer...")
                                    .font(.system(size: prefs.editorFontSize, design: prefs.currentMood.preferredDesign))
                                    .foregroundStyle(prefs.currentMood.secondaryTextColor.opacity(0.7))
                                    .padding(.top, 8)
                            }
                            
                            MacEditorTextView(
                                text: $document.content,
                                isFocusModeActive: isFocusModeActive,
                                fontSize: prefs.editorFontSize,
                                fontDesign: prefs.currentMood.preferredDesign,
                                isTypewriterScrolling: prefs.isTypewriterScrollingEnabled,
                                currentMood: prefs.currentMood,
                                onTextChange: handleTextChange,
                                onSelectionChange: handleSelectionChange
                            )
                            .frame(minHeight: 650)
                        }
                        .frame(maxWidth: prefs.editorMeasureWidth)
                        .padding(.bottom, 140) // breathing room for floating palettes & footer
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Overlays & Floating Palettes
            VStack(spacing: 12) {
                // 1. Rewrite Result Card
                if let rewritten = activeRewriteResult {
                    RewriteResultCard(
                        originalText: selectedText,
                        rewrittenText: rewritten,
                        onReplace: {
                            replaceSelection(with: rewritten)
                        },
                        onInsertBelow: {
                            insertBelowSelection(with: rewritten)
                        },
                        onDismiss: {
                            withAnimation {
                                activeRewriteResult = nil
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
                }
                
                // 2. Loading indicator while rewriting
                if isRewriting {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Ghost Writer is refining prose...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(prefs.currentMood.textColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .liquidGlassCard(cornerRadius: 12)
                    .transition(.opacity)
                }
                
                // 3. Selection Action Palette (When text is highlighted)
                if !selectedText.isEmpty && activeRewriteResult == nil && !isRewriting && !isFocusModeActive {
                    SelectionActionPalette(
                        selectedText: selectedText,
                        onRewrite: { instruction in
                            executeRewrite(instruction: instruction)
                        },
                        onAskGhostWriter: { text in
                            askGhostWriterAboutSelection(text: text)
                        },
                        onDismiss: {
                            withAnimation {
                                selectedText = ""
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
                }
                
                // 4. Proactive Suggestion Bubble (when paused & no selection)
                if let suggestion = activeBubbleSuggestion, selectedText.isEmpty && activeRewriteResult == nil && !isFocusModeActive {
                    ProactiveSuggestionBubble(
                        suggestion: suggestion,
                        onAccept: acceptSuggestion,
                        onDismiss: dismissSuggestion
                    )
                    .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .opacity))
                }
            }
            .padding(.bottom, 68)
            
            // Editor Footer Bar (Word Count, Reading Time, Style Profile, Analyzer)
            if !isFocusModeActive {
                editorFooter
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFocusModeActive)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeBubbleSuggestion != nil)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedText.isEmpty)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeRewriteResult != nil)
        .onAppear {
            updateAnalysis()
            activeStyle = StyleProfile.defaultProfiles.first(where: { $0.id == document.styleProfileId }) ?? .narrativeFiction
        }
        .onChange(of: document.styleProfileId) { _, newId in
            activeStyle = StyleProfile.defaultProfiles.first(where: { $0.id == newId }) ?? .narrativeFiction
            updateAnalysis()
        }
        .onChange(of: document.content) { _, _ in
            document.updatedAt = Date()
            DocumentStore.shared.save()
        }
    }
    
    // MARK: - Footer
    
    private var editorFooter: some View {
        HStack(spacing: 16) {
            // Style Profile Pill
            Menu {
                ForEach(StyleProfile.defaultProfiles) { profile in
                    Button {
                        document.styleProfileId = profile.id
                    } label: {
                        Label(profile.name, systemImage: profile.icon)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: activeStyle.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(prefs.currentMood.accentColor)
                    Text(activeStyle.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(prefs.currentMood.textColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .menuStyle(.borderlessButton)
            
            Spacer()
            
            // Metrics (Word count & Reading Time)
            HStack(spacing: 12) {
                Text("\(document.wordCount) words")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(prefs.currentMood.secondaryTextColor)
                
                Text("•")
                    .foregroundStyle(prefs.currentMood.secondaryTextColor.opacity(0.4))
                
                Text("\(Int(document.readingTimeMinutes)) min read")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(prefs.currentMood.secondaryTextColor)
            }
            
            Spacer()
            
            // Real-Time Analyzer Badge Pill
            if prefs.isRealtimeAnalyzerEnabled {
                Button {
                    showAnalyzerInspector.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(currentReport.label.color)
                            .frame(width: 7, height: 7)
                        
                        Text("\(currentReport.score)% · \(currentReport.label.rawValue)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(prefs.currentMood.textColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule().stroke(currentReport.label.color.opacity(0.35), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .help("View Prose Analysis & Craft Insights")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
    
    // MARK: - Selection Actions
    
    private func handleSelectionChange(range: NSRange, text: String) {
        self.selectedRange = range
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if range.length > 2 && !trimmed.isEmpty {
            self.selectedText = trimmed
            self.activeBubbleSuggestion = nil
        } else {
            self.selectedText = ""
        }
    }
    
    private func executeRewrite(instruction: String) {
        guard !selectedText.isEmpty else { return }
        isRewriting = true
        activeRewriteResult = nil
        
        Task {
            do {
                let rewritten = try await AIService.shared.rewrite(
                    selection: selectedText,
                    instruction: instruction,
                    style: activeStyle,
                    voice: VoiceLearningEngine.shared.currentVoiceSkill
                )
                await MainActor.run {
                    self.activeRewriteResult = rewritten
                    self.isRewriting = false
                }
            } catch {
                await MainActor.run {
                    self.activeRewriteResult = "Could not rewrite: \(error.localizedDescription)"
                    self.isRewriting = false
                }
            }
        }
    }
    
    private func replaceSelection(with replacement: String) {
        let nsString = document.content as NSString
        guard selectedRange.location + selectedRange.length <= nsString.length else { return }
        
        withAnimation {
            document.content = nsString.replacingCharacters(in: selectedRange, with: replacement)
            VoiceLearningEngine.shared.recordAcceptedSuggestion(text: replacement)
            selectedText = ""
            selectedRange = NSRange(location: 0, length: 0)
            activeRewriteResult = nil
        }
    }
    
    private func insertBelowSelection(with addition: String) {
        let nsString = document.content as NSString
        guard selectedRange.location + selectedRange.length <= nsString.length else { return }
        
        let insertIndex = selectedRange.location + selectedRange.length
        let prefix = nsString.substring(to: insertIndex)
        let suffix = nsString.substring(from: insertIndex)
        
        withAnimation {
            document.content = prefix + "\n\n" + addition + suffix
            VoiceLearningEngine.shared.recordAcceptedSuggestion(text: addition)
            selectedText = ""
            selectedRange = NSRange(location: 0, length: 0)
            activeRewriteResult = nil
        }
    }
    
    private func askGhostWriterAboutSelection(text: String) {
        showGhostWriterSidebar = true
        selectedText = ""
        // Ghost Writer sidebar is context-aware and receives current selection & document
    }
    
    // MARK: - Proactive Suggestions
    
    private func handleTextChange(newText: String) {
        suggestionTask?.cancel()
        
        if prefs.isTypewriterSoundEnabled {
            NSSound(named: "Tink")?.play()
        }
        
        if prefs.isRealtimeAnalyzerEnabled {
            updateAnalysis()
        }
        
        guard prefs.isProactiveSuggestionsEnabled && selectedText.isEmpty else { return }
        
        suggestionTask = Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s pause
            if !Task.isCancelled {
                let suggestion = await AIService.shared.fetchProactiveSuggestion(
                    precedingText: newText,
                    style: activeStyle
                )
                await MainActor.run {
                    self.activeBubbleSuggestion = suggestion
                }
            }
        }
    }
    
    private func acceptSuggestion() {
        guard let suggestion = activeBubbleSuggestion else { return }
        withAnimation {
            if !document.content.hasSuffix(" ") && !document.content.isEmpty {
                document.content += " "
            }
            document.content += suggestion
            VoiceLearningEngine.shared.recordAcceptedSuggestion(text: suggestion)
            activeBubbleSuggestion = nil
        }
    }
    
    private func dismissSuggestion() {
        if let suggestion = activeBubbleSuggestion {
            VoiceLearningEngine.shared.recordRejectedSuggestion(text: suggestion)
        }
        withAnimation {
            activeBubbleSuggestion = nil
        }
    }
    
    private func updateAnalysis() {
        self.currentReport = ProseAnalyzer.shared.analyze(text: document.content, style: activeStyle)
    }
}

// MARK: - Native AppKit Text View for Precision Typography & Focus Dimming

struct MacEditorTextView: NSViewRepresentable {
    @Binding var text: String
    var isFocusModeActive: Bool
    var fontSize: CGFloat
    var fontDesign: Font.Design
    var isTypewriterScrolling: Bool
    var currentMood: ThemeMood
    var onTextChange: (String) -> Void
    var onSelectionChange: (NSRange, String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.drawsBackground = false
        scrollView.drawsBackground = false
        
        // Typography & Colors
        applyTypography(to: textView)
        textView.string = text
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
        }
        
        applyTypography(to: textView)
        
        // Paragraph Focus Dimming
        if isFocusModeActive {
            applyFocusModeDimming(to: textView)
        } else {
            clearDimming(on: textView)
        }
        
        // Typewriter scrolling
        if isTypewriterScrolling {
            centerCursor(in: textView, scrollView: nsView)
        }
    }
    
    private func applyTypography(to textView: NSTextView) {
        let nsFont: NSFont
        switch fontDesign {
        case .serif:
            nsFont = NSFont(name: "New York", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        case .monospaced:
            nsFont = NSFont.monospacedSystemFont(ofSize: fontSize - 1, weight: .regular)
        default:
            nsFont = NSFont.systemFont(ofSize: fontSize, weight: .regular)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = fontSize * 0.42
        paragraphStyle.paragraphSpacing = fontSize * 0.65
        
        textView.font = nsFont
        textView.defaultParagraphStyle = paragraphStyle
        textView.textColor = currentMood.nsTextColor
        textView.insertionPointColor = currentMood.nsInsertionPointColor
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor.controlAccentColor.withAlphaComponent(0.35),
            .foregroundColor: currentMood.nsTextColor
        ]
    }
    
    private func applyFocusModeDimming(to textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let fullString = textStorage.string
        let selectedRange = textView.selectedRange()
        
        let nsString = fullString as NSString
        let paragraphRange = nsString.paragraphRange(for: selectedRange)
        
        textStorage.beginEditing()
        textStorage.addAttribute(.foregroundColor, value: currentMood.nsSecondaryTextColor.withAlphaComponent(0.22), range: NSRange(location: 0, length: nsString.length))
        textStorage.addAttribute(.foregroundColor, value: currentMood.nsTextColor, range: paragraphRange)
        textStorage.endEditing()
    }
    
    private func clearDimming(on textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let nsString = textStorage.string as NSString
        guard nsString.length > 0 else { return }
        
        textStorage.beginEditing()
        textStorage.addAttribute(.foregroundColor, value: currentMood.nsTextColor, range: NSRange(location: 0, length: nsString.length))
        textStorage.endEditing()
    }
    
    private func centerCursor(in textView: NSTextView, scrollView: NSScrollView) {
        guard let layoutManager = textView.layoutManager else { return }
        let cursorLocation = textView.selectedRange().location
        let glyphIndex = layoutManager.glyphIndexForCharacter(at: cursorLocation)
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        
        let clipView = scrollView.contentView
        let targetY = lineRect.origin.y - (clipView.bounds.height / 2) + (lineRect.height / 2)
        let clampedY = max(0, min(targetY, textView.bounds.height - clipView.bounds.height))
        
        clipView.scroll(to: NSPoint(x: 0, y: clampedY))
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditorTextView
        
        init(_ parent: MacEditorTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.onTextChange(textView.string)
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let range = textView.selectedRange()
            let nsString = textView.string as NSString
            let selectedSubstring = range.length > 0 && range.location + range.length <= nsString.length
                ? nsString.substring(with: range)
                : ""
            
            parent.onSelectionChange(range, selectedSubstring)
            
            if parent.isFocusModeActive {
                parent.applyFocusModeDimming(to: textView)
            }
            if parent.isTypewriterScrolling, let scrollView = textView.enclosingScrollView {
                parent.centerCursor(in: textView, scrollView: scrollView)
            }
        }
    }
}
