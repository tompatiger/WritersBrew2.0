import Foundation

public final class ProseAnalyzer {
    public static let shared = ProseAnalyzer()
    
    private let commonCrutchWords: Set<String> = [
        "very", "just", "really", "suddenly", "seemed", "felt", "started",
        "actually", "basically", "perhaps", "almost", "somewhat", "quietly"
    ]
    
    private init() {}
    
    public func analyze(text: String, style: StyleProfile) -> AnalysisReport {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .empty
        }
        
        let sentences = extractSentences(from: trimmed)
        let words = extractWords(from: trimmed)
        
        guard !sentences.isEmpty && !words.isEmpty else {
            return .empty
        }
        
        let wordCount = Double(words.count)
        let sentenceCount = Double(sentences.count)
        let syllableCount = words.reduce(0) { $0 + countSyllables(in: $1) }
        
        // Flesch Reading Ease: 206.835 - 1.015 * (total words / total sentences) - 84.6 * (total syllables / total words)
        let aslL = wordCount / sentenceCount
        let asw = Double(syllableCount) / max(1.0, wordCount)
        let rawEase = 206.835 - (1.015 * aslL) - (84.6 * asw)
        let readingEase = max(0.0, min(100.0, rawEase))
        
        // Flesch-Kincaid Grade Level: 0.39 * (total words / total sentences) + 11.8 * (total syllables / total words) - 15.59
        let gradeLevel = max(1.0, (0.39 * aslL) + (11.8 * asw) - 15.59)
        
        // Sentence variety / variance
        let sentenceLengths = sentences.map { Double(extractWords(from: $0).count) }
        let avgLength = aslL
        let variance = sentenceLengths.reduce(0.0) { $0 + pow($1 - avgLength, 2) } / max(1.0, sentenceCount)
        let stdDev = sqrt(variance)
        
        // Overused crutch words
        var freqMap: [String: Int] = [:]
        for word in words {
            let lower = word.lowercased()
            if commonCrutchWords.contains(lower) {
                freqMap[lower, default: 0] += 1
            }
        }
        
        let overused = freqMap.compactMap { (word, count) -> WordFrequency? in
            guard count >= 2 else { return nil }
            return WordFrequency(
                word: word,
                count: count,
                suggestion: "Consider pruning or replacing with stronger action"
            )
        }.sorted { $0.count > $1.count }
        
        // Generate insights
        var insights: [AnalysisInsight] = []
        
        // Variety insight
        if stdDev < 3.5 {
            insights.append(AnalysisInsight(
                category: .rhythm,
                title: "Monotonous Sentence Rhythm",
                explanation: "Sentences cluster tightly around \(Int(avgLength)) words. Mix short punchy clauses with longer flowing thoughts to create musical cadence."
            ))
        } else {
            insights.append(AnalysisInsight(
                category: .rhythm,
                title: "Dynamic Sentence Cadence",
                explanation: "Excellent variance in sentence structures keeps reader momentum high."
            ))
        }
        
        // Crutch words insight
        if let topCrutch = overused.first, topCrutch.count >= 4 {
            insights.append(AnalysisInsight(
                category: .vocabulary,
                title: "Repeated Crutch Word: '\(topCrutch.word)'",
                explanation: "Used \(topCrutch.count) times in this passage. Filtering crutch adverbs sharpens scene immediacy."
            ))
        }
        
        // Target length alignment with active style
        let diff = abs(avgLength - Double(style.targetSentenceLength))
        if diff <= 4.0 {
            insights.append(AnalysisInsight(
                category: .tone,
                title: "Aligned with \(style.name) Profile",
                explanation: "Average sentence length (\(String(format: "%.1f", avgLength)) words) matches the \(style.name) profile perfectly."
            ))
        }
        
        // Calculate unified 0-100 score
        var score = 85
        if stdDev >= 4.0 { score += 5 } else { score -= 6 }
        if readingEase >= 60.0 && readingEase <= 85.0 { score += 5 }
        score -= min(15, overused.reduce(0) { $0 + $1.count * 2 })
        score = max(35, min(98, score))
        
        let label: QualitativeLabel
        switch score {
        case 88...100: label = .excellent
        case 74..<88: label = .good
        case 55..<74: label = .needsImprovement
        default: label = .weak
        }
        
        return AnalysisReport(
            score: score,
            label: label,
            fleschKincaidGrade: gradeLevel,
            readingEase: readingEase,
            averageSentenceLength: avgLength,
            sentenceLengthVariance: stdDev,
            overusedWords: Array(overused.prefix(6)),
            insights: insights,
            timestamp: Date()
        )
    }
    
    // MARK: - Helpers
    
    private func extractSentences(from text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences
    }
    
    private func extractWords(from text: String) -> [String] {
        var words: [String] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byWords) { substring, _, _, _ in
            if let word = substring?.trimmingCharacters(in: .punctuationCharacters), !word.isEmpty {
                words.append(word)
            }
        }
        return words
    }
    
    private func countSyllables(in word: String) -> Int {
        let lower = word.lowercased()
        if lower.count <= 3 { return 1 }
        
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        var count = 0
        var prevWasVowel = false
        
        for char in lower {
            let isVowel = vowels.contains(char)
            if isVowel && !prevWasVowel {
                count += 1
            }
            prevWasVowel = isVowel
        }
        
        if lower.hasSuffix("e") && !lower.hasSuffix("le") && count > 1 {
            count -= 1
        }
        return max(1, count)
    }
}
