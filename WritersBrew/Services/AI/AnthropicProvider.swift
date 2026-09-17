import Foundation

public final class AnthropicProvider: LLMProvider {
    public let type: LLMProviderType = .anthropic
    private let apiKey: String
    public let modelIdentifier: String
    public let supportsStreaming: Bool = false
    
    public var isConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public init(apiKey: String, model: String = "claude-3-5-sonnet-20241022") {
        self.apiKey = apiKey
        self.modelIdentifier = model
    }
    
    public func generateCompletion(prompt: String, systemPrompt: String) async throws -> String {
        guard isConfigured else {
            throw LLMError.missingAPIKey("Anthropic")
        }
        
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let payload: [String: Any] = [
            "model": modelIdentifier,
            "system": systemPrompt,
            "max_tokens": 2048,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown HTTP status"
            throw LLMError.networkFailure("Anthropic API returned error: \(errorText)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstText = content.first?["text"] as? String else {
            throw LLMError.invalidResponse("Could not parse Anthropic response.")
        }
        
        return firstText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func streamCompletion(prompt: String, systemPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let result = try await self.generateCompletion(prompt: prompt, systemPrompt: systemPrompt)
                    continuation.yield(result)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
