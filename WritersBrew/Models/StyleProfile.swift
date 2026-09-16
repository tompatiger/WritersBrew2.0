import Foundation

/// Style Profiles influence both the visual presentation and the Ghost Writer's generation personality.
public struct StyleProfile: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var summary: String
    public var icon: String
    public var systemPromptModifier: String
    public var targetSentenceLength: Int // words per sentence
    public var vocabularyLevel: String // "Accessible", "Elevated", "Literary", "Specialized"
    public var isBuiltin: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        summary: String,
        icon: String = "text.quote",
        systemPromptModifier: String,
        targetSentenceLength: Int = 16,
        vocabularyLevel: String = "Literary",
        isBuiltin: Bool = false
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.icon = icon
        self.systemPromptModifier = systemPromptModifier
        self.targetSentenceLength = targetSentenceLength
        self.vocabularyLevel = vocabularyLevel
        self.isBuiltin = isBuiltin
    }
}

extension StyleProfile {
    public static let concise = StyleProfile(
        id: "concise",
        name: "Concise",
        summary: "Lean, punchy, maximum clarity with minimal fluff or filler.",
        icon: "scissors",
        systemPromptModifier: "Adopt a lean, muscular, concise writing style. Strip filler adverbs, eliminate passive constructions, and state thoughts with direct clarity and crisp pacing.",
        targetSentenceLength: 12,
        vocabularyLevel: "Accessible",
        isBuiltin: true
    )
    
    public static let descriptive = StyleProfile(
        id: "descriptive",
        name: "Descriptive",
        summary: "Rich sensory details, evocative imagery, and lyrical prose.",
        icon: "paintbrush.fill",
        systemPromptModifier: "Write with rich atmospheric immersion. Evoke sensory textures (sound, light, scent, tactile weight), develop metaphor with restraint, and weave immersive cadence.",
        targetSentenceLength: 22,
        vocabularyLevel: "Literary",
        isBuiltin: true
    )
    
    public static let formal = StyleProfile(
        id: "formal",
        name: "Formal",
        summary: "Authoritative, dignified, precise syntax and measured cadence.",
        icon: "building.columns.fill",
        systemPromptModifier: "Maintain an authoritative, scholarly, dignified tone. Use precise syntax, measured cadence, and balanced rhetorical structure.",
        targetSentenceLength: 20,
        vocabularyLevel: "Elevated",
        isBuiltin: true
    )
    
    public static let conversational = StyleProfile(
        id: "conversational",
        name: "Conversational",
        summary: "Intimate, warm, direct reader address with effortless flow.",
        icon: "bubble.left.and.bubble.right.fill",
        systemPromptModifier: "Speak directly to the reader like a brilliant friend at a quiet coffee table. Keep it warm, witty, rhythmically fluid, and grounded in authentic human speech.",
        targetSentenceLength: 15,
        vocabularyLevel: "Accessible",
        isBuiltin: true
    )
    
    public static let academic = StyleProfile(
        id: "academic",
        name: "Academic",
        summary: "Objective, rigorously structured, analytical, and thesis-driven.",
        icon: "graduationcap.fill",
        systemPromptModifier: "Produce rigorous analytical prose. Define terms clearly, balance evidence and counter-arguments, and maintain detached objective precision.",
        targetSentenceLength: 24,
        vocabularyLevel: "Specialized",
        isBuiltin: true
    )
    
    public static let narrativeFiction = StyleProfile(
        id: "narrative",
        name: "Narrative Fiction",
        summary: "Cinematic, deep character POV, show-don't-tell pacing.",
        icon: "book.pages.fill",
        systemPromptModifier: "Write narrative fiction with deep close-third or first-person POV. Ground reactions in physical subtext, avoid melodrama, show rather than explain, and maintain magnetic narrative tension.",
        targetSentenceLength: 17,
        vocabularyLevel: "Literary",
        isBuiltin: true
    )
    
    public static let defaultProfiles: [StyleProfile] = [
        .narrativeFiction,
        .concise,
        .descriptive,
        .conversational,
        .formal,
        .academic
    ]
}
