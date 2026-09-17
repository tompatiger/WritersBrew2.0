import Foundation

public final class LocalOllamaProvider: LLMProvider {
    public let type: LLMProviderType = .ollama
    private let hostURL: String
    public let modelIdentifier: String
    public let supportsStreaming: Bool = false
    
    public var isConfigured: Bool {
        !hostURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public init(hostURL: String = "http://localhost:11434", model: String = "llama3.2") {
        self.hostURL = hostURL
        self.modelIdentifier = model
    }
    
    public func generateCompletion(prompt: String, systemPrompt: String) async throws -> String {
        guard let url = URL(string: "\(hostURL)/api/generate") else {
            throw LLMError.invalidResponse("Invalid Ollama host URL: \(hostURL)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let payload: [String: Any] = [
            "model": modelIdentifier,
            "system": systemPrompt,
            "prompt": prompt,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw LLMError.networkFailure("Could not reach Ollama at \(hostURL). Make sure Ollama is running.")
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let responseText = json["response"] as? String else {
                throw LLMError.invalidResponse("Could not parse Ollama response format.")
            }
            
            return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw LLMError.networkFailure("Ollama connection failed: \(error.localizedDescription)")
        }
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
