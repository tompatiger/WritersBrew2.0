import Foundation

/// A living model of the writer's individual style, rhythm, vocabulary, and preferences.
/// Built continuously as the writer accepts, rejects, or edits AI suggestions.
public struct VoiceSkill: Codable, Equatable {
    public var id: UUID
    public var name: String
    
    // Sliders (0.0 to 1.0)
    public var vocabularySophistication: Double // 0 = plain/simple, 1 = erudite/poetic
    public var sentenceRhythmPacing: Double     // 0 = staccato/short, 1 = sprawling/flowing
    public var emotionalWarmth: Double          // 0 = detached/stoic, 1 = warm/resonant
    public var sensoryDensity: Double           // 0 = conceptual/abstract, 1 = visceral/tactile
    public var dialogueNaturalness: Double      // 0 = stylized/heightened, 1 = grounded/colloquial
    
    // Learned patterns
    public var preferredCadences: [String]      // e.g., "Triad sentences", "Hypothetical opening questions"
    public var distinctiveVocabulary: [String]  // Words the author loves using
    public var avoidedClichés: [String]         // Words or constructions the author repeatedly strikes
    public var customDirectives: String         // Author's personal notes to the model
    
    // Metrics
    public var acceptedSuggestionsCount: Int
    public var rejectedSuggestionsCount: Int
    public var totalWordsAnalyzed: Int
    public var lastUpdated: Date
    
    public init(
        id: UUID = UUID(),
        name: String = "Author Voice Skill",
        vocabularySophistication: Double = 0.65,
        sentenceRhythmPacing: Double = 0.50,
        emotionalWarmth: Double = 0.55,
        sensoryDensity: Double = 0.60,
        dialogueNaturalness: Double = 0.70,
        preferredCadences: [String] = ["Varied sentence lengths", "Rhythmic punchy clauses"],
        distinctiveVocabulary: [String] = ["luminous", "threshold", "stillness", "resonance", "flicker"],
        avoidedClichés: [String] = ["suddenly", "little did they know", "shivers down spine", "a testament to"],
        customDirectives: String = "Prefer concrete imagery over abstract exposition. Never use generic corporate adjectives.",
        acceptedSuggestionsCount: Int = 12,
        rejectedSuggestionsCount: Int = 3,
        totalWordsAnalyzed: Int = 4500,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.vocabularySophistication = vocabularySophistication
        self.sentenceRhythmPacing = sentenceRhythmPacing
        self.emotionalWarmth = emotionalWarmth
        self.sensoryDensity = sensoryDensity
        self.dialogueNaturalness = dialogueNaturalness
        self.preferredCadences = preferredCadences
        self.distinctiveVocabulary = distinctiveVocabulary
        self.avoidedClichés = avoidedClichés
        self.customDirectives = customDirectives
        self.acceptedSuggestionsCount = acceptedSuggestionsCount
        self.rejectedSuggestionsCount = rejectedSuggestionsCount
        self.totalWordsAnalyzed = totalWordsAnalyzed
        self.lastUpdated = lastUpdated
    }
    
    public var acceptanceRate: Double {
        let total = acceptedSuggestionsCount + rejectedSuggestionsCount
        guard total > 0 else { return 1.0 }
        return Double(acceptedSuggestionsCount) / Double(total)
    }
    
    /// Generates a synthesized system prompt instruction embodying this exact Voice Skill
    public func promptDirective() -> String {
        var parts: [String] = []
        
        parts.append("Author Voice Model:")
        if vocabularySophistication > 0.7 {
            parts.append("- Vocabulary: Sophisticated, literary, and evocative without sounding pretentious.")
        } else if vocabularySophistication < 0.3 {
            parts.append("- Vocabulary: Direct, crisp, grounded, plainspoken words.")
        } else {
            parts.append("- Vocabulary: Natural, precise, and expressive.")
        }
        
        if sentenceRhythmPacing > 0.7 {
            parts.append("- Rhythm: Flowing, compound sentences with rhythmic cadence.")
        } else if sentenceRhythmPacing < 0.3 {
            parts.append("- Rhythm: Short, staccato, muscular sentences with immediate punch.")
        } else {
            parts.append("- Rhythm: Dynamic mixture of short and longer sentences.")
        }
        
        if sensoryDensity > 0.6 {
            parts.append("- Sensory anchor: Rich tactile, auditory, and lighting details.")
        }
        
        if !distinctiveVocabulary.isEmpty {
            parts.append("- Natural vocabulary leanings: \(distinctiveVocabulary.prefix(8).joined(separator: ", ")).")
        }
        
        if !avoidedClichés.isEmpty {
            parts.append("- STRICTLY AVOID these clichés: \(avoidedClichés.joined(separator: ", ")).")
        }
        
        if !customDirectives.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("- Direct author instructions: \(customDirectives)")
        }
        
        return parts.joined(separator: "\n")
    }
}
