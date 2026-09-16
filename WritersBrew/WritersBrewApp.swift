import SwiftUI

@main
struct WritersBrewApp: App {
    @State private var documentStore = DocumentStore.shared
    @State private var preferences = PreferencesStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .frame(minWidth: 900, minHeight: 600)
                .tint(preferences.currentMood.accentColor)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // App native keyboard commands
            CommandGroup(replacing: .newItem) {
                Button("New Chapter") {
                    _ = documentStore.createChapter()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Standalone Manuscript") {
                    _ = documentStore.createDocument()
                }
                .keyboardShortcut("n", modifiers: [.command, .option])
                
                Button("Save Version Snapshot") {
                    documentStore.saveCurrentSnapshot(summary: "Manual Snapshot")
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandMenu("Ghost Writer") {
                Button("Continue from Cursor") {
                    if let doc = documentStore.currentDocument {
                        Task {
                            let style = StyleProfile.defaultProfiles.first(where: { $0.id == doc.styleProfileId }) ?? .narrativeFiction
                            if let prose = try? await AIService.shared.continueFromCursor(
                                precedingText: doc.content,
                                style: style,
                                voice: VoiceLearningEngine.shared.currentVoiceSkill
                            ) {
                                await MainActor.run {
                                    var updated = doc
                                    if !updated.content.isEmpty && !updated.content.hasSuffix(" ") {
                                        updated.content += " "
                                    }
                                    updated.content += prose
                                    documentStore.currentDocument = updated
                                }
                            }
                        }
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
            }
            
            CommandMenu("Craft & Voice") {
                Button("Voice Skill Inspector") {
                    // Triggered via toolbar or shortcuts
                }
                .keyboardShortcut("v", modifiers: [.command, .shift])
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
