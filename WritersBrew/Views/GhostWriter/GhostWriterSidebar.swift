import SwiftUI

public struct GhostWriterSidebar: View {
    @Binding var document: BrewDocument
    var activeStyle: StyleProfile
    var characters: [BrewCharacter]
    var locations: [BrewLocation]
    
    @State private var messages: [ChatMessage] = []
    @State private var inputPrompt: String = ""
    @State private var isStreaming: Bool = false
    @State private var currentStreamResponse: String = ""
    @State private var showBlockBreakerSheet: Bool = false
    @State private var showRewriteMenu: Bool = false
    
    private var aiService = AIService.shared
    private var voiceEngine = VoiceLearningEngine.shared
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar
            
            Divider()
                .opacity(0.3)
            
            // Quick Creative Block Breaker Tools Bar
            creativeActionsBar
            
            Divider()
                .opacity(0.2)
            
            // Chat Conversation List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if messages.isEmpty && currentStreamResponse.isEmpty {
                            emptyStateView
                        }
                        
                        ForEach(messages) { message in
                            chatBubble(for: message)
                        }
                        
                        if !currentStreamResponse.isEmpty {
                            streamingBubbleView
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastId = messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            
            Divider()
                .opacity(0.3)
            
            // Input Area
            inputArea
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showBlockBreakerSheet) {
            BlockBreakerSheet(
                documentContext: document.content,
                style: activeStyle,
                voice: voiceEngine.currentVoiceSkill,
                characters: characters,
                onInsertProse: { prose in
                    insertProseIntoDocument(prose)
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    private var headerBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 14, weight: .bold))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Ghost Writer")
                    .font(.system(size: 13, weight: .semibold))
                
                Text(PreferencesStore.shared.activeProvider.rawValue)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if !messages.isEmpty {
                Button {
                    withAnimation {
                        messages.removeAll()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Clear Chat History")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var creativeActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Writer's block button
                Button {
                    showBlockBreakerSheet = true
                } label: {
                    Label("Break Block", systemImage: "bolt.fill")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                // Continue button
                Button {
                    triggerContinue()
                } label: {
                    Label("Continue", systemImage: "arrow.forward")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                // Expand Sensory button
                Button {
                    triggerExpand()
                } label: {
                    Label("Expand Sensory", systemImage: "eye.fill")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.accentColor.opacity(0.6))
                .padding(.top, 30)
            
            Text("Your Creative Partner")
                .font(.system(size: 14, weight: .semibold))
            
            Text("Ask anything about your draft, brainstorm alternate twists, or prompt Ghost Writer to expand sensory depth.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }
    
    private func chatBubble(for message: ChatMessage) -> some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            HStack {
                if message.role == .user { Spacer() }
                
                Text(message.content)
                    .font(.system(size: 12.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.role == .user
                            ? Color.accentColor.opacity(0.25)
                            : Color.primary.opacity(0.06)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                message.role == .user ? Color.accentColor.opacity(0.4) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    }
                
                if message.role != .user { Spacer() }
            }
            
            // Action buttons on assistant response
            if message.role == .assistant {
                HStack(spacing: 8) {
                    Button("Insert into Document") {
                        insertProseIntoDocument(message.content)
                    }
                    .font(.system(size: 10, weight: .medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.content, forType: .string)
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
            }
        }
    }
    
    private var streamingBubbleView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(currentStreamResponse)
                .font(.system(size: 12.5))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Crafting...")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 8) {
            TextField("Ask Ghost Writer...", text: $inputPrompt, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 12.5))
                .lineLimit(1...4)
                .onSubmit {
                    sendMessage()
                }
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(inputPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary.opacity(0.4) : Color.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(inputPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isStreaming)
        }
        .padding(12)
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let trimmed = inputPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        inputPrompt = ""
        isStreaming = true
        currentStreamResponse = ""
        
        Task {
            let stream = aiService.streamChat(
                messages: messages,
                documentContext: document.content,
                style: activeStyle,
                voice: voiceEngine.currentVoiceSkill,
                characters: characters,
                locations: locations
            )
            
            do {
                for try await token in stream {
                    await MainActor.run {
                        self.currentStreamResponse += token
                    }
                }
                await MainActor.run {
                    let assistantMessage = ChatMessage(role: .assistant, content: self.currentStreamResponse)
                    self.messages.append(assistantMessage)
                    self.currentStreamResponse = ""
                    self.isStreaming = false
                }
            } catch {
                await MainActor.run {
                    self.messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
                    self.currentStreamResponse = ""
                    self.isStreaming = false
                }
            }
        }
    }
    
    private func triggerContinue() {
        isStreaming = true
        currentStreamResponse = ""
        
        Task {
            do {
                let prose = try await aiService.continueFromCursor(
                    precedingText: document.content,
                    style: activeStyle,
                    voice: voiceEngine.currentVoiceSkill
                )
                await MainActor.run {
                    self.messages.append(ChatMessage(role: .user, content: "Continue the scene from the cursor."))
                    self.messages.append(ChatMessage(role: .assistant, content: prose))
                    self.isStreaming = false
                }
            } catch {
                await MainActor.run {
                    self.messages.append(ChatMessage(role: .assistant, content: "Error continuing scene: \(error.localizedDescription)"))
                    self.isStreaming = false
                }
            }
        }
    }
    
    private func triggerExpand() {
        isStreaming = true
        currentStreamResponse = ""
        
        Task {
            do {
                let prose = try await aiService.expandSensory(
                    sceneText: document.content,
                    style: activeStyle,
                    voice: voiceEngine.currentVoiceSkill,
                    locations: locations
                )
                await MainActor.run {
                    self.messages.append(ChatMessage(role: .user, content: "Expand sensory details in this moment."))
                    self.messages.append(ChatMessage(role: .assistant, content: prose))
                    self.isStreaming = false
                }
            } catch {
                await MainActor.run {
                    self.messages.append(ChatMessage(role: .assistant, content: "Error expanding: \(error.localizedDescription)"))
                    self.isStreaming = false
                }
            }
        }
    }
    
    private func insertProseIntoDocument(_ prose: String) {
        withAnimation {
            if !document.content.hasSuffix("\n\n") && !document.content.isEmpty {
                document.content += "\n\n"
            }
            document.content += prose
            voiceEngine.recordAcceptedSuggestion(text: prose)
        }
    }
}
