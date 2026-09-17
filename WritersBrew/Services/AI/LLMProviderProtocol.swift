import Foundation

public enum LLMProviderType: String, CaseIterable, Identifiable, Codable {
    case offlineCreative
    case openAI
    case anthropic
    case gemini
    case grok
    case ollama
    
    public var id: String { rawValue }

    static func fromPersistedValue(_ value: String) -> LLMProviderType? {
        if let currentValue = LLMProviderType(rawValue: value) {
            return currentValue
        }

        switch value {
        case "Offline Creative Engine": return .offlineCreative
        case "OpenAI (GPT-4o)": return .openAI
        case "Anthropic (Claude 3.5 Sonnet)": return .anthropic
        case "Google Gemini (2.5 Pro / Flash)": return .gemini
        case "xAI Grok": return .grok
        case "Local Model (Ollama / MLX)": return .ollama
        default: return nil
        }
    }

    public var displayName: String {
        switch self {
        case .offlineCreative: return "Offline Creative (Heuristic)"
        case .openAI: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .gemini: return "Google Gemini"
        case .grok: return "xAI"
        case .ollama: return "Ollama"
        }
    }
    
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
        case .offlineCreative: return "Local template and heuristic assistance. This is not a language model."
        case .openAI: return "Cloud generation using your OpenAI API key."
        case .anthropic: return "Cloud generation using your Anthropic API key."
        case .gemini: return "Cloud generation using your Google AI Studio key."
        case .grok: return "xAI transport is not implemented in this build."
        case .ollama: return "Connects to an Ollama server, such as localhost:11434. MLX is not implemented."
        }
    }
}

public enum AIExecutionLocation: String, Equatable {
    case local = "Local"
    case cloud = "Cloud"
}

public enum AIOperation: String, CaseIterable, Hashable {
    case chat
    case continueWriting
    case rewrite
    case expand
    case blockBreaker
}

public struct ProviderCapability: Equatable {
    public let provider: LLMProviderType
    public let providerName: String
    public let model: String
    public let executionLocation: AIExecutionLocation
    public let isAvailable: Bool
    public let isConfigured: Bool
    public let supportsStreaming: Bool
    public let supportedOperations: Set<AIOperation>
    public let statusMessage: String
}

public protocol LLMProvider {
    var type: LLMProviderType { get }
    var isConfigured: Bool { get }
    var modelIdentifier: String { get }
    var supportsStreaming: Bool { get }
    
    func generateCompletion(prompt: String, systemPrompt: String) async throws -> String
    func streamCompletion(prompt: String, systemPrompt: String) -> AsyncThrowingStream<String, Error>
}

public enum LLMError: LocalizedError {
    case missingAPIKey(String)
    case providerUnavailable(String)
    case networkFailure(String)
    case invalidResponse(String)
    case contextTooLong
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey(let provider):
            return "\(provider) is selected but not configured. Add its API key in Settings or explicitly choose another provider."
        case .providerUnavailable(let provider):
            return "\(provider) is not available in this build. Choose an implemented provider in Settings."
        case .networkFailure(let details):
            return "Connection error: \(details)"
        case .invalidResponse(let details):
            return "Model returned unexpected format: \(details)"
        case .contextTooLong:
            return "Document length exceeds maximum context window for this action."
        }
    }
}

public enum LLMProviderFactory {
    public static func makeProvider(
        for type: LLMProviderType,
        preferences: PreferencesStore
    ) throws -> any LLMProvider {
        switch type {
        case .offlineCreative:
            return OfflineCreativeEngine()
        case .openAI:
            guard !preferences.openAIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw LLMError.missingAPIKey(type.displayName)
            }
            return OpenAIProvider(apiKey: preferences.openAIKey)
        case .anthropic:
            guard !preferences.anthropicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw LLMError.missingAPIKey(type.displayName)
            }
            return AnthropicProvider(apiKey: preferences.anthropicKey)
        case .gemini:
            guard !preferences.geminiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw LLMError.missingAPIKey(type.displayName)
            }
            return GeminiProvider(apiKey: preferences.geminiKey)
        case .grok:
            throw LLMError.providerUnavailable(type.displayName)
        case .ollama:
            guard !preferences.ollamaURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw LLMError.providerUnavailable("Ollama (no server URL is configured)")
            }
            return LocalOllamaProvider(hostURL: preferences.ollamaURL)
        }
    }

    public static func capability(
        for type: LLMProviderType,
        preferences: PreferencesStore
    ) -> ProviderCapability {
        let allOperations = Set(AIOperation.allCases)

        switch type {
        case .offlineCreative:
            return ProviderCapability(
                provider: type,
                providerName: type.displayName,
                model: "Deterministic templates and heuristics",
                executionLocation: .local,
                isAvailable: true,
                isConfigured: true,
                supportsStreaming: false,
                supportedOperations: allOperations,
                statusMessage: "Ready — local heuristic assistance, not a language model"
            )
        case .openAI:
            return cloudCapability(
                type,
                model: "gpt-4o",
                configured: !preferences.openAIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        case .anthropic:
            return cloudCapability(
                type,
                model: "claude-3-5-sonnet-20241022",
                configured: !preferences.anthropicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        case .gemini:
            return cloudCapability(
                type,
                model: "gemini-2.0-flash",
                configured: !preferences.geminiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        case .grok:
            return ProviderCapability(
                provider: type,
                providerName: type.displayName,
                model: "Unavailable",
                executionLocation: .cloud,
                isAvailable: false,
                isConfigured: !preferences.grokKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                supportsStreaming: false,
                supportedOperations: [],
                statusMessage: "Unavailable — xAI transport is not implemented in this build"
            )
        case .ollama:
            let configured = !preferences.ollamaURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return ProviderCapability(
                provider: type,
                providerName: type.displayName,
                model: "llama3.2",
                executionLocation: .local,
                isAvailable: true,
                isConfigured: configured,
                supportsStreaming: false,
                supportedOperations: allOperations,
                statusMessage: configured
                    ? "Configured — server reachability is checked when used"
                    : "Not configured — add an Ollama server URL"
            )
        }
    }

    private static func cloudCapability(
        _ type: LLMProviderType,
        model: String,
        configured: Bool
    ) -> ProviderCapability {
        ProviderCapability(
            provider: type,
            providerName: type.displayName,
            model: model,
            executionLocation: .cloud,
            isAvailable: true,
            isConfigured: configured,
            supportsStreaming: false,
            supportedOperations: Set(AIOperation.allCases),
            statusMessage: configured ? "Configured — responses currently arrive as a complete result" : "Not configured — API key required"
        )
    }
}
