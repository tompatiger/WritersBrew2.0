import SwiftUI

public struct StoryboardMainView: View {
    @State private var selectedTab: StoryboardTab = .characters
    @State private var store = DocumentStore.shared
    
    // Sheet states for creating items
    @State private var showNewCharacterSheet: Bool = false
    @State private var showNewLocationSheet: Bool = false
    @State private var showNewTimelineEventSheet: Bool = false
    
    public enum StoryboardTab: String, CaseIterable, Identifiable {
        case characters = "Characters"
        case locations = "Worlds & Lore"
        case timeline = "Timeline & Arcs"
        
        public var id: String { rawValue }
        
        public var icon: String {
            switch self {
            case .characters: return "person.2.fill"
            case .locations: return "map.fill"
            case .timeline: return "chart.bar.doc.horizontal.fill"
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tab Selector Bar
            HStack {
                Picker("Storyboard View", selection: $selectedTab) {
                    ForEach(StoryboardTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 400)
                
                Spacer()
                
                Button {
                    switch selectedTab {
                    case .characters: showNewCharacterSheet = true
                    case .locations: showNewLocationSheet = true
                    case .timeline: showNewTimelineEventSheet = true
                    }
                } label: {
                    Label("Add \(selectedTab.rawValue.dropLast())", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(16)
            
            Divider()
            
            // Content
            ScrollView {
                switch selectedTab {
                case .characters:
                    charactersGrid
                case .locations:
                    locationsGrid
                case .timeline:
                    timelineListView
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showNewCharacterSheet) {
            NewCharacterSheet { newChar in
                store.addCharacter(newChar)
            }
        }
        .sheet(isPresented: $showNewLocationSheet) {
            NewLocationSheet { newLoc in
                store.addLocation(newLoc)
            }
        }
        .sheet(isPresented: $showNewTimelineEventSheet) {
            NewTimelineEventSheet { newEvt in
                store.addTimelineEvent(newEvt)
            }
        }
    }
    
    // MARK: - Characters Grid
    
    private var charactersGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
            ForEach(store.characters) { character in
                characterCard(character)
            }
        }
        .padding(20)
    }
    
    private func characterCard(_ char: BrewCharacter) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: char.colorHex) ?? Color.accentColor)
                    .frame(width: 14, height: 14)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(char.name)
                        .font(.system(size: 15, weight: .bold))
                    Text(char.role.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    store.deleteCharacter(id: char.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            
            if !char.tagline.isEmpty {
                Text(char.tagline)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
                    .italic()
            }
            
            Divider().opacity(0.3)
            
            VStack(alignment: .leading, spacing: 6) {
                labeledField(label: "Appearance", value: char.appearance)
                labeledField(label: "External Goal", value: char.externalGoal)
                labeledField(label: "Internal Need", value: char.internalNeed)
                labeledField(label: "Voice & Speech", value: char.voiceNotes)
            }
            
            if !char.personalityTraits.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(char.personalityTraits, id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .liquidGlassCard()
    }
    
    // MARK: - Locations Grid
    
    private var locationsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
            ForEach(store.locations) { loc in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(loc.name, systemImage: "mappin.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text(loc.category)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider().opacity(0.3)
                    
                    labeledField(label: "Atmosphere", value: loc.atmosphere)
                    labeledField(label: "Sensory Anchors", value: loc.sensoryDetails)
                    labeledField(label: "Lore & Rules", value: loc.rulesOrLore)
                    labeledField(label: "History", value: loc.historicalBackground)
                }
                .padding(16)
                .liquidGlassCard()
            }
        }
        .padding(20)
    }
    
    // MARK: - Timeline List
    
    private var timelineListView: some View {
        VStack(spacing: 12) {
            ForEach(store.timelineEvents.sorted { $0.orderIndex < $1.orderIndex }) { event in
                HStack(alignment: .top, spacing: 16) {
                    // Tension Badge
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: event.arcStage.colorHex) ?? Color.accentColor)
                            .frame(width: 12, height: 12)
                        
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 2)
                    }
                    .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(event.chapterOrAct)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.accentColor)
                            
                            Text("—")
                                .foregroundStyle(.secondary)
                            
                            Text(event.title)
                                .font(.system(size: 14, weight: .bold))
                            
                            Spacer()
                            
                            Text(event.arcStage.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: event.arcStage.colorHex)?.opacity(0.15) ?? Color.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        
                        Text(event.summary)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                        
                        HStack(spacing: 12) {
                            if !event.locationName.isEmpty {
                                Label(event.locationName, systemImage: "mappin")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !event.characterNames.isEmpty {
                                Label(event.characterNames.joined(separator: ", "), systemImage: "person.2")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("Tension: \(String(repeating: "⚡️", count: event.tensionLevel))")
                                .font(.system(size: 10))
                        }
                    }
                    .padding(14)
                    .liquidGlassCard()
                }
            }
        }
        .padding(20)
    }
    
    private func labeledField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary.opacity(0.7))
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 12))
                .lineLimit(2)
        }
    }
}

