import SwiftUI

@Observable
public final class PreferencesStore {
    public static let shared = PreferencesStore(
        defaults: .standard,
        credentialStore: KeychainCredentialStore.shared
    )

    private let defaults: UserDefaults
    private let credentialStore: any CredentialStore

    /// A non-secret, user-displayable error from the most recent credential operation.
    public var credentialError: String?
    
    // AI Providers
    public var activeProvider: LLMProviderType {
        didSet { defaults.set(activeProvider.rawValue, forKey: "activeProvider") }
    }
    
    public var openAIKey: String {
        didSet { persistCredential(openAIKey, for: .openAI) }
    }
    
    public var anthropicKey: String {
        didSet { persistCredential(anthropicKey, for: .anthropic) }
    }
    
    public var geminiKey: String {
        didSet { persistCredential(geminiKey, for: .gemini) }
    }
    
    public var grokKey: String {
        didSet { persistCredential(grokKey, for: .xAI) }
    }
    
    public var ollamaURL: String {
        didSet { defaults.set(ollamaURL, forKey: "ollamaURL") }
    }
    
    // Visual & Mood
    public var currentMood: ThemeMood {
        didSet { defaults.set(currentMood.rawValue, forKey: "currentMood") }
    }
    
    // Editor ergonomics
    public var isTypewriterScrollingEnabled: Bool {
        didSet { defaults.set(isTypewriterScrollingEnabled, forKey: "isTypewriterScrollingEnabled") }
    }
    
    public var isTypewriterSoundEnabled: Bool {
        didSet { defaults.set(isTypewriterSoundEnabled, forKey: "isTypewriterSoundEnabled") }
    }
    
    public var isProactiveSuggestionsEnabled: Bool {
        didSet { defaults.set(isProactiveSuggestionsEnabled, forKey: "isProactiveSuggestionsEnabled") }
    }
    
    public var isRealtimeAnalyzerEnabled: Bool {
        didSet { defaults.set(isRealtimeAnalyzerEnabled, forKey: "isRealtimeAnalyzerEnabled") }
    }
    
    public var editorMeasureWidth: CGFloat {
        didSet { defaults.set(Double(editorMeasureWidth), forKey: "editorMeasureWidth") }
    }
    
    public var editorFontSize: CGFloat {
        didSet { defaults.set(Double(editorFontSize), forKey: "editorFontSize") }
    }
    
    public var editorFontDesign: String { // "serif", "system", "mono"
        didSet { defaults.set(editorFontDesign, forKey: "editorFontDesign") }
    }
    
    init(defaults: UserDefaults, credentialStore: any CredentialStore) {
        self.defaults = defaults
        self.credentialStore = credentialStore
        self.credentialError = nil

        let savedProvider = defaults.string(forKey: "activeProvider") ?? LLMProviderType.offlineCreative.rawValue
        let resolvedProvider = LLMProviderType.fromPersistedValue(savedProvider) ?? .offlineCreative
        self.activeProvider = resolvedProvider
        defaults.set(resolvedProvider.rawValue, forKey: "activeProvider")

        var migrationErrors: [String] = []
        self.openAIKey = Self.loadAndMigrateCredential(
            .openAI,
            defaults: defaults,
            credentialStore: credentialStore,
            errors: &migrationErrors
        )
        self.anthropicKey = Self.loadAndMigrateCredential(
            .anthropic,
            defaults: defaults,
            credentialStore: credentialStore,
            errors: &migrationErrors
        )
        self.geminiKey = Self.loadAndMigrateCredential(
            .gemini,
            defaults: defaults,
            credentialStore: credentialStore,
            errors: &migrationErrors
        )
        self.grokKey = Self.loadAndMigrateCredential(
            .xAI,
            defaults: defaults,
            credentialStore: credentialStore,
            errors: &migrationErrors
        )
        self.ollamaURL = defaults.string(forKey: "ollamaURL") ?? "http://localhost:11434"
        
        let savedMood = defaults.string(forKey: "currentMood") ?? ThemeMood.system.rawValue
        self.currentMood = ThemeMood(rawValue: savedMood) ?? .system
        
        self.isTypewriterScrollingEnabled = defaults.object(forKey: "isTypewriterScrollingEnabled") as? Bool ?? false
        self.isTypewriterSoundEnabled = defaults.object(forKey: "isTypewriterSoundEnabled") as? Bool ?? false
        self.isProactiveSuggestionsEnabled = defaults.object(forKey: "isProactiveSuggestionsEnabled") as? Bool ?? true
        self.isRealtimeAnalyzerEnabled = defaults.object(forKey: "isRealtimeAnalyzerEnabled") as? Bool ?? true
        
        let measure = defaults.double(forKey: "editorMeasureWidth")
        self.editorMeasureWidth = measure > 300 ? CGFloat(measure) : 740.0
        
        let fontSize = defaults.double(forKey: "editorFontSize")
        self.editorFontSize = fontSize > 10 ? CGFloat(fontSize) : 18.0
        
        self.editorFontDesign = defaults.string(forKey: "editorFontDesign") ?? "serif"

        if !migrationErrors.isEmpty {
            self.credentialError = migrationErrors.joined(separator: " ")
        }
    }

    private func persistCredential(_ value: String, for provider: ProviderCredential) {
        do {
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try credentialStore.removeCredential(for: provider)
            } else {
                try credentialStore.setCredential(value, for: provider)
            }
            credentialError = nil
        } catch {
            credentialError = "Could not update the \(provider.rawValue) credential: \(error.localizedDescription)"
        }
    }

    private static func loadAndMigrateCredential(
        _ provider: ProviderCredential,
        defaults: UserDefaults,
        credentialStore: any CredentialStore,
        errors: inout [String]
    ) -> String {
        let legacyValue = defaults.string(forKey: provider.legacyUserDefaultsKey) ?? ""

        do {
            if let keychainValue = try credentialStore.credential(for: provider),
               !keychainValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if defaults.object(forKey: provider.legacyUserDefaultsKey) != nil {
                    defaults.removeObject(forKey: provider.legacyUserDefaultsKey)
                }
                return keychainValue
            }

            guard !legacyValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                if defaults.object(forKey: provider.legacyUserDefaultsKey) != nil {
                    defaults.removeObject(forKey: provider.legacyUserDefaultsKey)
                }
                return ""
            }

            try credentialStore.setCredential(legacyValue, for: provider)
            defaults.removeObject(forKey: provider.legacyUserDefaultsKey)
            return legacyValue
        } catch {
            errors.append("The \(provider.rawValue) credential could not be migrated to Keychain; the legacy value was retained.")
            return legacyValue
        }
    }
}
