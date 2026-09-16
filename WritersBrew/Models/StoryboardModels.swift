import Foundation

// MARK: - Characters

public struct BrewCharacter: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var role: CharacterRole
    public var tagline: String
    public var appearance: String
    public var personalityTraits: [String]
    public var backstory: String
    public var externalGoal: String
    public var internalNeed: String
    public var voiceNotes: String
    public var relationships: [String]
    public var colorHex: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        role: CharacterRole = .protagonist,
        tagline: String = "",
        appearance: String = "",
        personalityTraits: [String] = [],
        backstory: String = "",
        externalGoal: String = "",
        internalNeed: String = "",
        voiceNotes: String = "",
        relationships: [String] = [],
        colorHex: String = "#E89138"
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.tagline = tagline
        self.appearance = appearance
        self.personalityTraits = personalityTraits
        self.backstory = backstory
        self.externalGoal = externalGoal
        self.internalNeed = internalNeed
        self.voiceNotes = voiceNotes
        self.relationships = relationships
        self.colorHex = colorHex
    }
}

public enum CharacterRole: String, CaseIterable, Codable {
    case protagonist = "Protagonist"
    case antagonist = "Antagonist"
    case deuteragonist = "Deuteragonist"
    case mentor = "Mentor"
    case foil = "Foil"
    case supporting = "Supporting"
    
    public var icon: String {
        switch self {
        case .protagonist: return "star.fill"
        case .antagonist: return "flame.fill"
        case .deuteragonist: return "person.2.fill"
        case .mentor: return "book.closed.fill"
        case .foil: return "arrow.left.arrow.right"
        case .supporting: return "person.fill"
        }
    }
}

// MARK: - Worlds & Locations

public struct BrewLocation: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var category: String // e.g. "Metropolis", "Sanctuary", "Frontier Station"
    public var atmosphere: String
    public var sensoryDetails: String // sights, smells, sounds, ambient temperature
    public var rulesOrLore: String
    public var historicalBackground: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: String = "Key Location",
        atmosphere: String = "",
        sensoryDetails: String = "",
        rulesOrLore: String = "",
        historicalBackground: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.atmosphere = atmosphere
        self.sensoryDetails = sensoryDetails
        self.rulesOrLore = rulesOrLore
        self.historicalBackground = historicalBackground
    }
}

// MARK: - Timeline & Scenes

public struct BrewTimelineEvent: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var chapterOrAct: String
    public var orderIndex: Int
    public var summary: String
    public var locationName: String
    public var characterNames: [String]
    public var tensionLevel: Int // 1 to 5
    public var arcStage: NarrativeArcStage
    public var notes: String
    
    public init(
        id: UUID = UUID(),
        title: String,
        chapterOrAct: String = "Chapter 1",
        orderIndex: Int = 0,
        summary: String = "",
        locationName: String = "",
        characterNames: [String] = [],
        tensionLevel: Int = 3,
        arcStage: NarrativeArcStage = .risingAction,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.chapterOrAct = chapterOrAct
        self.orderIndex = orderIndex
        self.summary = summary
        self.locationName = locationName
        self.characterNames = characterNames
        self.tensionLevel = tensionLevel
        self.arcStage = arcStage
        self.notes = notes
    }
}

public enum NarrativeArcStage: String, CaseIterable, Codable {
    case hook = "The Hook"
    case exposition = "Exposition"
    case incitingIncident = "Inciting Incident"
    case plotPointOne = "First Plot Point"
    case risingAction = "Rising Action"
    case midpoint = "Midpoint Shift"
    case allHopeLost = "Dark Night of the Soul"
    case climax = "Climax"
    case resolution = "Resolution"
    
    public var colorHex: String {
        switch self {
        case .hook: return "#5E81AC"
        case .exposition: return "#81A1C1"
        case .incitingIncident: return "#88C0D0"
        case .plotPointOne: return "#A3BE8C"
        case .risingAction: return "#EBCB8B"
        case .midpoint: return "#D08770"
        case .allHopeLost: return "#BF616A"
        case .climax: return "#B48EAD"
        case .resolution: return "#8FBCBB"
        }
    }
}