// MARK: - Color Hex Helper

extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        guard cleanHex.count == 6, let rgbValue = UInt64(cleanHex, radix: 16) else { return nil }
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

// MARK: - Creation Sheets

struct NewCharacterSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (BrewCharacter) -> Void
    
    @State private var name: String = ""
    @State private var role: CharacterRole = .protagonist
    @State private var tagline: String = ""
    @State private var appearance: String = ""
    @State private var goal: String = ""
    @State private var voiceNotes: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Storyboard Character")
                .font(.system(size: 15, weight: .bold))
            
            Form {
                TextField("Character Name", text: $name)
                Picker("Role", selection: $role) {
                    ForEach(CharacterRole.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                TextField("Tagline / Concept", text: $tagline)
                TextField("Physical Appearance", text: $appearance)
                TextField("External Goal", text: $goal)
                TextField("Voice & Mannerisms", text: $voiceNotes)
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Add Character") {
                    let char = BrewCharacter(
                        name: name.isEmpty ? "New Character" : name,
                        role: role,
                        tagline: tagline,
                        appearance: appearance,
                        externalGoal: goal,
                        voiceNotes: voiceNotes
                    )
                    onSave(char)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}

struct NewLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (BrewLocation) -> Void
    
    @State private var name: String = ""
    @State private var category: String = "Key Location"
    @State private var atmosphere: String = ""
    @State private var sensory: String = ""
    @State private var rules: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New World Location")
                .font(.system(size: 15, weight: .bold))
            
            Form {
                TextField("Location Name", text: $name)
                TextField("Category", text: $category)
                TextField("Atmosphere", text: $atmosphere)
                TextField("Sensory Details", text: $sensory)
                TextField("Rules & Lore", text: $rules)
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Add Location") {
                    let loc = BrewLocation(
                        name: name.isEmpty ? "New Location" : name,
                        category: category,
                        atmosphere: atmosphere,
                        sensoryDetails: sensory,
                        rulesOrLore: rules
                    )
                    onSave(loc)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}

struct NewTimelineEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (BrewTimelineEvent) -> Void
    
    @State private var title: String = ""
    @State private var chapter: String = "Chapter 1"
    @State private var summary: String = ""
    @State private var arcStage: NarrativeArcStage = .risingAction
    @State private var tension: Int = 3
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Timeline Event")
                .font(.system(size: 15, weight: .bold))
            
            Form {
                TextField("Event Title", text: $title)
                TextField("Chapter / Act", text: $chapter)
                TextField("Summary", text: $summary)
                Picker("Arc Stage", selection: $arcStage) {
                    ForEach(NarrativeArcStage.allCases, id: \.self) { stage in
                        Text(stage.rawValue).tag(stage)
                    }
                }
                Picker("Tension (1-5)", selection: $tension) {
                    ForEach(1...5, id: \.self) { t in
                        Text("\(t) ⚡️").tag(t)
                    }
                }
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Add Event") {
                    let evt = BrewTimelineEvent(
                        title: title.isEmpty ? "New Scene" : title,
                        chapterOrAct: chapter,
                        summary: summary,
                        tensionLevel: tension,
                        arcStage: arcStage
                    )
                    onSave(evt)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}
