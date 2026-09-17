import Foundation
import Security

public enum ProviderCredential: String, CaseIterable, Sendable {
    case openAI = "openai"
    case anthropic = "anthropic"
    case gemini = "gemini"
    case xAI = "xai"

    var legacyUserDefaultsKey: String {
        switch self {
        case .openAI: return "openAIKey"
        case .anthropic: return "anthropicKey"
        case .gemini: return "geminiKey"
        case .xAI: return "grokKey"
        }
    }
}

public protocol CredentialStore {
    func credential(for provider: ProviderCredential) throws -> String?
    func setCredential(_ credential: String, for provider: ProviderCredential) throws
    func removeCredential(for provider: ProviderCredential) throws
}

public enum CredentialStoreError: LocalizedError, Equatable {
    case invalidCredentialEncoding
    case keychain(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentialEncoding:
            return "The credential could not be encoded securely."
        case .keychain(let status):
            let detail = SecCopyErrorMessageString(status, nil) as String? ?? "status \(status)"
            return "Keychain operation failed (\(detail))."
        }
    }
}

/// Stores provider credentials in the user's login Keychain. Secret values are never logged.
public final class KeychainCredentialStore: CredentialStore {
    public static let shared = KeychainCredentialStore()

    private let service: String

    public init(service: String = "com.writersbrew.WritersBrew.api-credentials") {
        self.service = service
    }

    public func credential(for provider: ProviderCredential) throws -> String? {
        var query = baseQuery(for: provider)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw CredentialStoreError.keychain(status)
        }
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw CredentialStoreError.invalidCredentialEncoding
        }
        return value
    }

    public func setCredential(_ credential: String, for provider: ProviderCredential) throws {
        let trimmed = credential.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            try removeCredential(for: provider)
            return
        }
        guard let data = trimmed.data(using: .utf8) else {
            throw CredentialStoreError.invalidCredentialEncoding
        }

        let query = baseQuery(for: provider)
        let attributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw CredentialStoreError.keychain(addStatus)
            }
            return
        }

        guard updateStatus == errSecSuccess else {
            throw CredentialStoreError.keychain(updateStatus)
        }
    }

    public func removeCredential(for provider: ProviderCredential) throws {
        let status = SecItemDelete(baseQuery(for: provider) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialStoreError.keychain(status)
        }
    }

    private func baseQuery(for provider: ProviderCredential) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider.rawValue
        ]
    }
}
