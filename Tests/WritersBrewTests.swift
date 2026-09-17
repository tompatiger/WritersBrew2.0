import XCTest
@testable import WritersBrew

final class CredentialMigrationTests: XCTestCase {
    func testLegacyCredentialsMoveToCredentialStoreAndLeaveDefaults() throws {
        let defaults = makeDefaults()
        let credentialStore = InMemoryCredentialStore()
        let legacyValues: [ProviderCredential: String] = [
            .openAI: "openai-secret",
            .anthropic: "anthropic-secret",
            .gemini: "gemini-secret",
            .xAI: "xai-secret"
        ]

        for (provider, value) in legacyValues {
            defaults.set(value, forKey: provider.legacyUserDefaultsKey)
        }

        let preferences = PreferencesStore(defaults: defaults, credentialStore: credentialStore)

        XCTAssertEqual(preferences.openAIKey, legacyValues[.openAI])
        XCTAssertEqual(preferences.anthropicKey, legacyValues[.anthropic])
        XCTAssertEqual(preferences.geminiKey, legacyValues[.gemini])
        XCTAssertEqual(preferences.grokKey, legacyValues[.xAI])

        for (provider, value) in legacyValues {
            XCTAssertEqual(try credentialStore.credential(for: provider), value)
            XCTAssertNil(defaults.object(forKey: provider.legacyUserDefaultsKey))
        }
        XCTAssertNil(preferences.credentialError)
    }

    func testFailedMigrationRetainsLegacyCredential() {
        let defaults = makeDefaults()
        let credentialStore = InMemoryCredentialStore()
        credentialStore.providersThatFailOnWrite = [.openAI]
        defaults.set("must-not-be-lost", forKey: ProviderCredential.openAI.legacyUserDefaultsKey)

        let preferences = PreferencesStore(defaults: defaults, credentialStore: credentialStore)

        XCTAssertEqual(preferences.openAIKey, "must-not-be-lost")
        XCTAssertEqual(
            defaults.string(forKey: ProviderCredential.openAI.legacyUserDefaultsKey),
            "must-not-be-lost"
        )
        XCTAssertNotNil(preferences.credentialError)
    }

