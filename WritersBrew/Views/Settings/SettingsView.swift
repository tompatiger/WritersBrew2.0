import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var prefs = PreferencesStore.shared
    
    public var body: some View {
        TabView {
            // AI Providers Tab
            aiProvidersTab
                .tabItem {
                    Label("Ghost Writer AI", systemImage: "sparkles")
                }
            
            // Typography & Editor Tab
            typographyTab
                .tabItem {
                    Label("Editor & Canvas", systemImage: "textformat")
                }
            
            // About Tab
            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 520, height: 440)
        .padding(16)
    }
    
    // MARK: - Tabs
    
    private var aiProvidersTab: some View {
        Form {
            Section {
                Picker("Active AI Provider", selection: $prefs.activeProvider) {
                    ForEach(LLMProviderType.allCases) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                
                Text(prefs.activeProvider.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            } header: {
                Text("Creative Partner Model")
            }

            Section {
                let capability = LLMProviderFactory.capability(
                    for: prefs.activeProvider,
                    preferences: prefs
                )

                LabeledContent("Provider", value: capability.providerName)
                LabeledContent("Model", value: capability.model)
                LabeledContent("Processing", value: capability.executionLocation.rawValue)
                LabeledContent("Streaming", value: capability.supportsStreaming ? "Supported" : "Not implemented")

                Label(
                    capability.statusMessage,
                    systemImage: capability.isAvailable && capability.isConfigured
                        ? "checkmark.circle.fill"
                        : "exclamationmark.triangle.fill"
                )
                .font(.system(size: 11))
                .foregroundStyle(capability.isAvailable && capability.isConfigured ? .green : .orange)
            } header: {
                Text("Capability Status")
            }
            
            Section {
                switch prefs.activeProvider {
                case .offlineCreative:
                    Label("No API key or network access. Uses bundled heuristics and templates, not a local language model.", systemImage: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 12))
                case .openAI:
                    SecureField("OpenAI API Key (sk-...)", text: $prefs.openAIKey)
                case .anthropic:
                    SecureField("Anthropic API Key (sk-ant-...)", text: $prefs.anthropicKey)
                case .gemini:
                    SecureField("Google Gemini API Key", text: $prefs.geminiKey)
                case .grok:
                    SecureField("xAI Grok API Key", text: $prefs.grokKey)
                    Text("Stored securely for future support. xAI requests are disabled in this build because the transport is unfinished.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                case .ollama:
                    TextField("Ollama Host URL", text: $prefs.ollamaURL)
                }

                if let credentialError = prefs.credentialError {
                    Label(credentialError, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                } else if [.openAI, .anthropic, .gemini, .grok].contains(prefs.activeProvider) {
                    Label("API credentials are stored in macOS Keychain.", systemImage: "key.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Provider Credentials")
            }
            
            Section {
                Toggle("Enable Proactive Inline Suggestion Bubbles", isOn: $prefs.isProactiveSuggestionsEnabled)
                Toggle("Enable Real-Time Prose Analyzer", isOn: $prefs.isRealtimeAnalyzerEnabled)
            } header: {
                Text("Intelligence Features")
            }
        }
        .formStyle(.grouped)
    }
    
    private var typographyTab: some View {
        Form {
            Section {
                Slider(value: $prefs.editorMeasureWidth, in: 500...1000, step: 20) {
                    Text("Measure (Column Width): \(Int(prefs.editorMeasureWidth)) pt")
                }
                
                Slider(value: $prefs.editorFontSize, in: 14...28, step: 1) {
                    Text("Font Size: \(Int(prefs.editorFontSize)) pt")
                }
                
                Picker("Typeface Design", selection: $prefs.editorFontDesign) {
                    Text("New York (Serif)").tag("serif")
                    Text("San Francisco (Default)").tag("system")
                    Text("SF Mono (Monospaced)").tag("mono")
                }
            } header: {
                Text("Typography & Canvas")
            }
            
            Section {
                Toggle("Subtle Typewriter Acoustic Sound", isOn: $prefs.isTypewriterSoundEnabled)
                Toggle("Typewriter Scrolling (Center Cursor)", isOn: $prefs.isTypewriterScrollingEnabled)
            } header: {
                Text("Haptics & Audio")
            }
        }
        .formStyle(.grouped)
    }
    
    private var aboutTab: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)
            
            Text("WritersBrew 2.0")
                .font(.system(size: 18, weight: .bold))
            
            Text("The calm, intelligent writing environment for the Mac.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            
            Text("Version 2.0 (Tahoe Edition) · Swift 6 · Liquid Glass")
                .font(.system(size: 11))
                .foregroundStyle(.secondary.opacity(0.7))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
