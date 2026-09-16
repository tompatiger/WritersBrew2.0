import SwiftUI

public enum QualitativeLabel: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case needsImprovement = "Needs Improvement"
    case weak = "Weak"
    
    public var color: Color {
        switch self {
        case .excellent: return Color.green
        case .good: return Color.blue
        case .needsImprovement: return Color.orange
        case .weak: return Color.red
        }
    }
    
    public var icon: String {
        switch self {
        case .excellent: return "sparkles"
        case .good: return "checkmark.circle.fill"
        case .needsImprovement: return "exclamationmark.triangle.fill"
        case .weak: return "xmark.octagon.fill"
        }
    }
}

public struct WordFrequency: Identifiable, Codable, Equatable, Hashable {
    public var id: String { word }
    public var word: String
    public var count: Int
    public var suggestion: String
    
    public init(word: String, count: Int, suggestion: String = "") {
        self.word = word
        self.count = count
        self.suggestion = suggestion
    }
}

public struct AnalysisInsight: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var category: InsightCategory
    public var title: String
    public var explanation: String
    public var suggestedFix: String?
    
    public init(
        id: UUID = UUID(),
        category: InsightCategory,
        title: String,
        explanation: String,
        suggestedFix: String? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.explanation = explanation
        self.suggestedFix = suggestedFix
    }
}

public enum InsightCategory: String, CaseIterable, Codable {
    case clarity = "Clarity"
    case rhythm = "Sentence Variety"
    case vocabulary = "Vocabulary"
    case tone = "Tone Consistency"
    case pacing = "Pacing"
    
    public var icon: String {
        switch self {
        case .clarity: return "eyeglasses"
        case .rhythm: return "waveform.path.ecg"
        case .vocabulary: return "character.book.closed"
        case .tone: return "tuningfork"
        case .pacing: return "metronome"
        }
    }
}

public struct AnalysisReport: Codable, Equatable {
    public var score: Int // 0 - 100
    public var label: QualitativeLabel
    public var fleschKincaidGrade: Double
    public var readingEase: Double
    public var averageSentenceLength: Double
    public var sentenceLengthVariance: Double
    public var overusedWords: [WordFrequency]
    public var insights: [AnalysisInsight]
    public var timestamp: Date
    
    public init(
        score: Int = 88,
        label: QualitativeLabel = .good,
        fleschKincaidGrade: Double = 8.2,
        readingEase: Double = 72.4,
        averageSentenceLength: Double = 16.4,
        sentenceLengthVariance: Double = 6.8,
        overusedWords: [WordFrequency] = [],
        insights: [AnalysisInsight] = [],
        timestamp: Date = Date()
    ) {
        self.score = score
        self.label = label
        self.fleschKincaidGrade = fleschKincaidGrade
        self.readingEase = readingEase
        self.averageSentenceLength = averageSentenceLength
        self.sentenceLengthVariance = sentenceLengthVariance
        self.overusedWords = overusedWords
        self.insights = insights
        self.timestamp = timestamp
    }
    
    public static let empty = AnalysisReport(
        score: 0,
        label: .needsImprovement,
        fleschKincaidGrade: 0,
        readingEase: 0,
        averageSentenceLength: 0,
        sentenceLengthVariance: 0,
        overusedWords: [],
        insights: [],
        timestamp: Date()
    )
}
