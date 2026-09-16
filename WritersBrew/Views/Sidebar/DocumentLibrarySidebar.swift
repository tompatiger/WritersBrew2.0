import SwiftUI

public struct DocumentLibrarySidebar: View {
    @State private var store = DocumentStore.shared
    @Binding var selectedTab: MainSidebarTab
    
    @State private var showNewChapterSheet: Bool = false
    @State private var showNewProjectSheet: Bool = false
    @State private var targetProjectForChapter: BrewProject? = nil
    
    private var prefs = PreferencesStore.shared
    
    public enum MainSidebarTab: Hashable {
        case library
        case storyboard
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Mode Switcher (Manuscripts vs Storyboard)
            Picker("Mode", selection: $selectedTab) {
                Label("Manuscript", systemImage: "doc.text.fill").tag(MainSidebarTab.library)
                Label("Storyboard", systemImage: "sparkles.rectangle.stack.fill").tag(MainSidebarTab.storyboard)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Quick Creation Action Bar
            HStack(spacing: 8) {
                // New Chapter Button
                Button {
                    targetProjectForChapter = store.projects.first
                    _ = store.createChapter(inProject: targetProjectForChapter)
                    selectedTab = .library
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 11))
                        Text("New Chapter")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.18))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .help("Create a new chapter in the current project (⌘N)")
                
                // New Project Button
                Menu {
                    Button("New Manuscript / Essay") {
                        _ = store.createDocument()
                    }
                    Button("New Book Project...") {
                        showNewProjectSheet = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            Divider().opacity(0.3)
            
            if selectedTab == .library {
                libraryView
            } else {
                storyboardQuickSidebar
            }
        }
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet { title, synopsis, emoji in
                let project = store.createProject(title: title, synopsis: synopsis, emoji: emoji)
                _ = store.createChapter(title: "Chapter 1", inProject: project)
            }
        }
    }
    
    // MARK: - Library View
    
    private var libraryView: some View {
        List(selection: $store.selectedDocumentId) {
            // Smart Collections
            Section("Collections") {
                NavigationLink(value: DocumentStore.SidebarFilter.allDocuments) {
                    Label("All Documents", systemImage: "tray.full.fill")
                }
                .tag(DocumentStore.SidebarFilter.allDocuments)
                
                NavigationLink(value: DocumentStore.SidebarFilter.favorites) {
                    Label("Starred", systemImage: "star.fill")
                }
                .tag(DocumentStore.SidebarFilter.favorites)
                
                NavigationLink(value: DocumentStore.SidebarFilter.pinned) {
                    Label("Pinned Drafts", systemImage: "pin.fill")
                }
                .tag(DocumentStore.SidebarFilter.pinned)
            }
            
            // Projects & Chapters
            ForEach(store.projects) { project in
                Section {
                    let projectChapters = store.chapters(for: project)
                    
                    if projectChapters.isEmpty {
                        Text("No chapters yet")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(projectChapters) { chapter in
                            chapterRow(chapter)
                                .tag(chapter.id)
                        }
                    }
                } header: {
                    HStack {
                        Text("\(project.emoji) \(project.title)")
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button {
                            _ = store.createChapter(inProject: project)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help("Add chapter to \(project.title)")
                    }
                }
            }
            
            // Standalone Documents
            let standaloneDocs = store.filteredDocuments.filter { $0.projectId == nil }
            if !standaloneDocs.isEmpty {
                Section("Standalone Drafts") {
                    ForEach(standaloneDocs) { doc in
                        documentRow(doc)
                            .tag(doc.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $store.searchText, prompt: "Search manuscripts, scenes, tags...")
    }
    
    private func chapterRow(_ doc: BrewDocument) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                if let num = doc.chapterNumber {
                    Text("Ch.\(num)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Text(doc.title.isEmpty ? "Untitled Chapter" : doc.title)
                    .font(.system(size: 12.5, weight: doc.isPinned ? .semibold : .regular))
                    .lineLimit(1)
                
                Spacer()
                
                if doc.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.yellow)
                }
            }
            
            HStack(spacing: 6) {
                Text("\(doc.wordCount) words")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary.opacity(0.4))
                
                Text(doc.updatedAt.formatted(.relative(presentation: .named)))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            Button {
                store.togglePinned(for: doc)
            } label: {
                Label(doc.isPinned ? "Unpin Chapter" : "Pin Chapter", systemImage: "pin")
            }
            
            Button {
                store.toggleFavorite(for: doc)
            } label: {
                Label(doc.isFavorite ? "Unstar" : "Star", systemImage: "star")
            }
            
            Divider()
            
            Button(role: .destructive) {
                store.deleteDocument(doc)
            } label: {
                Label("Delete Chapter", systemImage: "trash")
            }
        }
    }
    
    private func documentRow(_ doc: BrewDocument) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                if doc.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.accentColor)
                }
                
                Text(doc.title.isEmpty ? "Untitled" : doc.title)
                    .font(.system(size: 13, weight: doc.isPinned ? .semibold : .regular))
                    .lineLimit(1)
                
                Spacer()
                
                if doc.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                }
            }
            
            HStack(spacing: 8) {
                Text("\(doc.wordCount) words")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary.opacity(0.4))
                
                Text(doc.updatedAt.formatted(.relative(presentation: .named)))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
        .contextMenu {
            Button {
                store.togglePinned(for: doc)
            } label: {
                Label(doc.isPinned ? "Unpin Draft" : "Pin Draft", systemImage: "pin")
            }
            
            Button {
                store.toggleFavorite(for: doc)
            } label: {
                Label(doc.isFavorite ? "Unstar" : "Star", systemImage: "star")
            }
            
            Divider()
            
            Button(role: .destructive) {
                store.deleteDocument(doc)
            } label: {
                Label("Delete Draft", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Storyboard Quick Sidebar
    
    private var storyboardQuickSidebar: some View {
        List {
            Section("Characters (\(store.characters.count))") {
                ForEach(store.characters) { char in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: char.colorHex) ?? Color.accentColor)
                            .frame(width: 8, height: 8)
                        Text(char.name)
                            .font(.system(size: 12.5))
                        Spacer()
                        Text(char.role.rawValue)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("World & Locations (\(store.locations.count))") {
                ForEach(store.locations) { loc in
                    HStack(spacing: 8) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.accentColor)
                        Text(loc.name)
                            .font(.system(size: 12.5))
                    }
                }
            }
            
            Section("Timeline Scenes (\(store.timelineEvents.count))") {
                ForEach(store.timelineEvents) { evt in
                    HStack(spacing: 8) {
                        Text(evt.chapterOrAct)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text(evt.title)
                            .font(.system(size: 12.5))
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - New Project Sheet

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String, String, String) -> Void
    
    @State private var title: String = ""
    @State private var synopsis: String = ""
    @State private var emoji: String = "📖"
    
    let emojiOptions = ["📖", "✨", "🚀", "🗡️", "🕵️", "🌙", "🌊", "📜", "🪐"]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create Book / Manuscript Project")
                .font(.system(size: 15, weight: .bold))
            
            Form {
                HStack {
                    Text("Icon:")
                    Picker("", selection: $emoji) {
                        ForEach(emojiOptions, id: \.self) { e in
                            Text(e).tag(e)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                TextField("Project Title", text: $title)
                TextField("Synopsis / Premise", text: $synopsis)
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Create Project") {
                    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    onSave(title, synopsis, emoji)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}
