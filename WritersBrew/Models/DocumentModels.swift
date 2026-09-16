import Foundation

// MARK: - Document Version

public struct DocumentVersion: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var timestamp: Date
    public var summary: String
    public var content: String
    public var wordCount: Int
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        summary: String,
        content: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.summary = summary
        self.content = content
        self.wordCount = content.split { $0.isWhitespace || $0.isNewline }.count
    }
}

// MARK: - Document

public struct BrewDocument: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var content: String
    public var folderId: UUID?
    public var projectId: UUID?
    public var chapterNumber: Int?
    public var orderIndex: Int
    public var tags: [String]
    public var styleProfileId: String
    public var isPinned: Bool
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var versions: [DocumentVersion]
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        folderId: UUID? = nil,
        projectId: UUID? = nil,
        chapterNumber: Int? = nil,
        orderIndex: Int = 0,
        tags: [String] = [],
        styleProfileId: String = StyleProfile.narrativeFiction.id,
        isPinned: Bool = false,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        versions: [DocumentVersion] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.folderId = folderId
        self.projectId = projectId
        self.chapterNumber = chapterNumber
        self.orderIndex = orderIndex
        self.tags = tags
        self.styleProfileId = styleProfileId
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.versions = versions
    }
    
    public var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    public var characterCount: Int {
        content.count
    }
    
    public var readingTimeMinutes: Double {
        let words = Double(wordCount)
        return max(1.0, ceil(words / 225.0))
    }
    
    public var paragraphCount: Int {
        let paragraphs = content.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return max(1, paragraphs.count)
    }
}

// MARK: - Folders & Projects

public struct BrewFolder: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var emoji: String
    public var projectId: UUID?
    
    public init(id: UUID = UUID(), name: String, emoji: String = "📁", projectId: UUID? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.projectId = projectId
    }
}

public struct BrewProject: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var synopsis: String
    public var emoji: String
    public var genre: String
    public var targetWordCount: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        synopsis: String = "",
        emoji: String = "📖",
        genre: String = "Literary Fiction",
        targetWordCount: Int = 80000,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.emoji = emoji
        self.genre = genre
        self.targetWordCount = targetWordCount
        self.createdAt = createdAt
    }
}
