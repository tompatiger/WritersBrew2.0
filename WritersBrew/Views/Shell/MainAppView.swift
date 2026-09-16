import SwiftUI
import UniformTypeIdentifiers

public struct MainAppView: View {
    @State private var store = DocumentStore.shared
    @State private var sidebarTab: DocumentLibrarySidebar.MainSidebarTab = .library
    
    // UI state
    @State private var isFocusModeActive: Bool = false
    @State private var showGhostWriter: Bool = false
    @State private var showAnalyzer: Bool = false
    @State private var showVoiceSkillSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            if !isFocusModeActive {
                DocumentLibrarySidebar(selectedTab: $sidebarTab)
                    .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            }
        } detail: {
            HStack(spacing: 0) {
                // Main Working Surface
                if sidebarTab == .storyboard {
                    StoryboardMainView()
                } else if let docBinding = currentDocumentBinding {
                    FocusEditorView(
                        document: docBinding,
                        isFocusModeActive: $isFocusModeActive,
                        showGhostWriterSidebar: $showGhostWriter,
                        showAnalyzerInspector: $showAnalyzer
                    )
                } else {
                    noDocumentView
                }
                
                // Ghost Writer Collapsible Sidebar
                if showGhostWriter && !isFocusModeActive {
                    Divider().opacity(0.3)
                    
                    if let docBinding = currentDocumentBinding {
                        GhostWriterSidebar(
                            document: docBinding,
                            activeStyle: StyleProfile.defaultProfiles.first(where: { $0.id == docBinding.wrappedValue.styleProfileId }) ?? .narrativeFiction,
                            characters: store.characters,
                            locations: store.locations
                        )
                        .transition(.move(edge: .trailing))
                    }
                }
                
                // Analyzer Inspector
                if showAnalyzer && !isFocusModeActive {
                    Divider().opacity(0.3)
                    
                    if let doc = store.currentDocument {
                        let style = StyleProfile.defaultProfiles.first(where: { $0.id == doc.styleProfileId }) ?? .narrativeFiction
                        let report = ProseAnalyzer.shared.analyze(text: doc.content, style: style)
                        AnalyzerInspectorView(report: report, style: style)
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showGhostWriter)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showAnalyzer)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFocusModeActive)
        }
        .toolbar {
            AppToolbar(
                isFocusModeActive: $isFocusModeActive,
                showGhostWriter: $showGhostWriter,
                showAnalyzer: $showAnalyzer,
                showVoiceSkillSheet: $showVoiceSkillSheet,
                showSettingsSheet: $showSettingsSheet,
                onNewChapter: {
                    _ = store.createChapter()
                    sidebarTab = .library
                },
                onNewDocument: {
                    _ = store.createDocument()
                    sidebarTab = .library
                },
                onExportDocument: { format in
                    exportCurrentDocument(format: format)
                }
            )
        }
        .preferredColorScheme(PreferencesStore.shared.currentMood.forcedColorScheme)
        .tint(PreferencesStore.shared.currentMood.accentColor)
        .sheet(isPresented: $showVoiceSkillSheet) {
            VoiceSkillView()
                .preferredColorScheme(PreferencesStore.shared.currentMood.forcedColorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
                .preferredColorScheme(PreferencesStore.shared.currentMood.forcedColorScheme)
        }
        .onChange(of: isFocusModeActive) { _, active in
            withAnimation {
                columnVisibility = active ? .detailOnly : .all
            }
        }
    }
    
    // MARK: - Bindings & Subviews
    
    private var currentDocumentBinding: Binding<BrewDocument>? {
        guard let id = store.selectedDocumentId,
              let index = store.documents.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $store.documents[index]
    }
    
    private var noDocumentView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentColor.opacity(0.5))
            
            Text("No Manuscript Selected")
                .font(.system(size: 16, weight: .semibold))
            
            Button("Create New Manuscript") {
                _ = store.createDocument()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    // MARK: - Export Logic
    
    private func exportCurrentDocument(format: AppToolbar.ExportFormat) {
        guard let doc = store.currentDocument else { return }
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        
        let fileExtension: String
        let fileContent: String
        
        switch format {
        case .markdown:
            fileExtension = "md"
            fileContent = "# \(doc.title)\n\n\(doc.content)"
        case .plainText:
            fileExtension = "txt"
            fileContent = "\(doc.title)\n\n\(doc.content)"
        case .html:
            fileExtension = "html"
            fileContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>\(doc.title)</title>
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, "New York", serif; max-width: 720px; margin: 60px auto; line-height: 1.7; font-size: 18px; color: #1a1a1a; }
                    h1 { font-family: -apple-system, sans-serif; font-size: 32px; margin-bottom: 24px; }
                    p { margin-bottom: 20px; }
                </style>
            </head>
            <body>
                <h1>\(doc.title)</h1>
                \(doc.content.components(separatedBy: "\n\n").map { "<p>\($0)</p>" }.joined(separator: "\n"))
            </body>
            </html>
            """
        }
        
        savePanel.nameFieldStringValue = "\(doc.title).\(fileExtension)"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? fileContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
