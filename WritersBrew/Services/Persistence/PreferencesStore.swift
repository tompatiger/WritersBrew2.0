import SwiftUI

@Observable
public final class PreferencesStore {
    public static let shared = PreferencesStore()
    
    // AI Providers
    public var activeProvider: LLMProviderType {
        didSet { UserDefaults.standard.set(activeProvider.rawValue, forKey: "activeProvider") }
    }
    
    public var openAIKey: String {
        didSet { UserDefaults.standard.set(openAIKey, forKey: "openAIKey") }
    }
    
    public var anthropicKey: String {
        didSet { UserDefaults.standard.set(anthropicKey, forKey: "anthropicKey") }
    }
    
    public var geminiKey: String {
        didSet { UserDefaults.standard.set(geminiKey, forKey: "geminiKey") }
    }
    
    public var grokKey: String {
        didSet { UserDefaults.standard.set(grokKey, forKey: "grokKey") }
    }
    
    public var ollamaURL: String {
        didSet { UserDefaults.standard.set(ollamaURL, forKey: "ollamaURL") }
    }
    
    // Visual & Mood
    public var currentMood: ThemeMood {
        didSet { UserDefaults.standard.set(currentMood.rawValue, forKey: "currentMood") }
    }
    
    // Editor ergonomics
    public var isTypewriterScrollingEnabled: Bool {
        didSet { UserDefaults.standard.set(isTypewriterScrollingEnabled, forKey: "isTypewriterScrollingEnabled") }
    }
    
    public var isTypewriterSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isTypewriterSoundEnabled, forKey: "isTypewriterSoundEnabled") }
    }
    
    public var isProactiveSuggestionsEnabled: Bool {
        didSet { UserDefaults.standard.set(isProactiveSuggestionsEnabled, forKey: "isProactiveSuggestionsEnabled") }
    }
    
    public var isRealtimeAnalyzerEnabled: Bool {
        didSet { UserDefaults.standard.set(isRealtimeAnalyzerEnabled, forKey: "isRealtimeAnalyzerEnabled") }
    }
    
    public var editorMeasureWidth: CGFloat {
        didSet { UserDefaults.standard.set(Double(editorMeasureWidth), forKey: "editorMeasureWidth") }
    }
    
    public var editorFontSize: CGFloat {
        didSet { UserDefaults.standard.set(Double(editorFontSize), forKey: "editorFontSize") }
    }
    
    public var editorFontDesign: String { // "serif", "system", "mono"
        didSet { UserDefaults.standard.set(editorFontDesign, forKey: "editorFontDesign") }
    }
    
    private init() {
        let defaults = UserDefaults.standard
        let savedProvider = defaults.string(forKey: "activeProvider") ?? LLMProviderType.offlineCreative.rawValue
        self.activeProvider = LLMProviderType(rawValue: savedProvider) ?? .offlineCreative
        
        self.openAIKey = defaults.string(forKey: "openAIKey") ?? ""
        self.anthropicKey = defaults.string(forKey: "anthropicKey") ?? ""
        self.geminiKey = defaults.string(forKey: "geminiKey") ?? ""
        self.grokKey = defaults.string(forKey: "grokKey") ?? ""
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
    }
}
