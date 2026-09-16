import Foundation
import SwiftUI

public struct ChatMessage: Identifiable, Codable, Equatable {
    public var id: UUID
    public var role: MessageRole
    public var content: String
    public var timestamp: Date
    
    public init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

public enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

@Observable
public final class AIService {
    public static let shared = AIService()
    
    public var isGenerating: Bool = false
    public var lastError: String? = nil
    
    private init() {}
    
    private func getProvider() -> LLMProvider {
        let prefs = PreferencesStore.shared
        switch prefs.activeProvider {
        case .offlineCreative:
            return OfflineCreativeEngine()
        case .openAI:
            if !prefs.openAIKey.isEmpty {
                return OpenAIProvider(apiKey: prefs.openAIKey)
            }
            return OfflineCreativeEngine()
        case .anthropic:
            if !prefs.anthropicKey.isEmpty {
                return AnthropicProvider(apiKey: prefs.anthropicKey)
            }
            return OfflineCreativeEngine()
        case .gemini:
            if !prefs.geminiKey.isEmpty {
                return GeminiProvider(apiKey: prefs.geminiKey)
            }
            return OfflineCreativeEngine()
        case .grok:
            if !prefs.grokKey.isEmpty {
                return OpenAIProvider(apiKey: prefs.grokKey, model: "grok-beta")
            }
            return OfflineCreativeEngine()
        case .ollama:
            return LocalOllamaProvider(hostURL: prefs.ollamaURL)
        }
    }
    
    // MARK: - Context Assembly
    
    public func buildSystemPrompt(
        style: StyleProfile,
        voice: VoiceSkill?,
        storyboardCharacters: [BrewCharacter] = [],
        storyboardLocations: [BrewLocation] = []
    ) -> String {
        var sections: [String] = []
        
        sections.append("""
        You are Ghost Writer, a quiet, elite creative partner built exclusively for serious writers.
        Your goal is to elevate the craft of writing without ever sounding like generic AI prose.
        """)
        
        // Active Style Profile
        sections.append("ACTIVE STYLE PROFILE: \(style.name)\n\(style.systemPromptModifier)")
        
        // Voice Skill
        if let voice = voice {
            sections.append(voice.promptDirective())
        }
        
        // Storyboard Context (if relevant)
        if !storyboardCharacters.isEmpty {
            let charSummaries = storyboardCharacters.prefix(4).map {
                "- \($0.name) (\($0.role.rawValue)): \($0.appearance). Goal: \($0.externalGoal). Voice: \($0.voiceNotes)"
            }.joined(separator: "\n")
            sections.append("STORYBOARD CHARACTERS (Reference for scene consistency):\n\(charSummaries)")
        }
        
        if !storyboardLocations.isEmpty {
            let locSummaries = storyboardLocations.prefix(3).map {
                "- \($0.name) (\($0.category)): \($0.atmosphere). Sensory: \($0.sensoryDetails)"
            }.joined(separator: "\n")
            sections.append("STORYBOARD WORLD & LOCATIONS:\n\(locSummaries)")
        }
        
        return sections.joined(separator: "\n\n")
    }
    
    // MARK: - Creative Block Breaker
    
    public func breakWritersBlock(
        documentContext: String,
        style: StyleProfile,
        voice: VoiceSkill?,
        characters: [BrewCharacter] = []
    ) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }
        
        let systemPrompt = buildSystemPrompt(style: style, voice: voice, storyboardCharacters: characters)
        let prompt = """
        The author is currently stuck on this scene:
        \"\"\"
        \(documentContext.suffix(1500))
        \"\"\"
        
        Generate three distinct, compelling, and surprising ways to break writer's block right here:
        1. The Subversion (an unexpected reaction or sudden secret revealed)
        2. The Sensory Shift (ground the tension in an external physical action or environmental pivot)
        3. The Escalation (raise the stakes or force an unavoidable dilemma)
        
        Keep explanations brief, actionable, and evocative.
        """
        
        do {
            let result = try await getProvider().generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
            return result
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Rewriting
    
    public func rewrite(
        selection: String,
        instruction: String,
        style: StyleProfile,
        voice: VoiceSkill?
    ) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }
        
        let systemPrompt = buildSystemPrompt(style: style, voice: voice)
        let prompt = """
        Rewrite the following passage according to this instruction: "\(instruction)".
        Preserve the author's voice and intent. Do NOT add meta commentary or introductory chatter.
        Return ONLY the rewritten prose.
        
        Original Text:
        \"\"\"
        \(selection)
        \"\"\"
        """
        
        do {
            let result = try await getProvider().generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
            return result
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sensory Expansion
    
    public func expandSensory(
        sceneText: String,
        style: StyleProfile,
        voice: VoiceSkill?,
        locations: [BrewLocation] = []
    ) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }
        
        let systemPrompt = buildSystemPrompt(style: style, voice: voice, storyboardLocations: locations)
        let prompt = """
        Expand this moment with vivid, visceral sensory details (sound, tactile texture, lighting, temperature).
        Avoid empty purple prose. Make the physical details mirror the scene's emotional weight.
        Return ONLY the continuation or expansion paragraph.
        
        Scene:
        \"\"\"
        \(sceneText.suffix(1000))
        \"\"\"
        """
        
        do {
            return try await getProvider().generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Inline Continuation
    
    public func continueFromCursor(
        precedingText: String,
        style: StyleProfile,
        voice: VoiceSkill?
    ) async throws -> String {
        isGenerating = true
        defer { isGenerating = false }
        
        let systemPrompt = buildSystemPrompt(style: style, voice: voice)
        let prompt = """
        Seamlessly continue the prose immediately from where the text ends.
        Write 2 to 4 sentences that match the tone, rhythm, and forward momentum.
        Output ONLY the continuation text with no conversational preamble.
        
        Current Text:
        \"\"\"
        \(precedingText.suffix(800))
        \"\"\"
        """
        
        do {
            return try await getProvider().generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Proactive Suggestion Bubble
    
    public func fetchProactiveSuggestion(
        precedingText: String,
        style: StyleProfile
    ) async -> String? {
        guard PreferencesStore.shared.isProactiveSuggestionsEnabled else { return nil }
        let trimmed = precedingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 40 else { return nil }
        
        do {
            let suggestion = try await getProvider().generateCompletion(
                prompt: "Offer a single crisp sentence continuation or clause for: \"\(trimmed.suffix(200))\". Return only the continuation sentence.",
                systemPrompt: "You are an unobtrusive proactive writing partner. Provide one brief, elegant sentence."
            )
            return suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
    
    // MARK: - Conversational Stream
    
    public func streamChat(
        messages: [ChatMessage],
        documentContext: String,
        style: StyleProfile,
        voice: VoiceSkill?,
        characters: [BrewCharacter],
        locations: [BrewLocation]
    ) -> AsyncThrowingStream<String, Error> {
        let systemPrompt = buildSystemPrompt(
            style: style,
            voice: voice,
            storyboardCharacters: characters,
            storyboardLocations: locations
        ) + "\n\nCURRENT DOCUMENT EXCERPT:\n\"\"\"\n\(documentContext.suffix(2000))\n\"\"\""
        
        let lastUserMessage = messages.last(where: { $0.role == .user })?.content ?? "Help me brainstorm this scene."
        return getProvider().streamCompletion(prompt: lastUserMessage, systemPrompt: systemPrompt)
    }
}
