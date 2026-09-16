import SwiftUI

public struct AnalyzerInspectorView: View {
    let report: AnalysisReport
    let style: StyleProfile
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Craft & Prose Analyzer", systemImage: "sparkle.magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                
                Spacer()
                
                Text(style.name)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider().opacity(0.3)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Unified Quality Score Dial
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 8)
                                .frame(width: 86, height: 86)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(report.score) / 100.0)
                                .stroke(report.label.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 86, height: 86)
                            
                            VStack(spacing: 2) {
                                Text("\(report.score)%")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                
                                Text(report.label.rawValue)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(report.label.color)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .liquidGlassCard()
                    
                    // Core Metric Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        metricTile(
                            title: "Readability",
                            value: "Grade \(String(format: "%.1f", report.fleschKincaidGrade))",
                            icon: "text.book.closed"
                        )
                        metricTile(
                            title: "Reading Ease",
                            value: "\(Int(report.readingEase))/100",
                            icon: "eyeglasses"
                        )
                        metricTile(
                            title: "Avg Sentence",
                            value: "\(String(format: "%.1f", report.averageSentenceLength)) words",
                            icon: "ruler"
                        )
                        metricTile(
                            title: "Rhythm Variance",
                            value: report.sentenceLengthVariance > 4 ? "High" : "Low",
                            icon: "waveform.path.ecg"
                        )
                    }
                    
                    // Targeted Craft Insights
                    if !report.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Stylistic Insights")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                            
                            ForEach(report.insights) { insight in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: insight.category.icon)
                                        .foregroundStyle(Color.accentColor)
                                        .font(.system(size: 12))
                                        .padding(.top, 2)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(insight.title)
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(insight.explanation)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                            .lineSpacing(2)
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.primary.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    
                    // Overused Crutch Words
                    if !report.overusedWords.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Crutch Words")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                            
                            ForEach(report.overusedWords) { word in
                                HStack {
                                    Text("\"\(word.word)\"")
                                        .font(.system(size: 12, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(word.count)x")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.orange)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 300)
        .background(.ultraThinMaterial)
    }
    
    private func metricTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
