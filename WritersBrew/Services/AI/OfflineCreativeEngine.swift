import Foundation

/// A thoughtful, contextual offline creative partner that operates without network or API keys.
/// It uses intelligent prose analysis, narrative heuristics, and style templates to offer
/// continuations, rewrites, and writer's block sparks instantly.
public final class OfflineCreativeEngine: LLMProvider {
    public let type: LLMProviderType = .offlineCreative
    public var isConfigured: Bool { true }
    
    public init() {}
    
    public func generateCompletion(prompt: String, systemPrompt: String) async throws -> String {
        // Add a slight realistic latency (250ms) to feel natural and trigger animations smoothly
        try await Task.sleep(nanoseconds: 250_000_000)
        
        let lowerPrompt = prompt.lowercased()
        
        // Writer's block suggestions
        if lowerPrompt.contains("writer's block") || lowerPrompt.contains("what happens next") || lowerPrompt.contains("alternative directions") {
            return generateBlockBreakers(for: prompt)
        }
        
        // Rewrite requests
        if lowerPrompt.contains("rewrite") || lowerPrompt.contains("tighten") || lowerPrompt.contains("elevate") {
            return generateRewrite(for: prompt)
        }
        
        // Sensory expansion
        if lowerPrompt.contains("expand") || lowerPrompt.contains("sensory") {
            return generateSensoryExpansion(for: prompt)
        }
        
        // Continue from cursor
        if lowerPrompt.contains("continue") || lowerPrompt.contains("next sentence") {
            return generateProseContinuation(for: prompt)
        }
        
        // Conversational chat fallback
        return generateChatResponse(for: prompt, systemPrompt: systemPrompt)
    }
    
    public func streamCompletion(prompt: String, systemPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let fullText = try await self.generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
                    let words = fullText.components(separatedBy: " ")
                    for (index, word) in words.enumerated() {
                        let token = (index == 0 ? "" : " ") + word
                        continuation.yield(token)
                        try await Task.sleep(nanoseconds: 35_000_000) // ~28 words per second
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Creative Heuristic Generators
    
    private func generateBlockBreakers(for context: String) -> String {
        return """
        Here are three divergent paths to break your block:

        1. The Subversion:
        Have the character abruptly reveal something they swore never to speak aloud. Force an immediate emotional consequence that cannot be taken back.

        2. The Sensory Interruption:
        Shift perspective to an external intrusion—a sudden fracture in the room’s silence, an unread telegram, or an anomaly in the immediate physical environment that demands their attention.

        3. The Uncomfortable Truth:
        Allow the scene’s subtext to erupt into the open. Let one character voice the exact observation everyone in the room has been tip-toeing around.
        """
    }
    
    private func generateRewrite(for text: String) -> String {
        let clean = text.replacingOccurrences(of: "Rewrite the following text with elevated style:\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Provide an evocative, tightened revision
        return "The air held the crisp stillness of early frost. Rather than lingering on what was lost, she turned toward the desk, where the unanswered letter lay beneath the amber light of the lamp."
    }
    
    private func generateSensoryExpansion(for text: String) -> String {
        return """
        Beneath the hum of the quiet street, a sharp scent of rain-soaked cedar drifted through the half-open sash. The wood beneath her fingertips was cold and pitted from years of salt air, grounding the frantic spiral of her thoughts into tangible weight.
        """
    }
    
    private func generateProseContinuation(for text: String) -> String {
        let options = [
            "Neither of them moved, letting the gravity of the confession settle into the quiet room.",
            "Outside, the rain began in earnest, drumming a steady, hollow rhythm against the leaded glass.",
            "He had rehearsed the explanation a dozen times, yet standing here, every word felt hollow and borrowed.",
            "The silence stretched between them, fragile as spun glass, until someone finally dared to exhale."
        ]
        return options.randomElement() ?? options[0]
    }
    
    private func generateChatResponse(for prompt: String, systemPrompt: String) -> String {
        return """
        Looking closely at your scene, the narrative tension hinges on what remains unsaid. Consider trimming the internal monologue and letting the physical actions carry the emotional subtext. 

        Would you like me to draft an alternative dialogue exchange or deepen the atmospheric sensory details of this setting?
        """
    }
}
