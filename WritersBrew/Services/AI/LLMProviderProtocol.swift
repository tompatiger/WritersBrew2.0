import Foundation

public enum LLMProviderType: String, CaseIterable, Identifiable, Codable {
    case offlineCreative = "Offline Creative Engine"
    case openAI = "OpenAI (GPT-4o)"
    case anthropic = "Anthropic (Claude 3.5 Sonnet)"
    case gemini = "Google Gemini (2.5 Pro / Flash)"
    case grok = "xAI Grok"
    case ollama = "Local Model (Ollama / MLX)"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .offlineCreative: return "sparkles.rectangle.stack"
        case .openAI: return "brain.head.profile"
        case .anthropic: return "cpu"
        case .gemini: return "bolt.shield.fill"
        case .grok: return "tornado"
        case .ollama: return "desktopcomputer"
        }
    }
    
    public var description: String {
        switch self {
        case .offlineCreative: return "Runs 100% locally with zero setup or API keys needed."
        case .openAI: return "Bring your OpenAI API key for GPT-4o / mini."
        case .anthropic: return "Bring your Anthropic API key for Claude 3.5 Sonnet."
        case .gemini: return "Bring your Google AI Studio key for Gemini models."
        case .grok: return "Bring your xAI key for Grok models."
        case .ollama: return "Connects to your local Ollama / MLX instance (e.g. localhost:11434)."
        }
    }
}

public protocol LLMProvider {
    var type: LLMProviderType { get }
    var isConfigured: Bool { get }
    
    func generateCompletion(prompt: String, systemPrompt: String) async throws -> String
    func streamCompletion(prompt: String, systemPrompt: String) -> AsyncThrowingStream<String, Error>
}

public enum LLMError: LocalizedError {
    case missingAPIKey(String)
    case networkFailure(String)
    case invalidResponse(String)
    case contextTooLong
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey(let provider):
            return "Missing API key for \(provider). Please enter one in Settings or switch to Offline mode."
        case .networkFailure(let details):
            return "Connection error: \(details)"
        case .invalidResponse(let details):
            return "Model returned unexpected format: \(details)"
        case .contextTooLong:
            return "Document length exceeds maximum context window for this action."
        }
    }
}
