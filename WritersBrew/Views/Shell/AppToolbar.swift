import SwiftUI

public struct AppToolbar: ToolbarContent {
    @Binding var isFocusModeActive: Bool
    @Binding var showGhostWriter: Bool
    @Binding var showAnalyzer: Bool
    @Binding var showVoiceSkillSheet: Bool
    @Binding var showSettingsSheet: Bool
    
    var onNewChapter: () -> Void
    var onNewDocument: () -> Void
    var onExportDocument: (ExportFormat) -> Void
    
    public enum ExportFormat: String, CaseIterable {
        case markdown = "Markdown (.md)"
        case plainText = "Plain Text (.txt)"
        case html = "HTML Document (.html)"
    }
    
    public var body: some ToolbarContent {
        // Left side: New Chapter / Manuscript & Focus Mode
        ToolbarItemGroup(placement: .navigation) {
            Menu {
                Button("New Chapter") {
                    onNewChapter()
                }
                Button("New Standalone Manuscript") {
                    onNewDocument()
                }
            } label: {
                Label("New", systemImage: "plus")
            } primaryAction: {
                onNewChapter()
            }
            .help("Create New Chapter (⌘N)")
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isFocusModeActive.toggle()
                }
            } label: {
                Label(isFocusModeActive ? "Exit Focus Mode" : "Focus Mode", systemImage: isFocusModeActive ? "arrow.down.right.and.arrow.up.left" : "viewfinder")
                    .foregroundStyle(isFocusModeActive ? Color.accentColor : Color.primary)
            }
            .help("Toggle Paragraph Focus Mode (⇧⌘F)")
        }
        
        // Center: Theme Mood Selector & Typewriter Mode
        ToolbarItemGroup(placement: .principal) {
            Menu {
                ForEach(ThemeMood.allCases) { mood in
                    Button {
                        PreferencesStore.shared.currentMood = mood
                    } label: {
                        HStack {
                            Label(mood.rawValue, systemImage: mood.icon)
                            if PreferencesStore.shared.currentMood == mood {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: PreferencesStore.shared.currentMood.icon)
                        .foregroundStyle(PreferencesStore.shared.currentMood.accentColor)
                    Text(PreferencesStore.shared.currentMood.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .menuStyle(.borderlessButton)
            .help("Select Ambient Writing Mood")
            
            // Typewriter Mode Button
            Button {
                PreferencesStore.shared.isTypewriterScrollingEnabled.toggle()
            } label: {
                Image(systemName: "arrow.up.and.down.text.horizontal")
                    .foregroundStyle(PreferencesStore.shared.isTypewriterScrollingEnabled ? Color.accentColor : Color.secondary)
            }
            .help("Toggle Typewriter Scrolling (Keeps active line centered)")
        }
        
        // Right: Export, Voice Skill, Analyzer, Ghost Writer, Settings
        ToolbarItemGroup(placement: .primaryAction) {
            // Export Menu
            Menu {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button(format.rawValue) {
                        onExportDocument(format)
                    }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .help("Export Manuscript (Markdown, Plain Text, HTML)")
            
            // Voice Skill Inspector
            Button {
                showVoiceSkillSheet = true
            } label: {
                Label("Voice Skill", systemImage: "person.crop.circle.badge.waveform")
            }
            .help("Inspect and Tune Living Voice Skill")
            
            // Analyzer Inspector
            Button {
                showAnalyzer.toggle()
            } label: {
                Label("Prose Analyzer", systemImage: "sparkle.magnifyingglass")
                    .foregroundStyle(showAnalyzer ? Color.accentColor : Color.primary)
            }
            .help("Toggle Prose & Craft Analyzer")
            
            // Ghost Writer Chat
            Button {
                showGhostWriter.toggle()
            } label: {
                Label("Ghost Writer", systemImage: "sparkles")
                    .foregroundStyle(showGhostWriter ? Color.accentColor : Color.primary)
            }
            .help("Toggle Ghost Writer AI Panel (⌥Space / ⌘J)")
            
            // Settings
            Button {
                showSettingsSheet = true
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .help("AI Providers & Settings (⌘,)")
        }
    }
}
