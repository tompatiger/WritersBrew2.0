import Foundation
import SwiftUI

@Observable
public final class DocumentStore {
    public static let shared = DocumentStore()
    
    public var projects: [BrewProject] = []
    public var folders: [BrewFolder] = []
    public var documents: [BrewDocument] = []
    
    // Storyboard items
    public var characters: [BrewCharacter] = []
    public var locations: [BrewLocation] = []
    public var timelineEvents: [BrewTimelineEvent] = []
    
    // Selected states
    public var selectedDocumentId: UUID?
    public var searchText: String = ""
    public var selectedFilter: SidebarFilter = .allDocuments
    
    public enum SidebarFilter: Hashable {
        case allDocuments
        case favorites
        case pinned
        case folder(UUID)
        case project(UUID)
        case storyboard
    }
    
    private let documentsFileURL: URL
    private let storyboardFileURL: URL
    
    private convenience init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let writersBrewDir = appSupport.appendingPathComponent("WritersBrew", isDirectory: true)

        self.init(storageDirectoryURL: writersBrewDir, seedSampleDataIfEmpty: true)
    }

    /// An isolated initializer used by tests and future persistence migration work.
    /// It never reads or writes the user's production library unless given that URL explicitly.
    init(storageDirectoryURL: URL, seedSampleDataIfEmpty: Bool = false) {
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: storageDirectoryURL, withIntermediateDirectories: true)

        self.documentsFileURL = storageDirectoryURL.appendingPathComponent("library.json")
        self.storyboardFileURL = storageDirectoryURL.appendingPathComponent("storyboard.json")
        
        load()
        
        if documents.isEmpty && seedSampleDataIfEmpty {
            seedSampleData()
        }
        
        if selectedDocumentId == nil {
            selectedDocumentId = documents.first?.id
        }
    }
    
    public var currentDocument: BrewDocument? {
        get {
            guard let id = selectedDocumentId else { return nil }
            return documents.first(where: { $0.id == id })
        }
        set {
            guard let updated = newValue,
                  let index = documents.firstIndex(where: { $0.id == updated.id }) else { return }
            documents[index] = updated
            save()
        }
    }
    
    public var filteredDocuments: [BrewDocument] {
        var list = documents
        
        switch selectedFilter {
        case .allDocuments:
            break
        case .favorites:
            list = list.filter { $0.isFavorite }
        case .pinned:
            list = list.filter { $0.isPinned }
        case .folder(let folderId):
            list = list.filter { $0.folderId == folderId }
        case .project(let projectId):
            list = list.filter { $0.projectId == projectId }
        case .storyboard:
            break
        }
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.lowercased()
            list = list.filter {
                $0.title.lowercased().contains(query) ||
                $0.content.lowercased().contains(query) ||
                $0.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }
        
        // Pinned first, then by updated date
        return list.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            }
            return $0.updatedAt > $1.updatedAt
        }
    }
    
    // MARK: - Document & Chapter Actions
    
    public func createDocument(title: String = "Untitled", folderId: UUID? = nil, projectId: UUID? = nil) -> BrewDocument {
        let newDoc = BrewDocument(
            title: title,
            content: "",
            folderId: folderId,
            projectId: projectId,
            styleProfileId: StyleProfile.narrativeFiction.id,
            createdAt: Date(),
            updatedAt: Date()
        )
        documents.insert(newDoc, at: 0)
        selectedDocumentId = newDoc.id
        save()
        return newDoc
    }
    
    public func createChapter(title: String? = nil, inProject project: BrewProject? = nil, inFolder folder: BrewFolder? = nil) -> BrewDocument {
        let targetProject = project ?? projects.first
        let existingChapters = documents.filter { doc in
            if let p = targetProject {
                return doc.projectId == p.id && doc.chapterNumber != nil
            }
            return doc.chapterNumber != nil
        }
        
        let nextChapterNum = (existingChapters.compactMap { $0.chapterNumber }.max() ?? 0) + 1
        let finalTitle = title ?? "Chapter \(nextChapterNum)"
        
        let newDoc = BrewDocument(
            title: finalTitle,
            content: "",
            folderId: folder?.id ?? targetProject.flatMap { p in folders.first(where: { $0.projectId == p.id })?.id },
            projectId: targetProject?.id,
            chapterNumber: nextChapterNum,
            orderIndex: nextChapterNum,
            tags: ["Chapter", "Draft"],
            styleProfileId: StyleProfile.narrativeFiction.id,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        documents.insert(newDoc, at: 0)
        selectedDocumentId = newDoc.id
        save()
        return newDoc
    }
    
    public func createProject(title: String, synopsis: String = "", emoji: String = "📖") -> BrewProject {
        let newProject = BrewProject(title: title, synopsis: synopsis, emoji: emoji)
        projects.append(newProject)
        save()
        return newProject
    }
    
    public func chapters(for project: BrewProject) -> [BrewDocument] {
        documents
            .filter { $0.projectId == project.id }
            .sorted { ($0.orderIndex, $0.createdAt) < ($1.orderIndex, $1.createdAt) }
    }
    
    public func deleteDocument(_ document: BrewDocument) {
        documents.removeAll { $0.id == document.id }
        if selectedDocumentId == document.id {
            selectedDocumentId = documents.first?.id
        }
        save()
    }
    
    public func toggleFavorite(for document: BrewDocument) {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        documents[index].isFavorite.toggle()
        save()
    }
    
    public func togglePinned(for document: BrewDocument) {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        documents[index].isPinned.toggle()
        save()
    }
    
    public func saveCurrentSnapshot(summary: String) {
        guard let doc = currentDocument else { return }
        var updated = doc
        let version = DocumentVersion(summary: summary, content: doc.content)
        updated.versions.insert(version, at: 0)
        currentDocument = updated
    }
    
    // MARK: - Storyboard Actions
    
    public func addCharacter(_ character: BrewCharacter) {
        characters.append(character)
        saveStoryboard()
    }
    
    public func deleteCharacter(id: UUID) {
        characters.removeAll { $0.id == id }
        saveStoryboard()
    }
    
    public func addLocation(_ location: BrewLocation) {
        locations.append(location)
        saveStoryboard()
    }
    
    public func deleteLocation(id: UUID) {
        locations.removeAll { $0.id == id }
        saveStoryboard()
    }
    
    public func addTimelineEvent(_ event: BrewTimelineEvent) {
        timelineEvents.append(event)
        saveStoryboard()
    }
    
    public func deleteTimelineEvent(id: UUID) {
        timelineEvents.removeAll { $0.id == id }
        saveStoryboard()
    }
    
    // MARK: - Persistence
    
    public func save() {
        struct LibraryPayload: Codable {
            var projects: [BrewProject]
            var folders: [BrewFolder]
            var documents: [BrewDocument]
        }
        
        let payload = LibraryPayload(projects: projects, folders: folders, documents: documents)
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: documentsFileURL)
        }
    }
    
    public func saveStoryboard() {
        struct StoryboardPayload: Codable {
            var characters: [BrewCharacter]
            var locations: [BrewLocation]
            var timelineEvents: [BrewTimelineEvent]
        }
        
        let payload = StoryboardPayload(characters: characters, locations: locations, timelineEvents: timelineEvents)
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: storyboardFileURL)
        }
    }
    
    private func load() {
        struct LibraryPayload: Codable {
            var projects: [BrewProject]
            var folders: [BrewFolder]
            var documents: [BrewDocument]
        }
        
        if let data = try? Data(contentsOf: documentsFileURL),
           let payload = try? JSONDecoder().decode(LibraryPayload.self, from: data) {
            self.projects = payload.projects
            self.folders = payload.folders
            self.documents = payload.documents
        }
        
        struct StoryboardPayload: Codable {
            var characters: [BrewCharacter]
            var locations: [BrewLocation]
            var timelineEvents: [BrewTimelineEvent]
        }
        
        if let data = try? Data(contentsOf: storyboardFileURL),
           let payload = try? JSONDecoder().decode(StoryboardPayload.self, from: data) {
            self.characters = payload.characters
            self.locations = payload.locations
            self.timelineEvents = payload.timelineEvents
        }
    }
    
    // MARK: - Seed Data
    
    private func seedSampleData() {
        let sampleProject = BrewProject(
            title: "The Solitude of Orion",
            synopsis: "A salvage cartographer uncovers an ancient beacon transmitting an impossible acoustic melody from an uninhabited moon.",
            emoji: "✨",
            genre: "Speculative Fiction",
            targetWordCount: 75000
        )
        self.projects = [sampleProject]
        
        let novelFolder = BrewFolder(name: "Act I - The Signal", emoji: "🚀", projectId: sampleProject.id)
        let essayFolder = BrewFolder(name: "Essays & Crafts", emoji: "🖋️")
        self.folders = [novelFolder, essayFolder]
        
        let sampleDoc1 = BrewDocument(
            title: "Chapter 1: The Glass Horizon",
            content: """
            The beacon pulsed every twenty-seven seconds—not with electrical noise or microwave bursts, but with an acoustic harmonic that vibrated straight through the reinforced hull of the *Stardust*.

            Elena adjusted the copper vernier on the acoustic dampener. Her breathing sounded unnaturally loud inside the pressure suit, a rhythmic reminder that outside the six-inch observation port lay nothing but four hundred Kelvin of vacuum and the jagged silhouette of Moon Nine.

            "It shouldn't carry sound," Marcus said from the navigation pit. His voice had the flat, fatigued cadence of a man who had stared at sensor telemetry for eighteen consecutive hours. "Sound requires a medium, Elena. There is no atmosphere out there."

            "Then come over here and put your palm against the viewport," she whispered.

            He hesitated, his boots magnetic-clicking against the deck plates. When his gloved fingers made contact with the glass, the faint frost patterns on the edge shifted, realigning like iron filings in a magnetic field. 

            The signal wasn't transmitting through space. It was singing directly through the matter of their ship.
            """,
            folderId: novelFolder.id,
            projectId: sampleProject.id,
            tags: ["Draft", "SciFi", "Chapter 1"],
            styleProfileId: StyleProfile.narrativeFiction.id,
            isPinned: true,
            isFavorite: true
        )
        
        let sampleDoc2 = BrewDocument(
            title: "On the Sacred Geometry of Sentences",
            content: """
            To write well is not to decorate thought, but to strip away the accidental. 

            When a sentence is built with precision, the reader does not admire the engineering; they simply walk through the architecture of the idea as though it had always existed in the room. A short sentence creates momentum. It acts like a gavel on the desk, cutting through hesitation. But a cascade of short sentences becomes brittle, exhausting the ear like the endless clatter of a typewriter keys.

            Conversely, the long, periodic sentence invites contemplation. It gathers clauses into a deep breath, suspending resolution until the final word falls like a silver coin into stillness. 

            Great prose is an intentional alternation between tension and release—the rhythm of thought made visible.
            """,
            folderId: essayFolder.id,
            tags: ["Craft", "Essay"],
            styleProfileId: StyleProfile.concise.id,
            isPinned: false,
            isFavorite: true
        )
        
        self.documents = [sampleDoc1, sampleDoc2]
        
        // Seed Storyboard
        let elena = BrewCharacter(
            name: "Elena Vance",
            role: .protagonist,
            tagline: "Salvage Cartographer with a sharp ear for cosmic anomalies.",
            appearance: "Silver-streaked dark hair cropped close, weathered hands, worn flight suit with faded expedition patches.",
            personalityTraits: ["Observant", "Guarded", "Doggedly curious"],
            backstory: "Spent twelve years charting dead mining orbits after her research vessel was decommissioned by the Bureau.",
            externalGoal: "Decipher the acoustic harmonic before the salvage syndicate reclaims the sector.",
            internalNeed: "To prove that her brother’s disappearance near Moon Nine was not an accident.",
            voiceNotes: "Speaks quietly, pauses before concluding sentences, dislikes bureaucratic jargon.",
            colorHex: "#E89138"
        )
        
        let marcus = BrewCharacter(
            name: "Marcus Thorne",
            role: .foil,
            tagline: "Pragmatic orbital navigator and reluctant co-pilot.",
            appearance: "Broad-shouldered, pale from decades in deep space, perpetual five o'clock shadow.",
            personalityTraits: ["Skeptical", "Methodical", "Loyal"],
            backstory: "Former navy telemetry officer who survived the Callisto orbital collapse.",
            externalGoal: "Keep the ship intact and make enough credits to retire on Ganymede.",
            internalNeed: "To believe in something that cannot be neatly calculated on a spreadsheet.",
            voiceNotes: "Dry, sarcastic, references standard operating protocols when stressed.",
            colorHex: "#5E81AC"
        )
        
        self.characters = [elena, marcus]
        
        let moonNine = BrewLocation(
            name: "Moon Nine (The Glass Spire)",
            category: "Airless Celestial Body",
            atmosphere: "Dead stillness, harsh blinding sunlight against pitch-black shadows, absolute vacuum.",
            sensoryDetails: "Rumbling sub-bass vibration conducted through bedrock, blinding glare off silicate dunes, ozone smell in airlocks.",
            rulesOrLore: "Radio signals bend anomalously within 50km of the northern crater.",
            historicalBackground: "Abandoned during the Great Consolidation sixty years ago."
        )
        self.locations = [moonNine]
        
        let event1 = BrewTimelineEvent(
            title: "First Harmonic Contact",
            chapterOrAct: "Chapter 1",
            orderIndex: 0,
            summary: "The Stardust detects an impossible acoustic vibration conducting through the hull while surveying Moon Nine.",
            locationName: "Moon Nine",
            characterNames: ["Elena Vance", "Marcus Thorne"],
            tensionLevel: 3,
            arcStage: .incitingIncident,
            notes: "Must establish the eerie physical sensation of the sound rather than just electronic beeping."
        )
        self.timelineEvents = [event1]
        
        save()
        saveStoryboard()
    }
}