    func testUpdatingCredentialDoesNotWriteSecretToDefaults() throws {
        let defaults = makeDefaults()
        let credentialStore = InMemoryCredentialStore()
        let preferences = PreferencesStore(defaults: defaults, credentialStore: credentialStore)

        preferences.openAIKey = "new-secret"

        XCTAssertEqual(try credentialStore.credential(for: .openAI), "new-secret")
        XCTAssertNil(defaults.object(forKey: ProviderCredential.openAI.legacyUserDefaultsKey))
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "WritersBrewTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

final class ProviderSelectionTests: XCTestCase {
    func testLegacyProviderPreferenceMigratesToStableIdentifier() {
        let suiteName = "WritersBrewProviderMigrationTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set("Local Model (Ollama / MLX)", forKey: "activeProvider")

        let preferences = PreferencesStore(defaults: defaults, credentialStore: InMemoryCredentialStore())

        XCTAssertEqual(preferences.activeProvider, .ollama)
        XCTAssertEqual(defaults.string(forKey: "activeProvider"), LLMProviderType.ollama.rawValue)
    }

    func testUnconfiguredCloudProviderThrowsInsteadOfFallingBack() {
        let preferences = makePreferences()
        preferences.activeProvider = .openAI

        XCTAssertThrowsError(
            try LLMProviderFactory.makeProvider(for: .openAI, preferences: preferences)
        ) { error in
            guard case LLMError.missingAPIKey(let provider) = error else {
                return XCTFail("Expected missingAPIKey, got \(error)")
            }
            XCTAssertEqual(provider, "OpenAI")
        }
    }

    func testConfiguredProviderResolvesToExactProvider() throws {
        let preferences = makePreferences()
        preferences.anthropicKey = "test-key"

        let provider = try LLMProviderFactory.makeProvider(for: .anthropic, preferences: preferences)

        XCTAssertEqual(provider.type, .anthropic)
        XCTAssertFalse(provider.supportsStreaming)
        XCTAssertEqual(provider.modelIdentifier, "claude-3-5-sonnet-20241022")
    }

    func testXAIIsExplicitlyUnavailable() {
        let preferences = makePreferences()
        preferences.grokKey = "stored-for-future-support"

        let capability = LLMProviderFactory.capability(for: .grok, preferences: preferences)

        XCTAssertFalse(capability.isAvailable)
        XCTAssertFalse(capability.supportsStreaming)
        XCTAssertTrue(capability.supportedOperations.isEmpty)
        XCTAssertThrowsError(
            try LLMProviderFactory.makeProvider(for: .grok, preferences: preferences)
        ) { error in
            guard case LLMError.providerUnavailable = error else {
                return XCTFail("Expected providerUnavailable, got \(error)")
            }
        }
    }

    func testOfflineAndOllamaCapabilitiesAreHonest() {
        let preferences = makePreferences()
        let offline = LLMProviderFactory.capability(for: .offlineCreative, preferences: preferences)
        let ollama = LLMProviderFactory.capability(for: .ollama, preferences: preferences)

        XCTAssertEqual(offline.executionLocation, .local)
        XCTAssertTrue(offline.statusMessage.contains("not a language model"))
        XCTAssertFalse(offline.supportsStreaming)
        XCTAssertEqual(ollama.providerName, "Ollama")
        XCTAssertFalse(LLMProviderType.ollama.description.contains(" / MLX"))
    }

    private func makePreferences() -> PreferencesStore {
        let suiteName = "WritersBrewProviderTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return PreferencesStore(defaults: defaults, credentialStore: InMemoryCredentialStore())
    }
}

final class DocumentStoreTests: XCTestCase {
    func testCreatesProjectAndDocumentWithRelationship() throws {
        let directory = try makeTemporaryDirectory()
        let store = DocumentStore(storageDirectoryURL: directory)

        let project = store.createProject(title: "Field Notes")
        let document = store.createDocument(title: "Day One", projectId: project.id)

        XCTAssertEqual(store.projects, [project])
        XCTAssertEqual(store.documents.count, 1)
        XCTAssertEqual(document.projectId, project.id)
        XCTAssertEqual(store.currentDocument?.id, document.id)
        XCTAssertTrue(store.documents.contains(where: { $0.projectId == project.id }))
    }

    func testLibraryRoundTripUsesIsolatedDirectory() throws {
        let directory = try makeTemporaryDirectory()
        let firstStore = DocumentStore(storageDirectoryURL: directory)
        let project = firstStore.createProject(title: "A Project")
        _ = firstStore.createChapter(title: "Opening", inProject: project)

        let reloadedStore = DocumentStore(storageDirectoryURL: directory)

        XCTAssertEqual(reloadedStore.projects.map(\.title), ["A Project"])
        XCTAssertEqual(reloadedStore.documents.map(\.title), ["Opening"])
        XCTAssertEqual(reloadedStore.documents.first?.projectId, project.id)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WritersBrewTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }
}

final class ProductionLogicTests: XCTestCase {
    func testProseAnalyzerReportsRepeatedCrutchWordFromProductionImplementation() {
        let text = "It was very quiet. It was very still. It was very cold. It was very late."

        let report = ProseAnalyzer.shared.analyze(text: text, style: .concise)

        XCTAssertEqual(report.overusedWords.first(where: { $0.word == "very" })?.count, 4)
        XCTAssertTrue(report.insights.contains(where: { $0.category == .vocabulary }))
    }

    func testVoiceEngineRecordsAndPersistsAcceptedSuggestion() {
        let suiteName = "WritersBrewVoiceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let storageKey = "voice-test"
        let engine = VoiceLearningEngine(defaults: defaults, storageKey: storageKey)
        let originalCount = engine.currentVoiceSkill.acceptedSuggestionsCount

        engine.recordAcceptedSuggestion(text: "Subterranean harmonics reverberated everywhere.")
        let reloaded = VoiceLearningEngine(defaults: defaults, storageKey: storageKey)

        XCTAssertEqual(reloaded.currentVoiceSkill.acceptedSuggestionsCount, originalCount + 1)
        XCTAssertTrue(reloaded.currentVoiceSkill.distinctiveVocabulary.contains("subterranean"))
        XCTAssertGreaterThan(reloaded.currentVoiceSkill.totalWordsAnalyzed, 0)
    }
}

private final class InMemoryCredentialStore: CredentialStore {
    var values: [ProviderCredential: String] = [:]
    var providersThatFailOnWrite: Set<ProviderCredential> = []

    func credential(for provider: ProviderCredential) throws -> String? {
        values[provider]
    }

    func setCredential(_ credential: String, for provider: ProviderCredential) throws {
        if providersThatFailOnWrite.contains(provider) {
            throw TestCredentialError.writeFailed
        }
        values[provider] = credential
    }

    func removeCredential(for provider: ProviderCredential) throws {
        values.removeValue(forKey: provider)
    }

    private enum TestCredentialError: Error {
        case writeFailed
    }
}
