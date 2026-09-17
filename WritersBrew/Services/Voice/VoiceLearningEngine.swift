import Foundation

@Observable
public final class VoiceLearningEngine {
    public static let shared = VoiceLearningEngine()
    
    public var currentVoiceSkill: VoiceSkill {
        didSet { saveVoiceSkill() }
    }
    
    private let defaults: UserDefaults
    private let storageKey: String
    
    private convenience init() {
        self.init(defaults: .standard)
    }

    init(defaults: UserDefaults, storageKey: String = "WritersBrew_VoiceSkill") {
        self.defaults = defaults
        self.storageKey = storageKey

        if let data = defaults.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(VoiceSkill.self, from: data) {
            self.currentVoiceSkill = saved
        } else {
            self.currentVoiceSkill = VoiceSkill()
        }
    }
    
    public func recordAcceptedSuggestion(text: String) {
        currentVoiceSkill.acceptedSuggestionsCount += 1
        currentVoiceSkill.totalWordsAnalyzed += text.split { $0.isWhitespace }.count
        currentVoiceSkill.lastUpdated = Date()
        
        // Extract rich vocabulary from accepted text
        let words = text.split { $0.isWhitespace || $0.isPunctuation }
        for word in words {
            let lower = word.lowercased()
            if lower.count > 6 && !currentVoiceSkill.distinctiveVocabulary.contains(lower) {
                currentVoiceSkill.distinctiveVocabulary.insert(lower, at: 0)
                if currentVoiceSkill.distinctiveVocabulary.count > 15 {
                    currentVoiceSkill.distinctiveVocabulary.removeLast()
                }
            }
        }
        
        saveVoiceSkill()
    }
    
    public func recordRejectedSuggestion(text: String, reason: String? = nil) {
        currentVoiceSkill.rejectedSuggestionsCount += 1
        currentVoiceSkill.lastUpdated = Date()
        
        // If a cliché was detected in rejected prose, add it to avoided clichés
        if let reason = reason, !currentVoiceSkill.avoidedClichés.contains(reason) {
            currentVoiceSkill.avoidedClichés.append(reason)
        }
        
        saveVoiceSkill()
    }
    
    public func resetToDefaults() {
        self.currentVoiceSkill = VoiceSkill()
        saveVoiceSkill()
    }
    
    private func saveVoiceSkill() {
        if let data = try? JSONEncoder().encode(currentVoiceSkill) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
