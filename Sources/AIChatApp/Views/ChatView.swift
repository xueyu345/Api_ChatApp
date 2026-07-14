import SwiftUI

struct ChatView: View {
    @Environment(AppStore.self) var store
    @State private var inputText = ""
    @State private var showModelPicker = false
    @State private var scrollToBottom = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Model bar at top
            modelBar
            
            Divider()
            
            // Messages area
            messagesArea
            
            Divider()
            
            // Input area
            inputArea
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.1))
    }
    
    // MARK: - Model Bar
    private var modelBar: some View {
        HStack(spacing: 8) {
            // Model icon
            Image(systemName: store.selectedModel.provider.iconName)
                .font(.system(size: 14))
                .foregroundColor(modelColor(store.selectedModel.provider))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(store.selectedModel.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Text(store.selectedModel.provider.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if store.selectedModel.isFree {
                        Text("免费")
                            .font(.caption2)
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.cyan.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // Provider info
            Text("\(store.selectedModel.contextLength / 1000)K 上下文")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Switch model button
            Button(action: { showModelPicker = true }) {
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 12))
                    .foregroundColor(.cyan)
                Text("切换")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.cyan)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.09, green: 0.09, blue: 0.12))
        .sheet(isPresented: $showModelPicker) {
            modelPickerSheet
        }
    }
    
    // MARK: - Messages Area
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if store.messages.isEmpty {
                        welcomeView
                            .id("welcome")
                    } else {
                        ForEach(store.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if store.isStreaming {
                            StreamingBubble(content: store.streamingContent, model: store.selectedModel)
                                .id("streaming")
                        }
                    }
                }
                .padding(16)
            }
            .onChange(of: store.messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(store.messages.last?.id ?? "welcome", anchor: .bottom)
                }
            }
            .onChange(of: store.streamingContent) { _, _ in
                if store.isStreaming {
                    proxy.scrollTo("streaming", anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Welcome View
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "message.and.waveform.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("开始对话")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("当前使用 \(store.selectedModel.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if store.subscriptionPlan == .free {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.cyan)
                    Text("今日剩余 \(store.dailyMessagesRemaining) 条免费消息")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Suggested prompts
            VStack(spacing: 8) {
                ForEach(suggestedPrompts, id: \.self) { prompt in
                    Button(action: { sendPrompt(prompt) }) {
                        HStack {
                            Image(systemName: promptIcon(for: prompt))
                                .foregroundColor(.cyan)
                            Text(prompt)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: 400)
    }
    
    private var suggestedPrompts: [String] {
        [
            "帮我写一首诗",
            "解释一下量子计算",
            "写一段 Swift 代码",
            "给我一些创意灵感",
        ]
    }
    
    private func promptIcon(for prompt: String) -> String {
        switch prompt {
        case "帮我写一首诗": return "pencil.and.outline"
        case "解释一下量子计算": return "atom"
        case "写一段 Swift 代码": return "swift"
        case "给我一些创意灵感": return "lightbulb"
        default: return "bubble.magnifyingglass"
        }
    }
    
    private func sendPrompt(_ prompt: String) {
        store.sendMessage(prompt)
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        HStack(spacing: 8) {
            TextField("", text: $inputText, prompt: Text("输入消息...").foregroundColor(.gray.opacity(0.4)))
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .font(.body)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                .onSubmit { sendMessage() }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .cyan)
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || store.isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.09, green: 0.09, blue: 0.12))
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        store.sendMessage(text)
    }
    
    // MARK: - Model Picker Sheet
    private var modelPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择模型")
                    .font(.headline)
                Spacer()
                Button("完成") { showModelPicker = false }
                    .buttonStyle(.plain)
                    .foregroundColor(.cyan)
            }
            .padding()
            
            Divider()
            
            List {
                // Free models section
                Section("免费模型") {
                    ForEach(AIModel.freeModels) { model in
                        ModelRow(model: model, isSelected: store.selectedModel.id == model.id)
                            .onTapGesture {
                                store.selectedModel = model
                                showModelPicker = false
                            }
                    }
                }
                
                // Premium models section
                Section("需要 API Key") {
                    ForEach(AIModel.premiumModels) { model in
                        ModelRow(model: model, isSelected: store.selectedModel.id == model.id)
                            .onTapGesture {
                                if store.hasValidApiKey(for: model.provider) {
                                    store.selectedModel = model
                                    showModelPicker = false
                                } else {
                                    // Show settings to add API key
                                    showModelPicker = false
                                }
                            }
                    }
                }
            }
            .listStyle(.inset)
        }
        .frame(width: 360, height: 480)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user {
                Spacer()
            } else {
                // Avatar
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.cyan)
                    .padding(8)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.role == .user ? .white : Color(red: 0.9, green: 0.9, blue: 0.95))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user
                            ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : Color(red: 0.15, green: 0.15, blue: 0.2)
                    )
                    .cornerRadius(16)
                
                if let modelId = message.modelId {
                    Text(modelId)
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 4)
                }
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

// MARK: - Streaming Bubble
struct StreamingBubble: View {
    let content: String
    let model: AIModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 16))
                .foregroundColor(.cyan)
                .padding(8)
                .background(Color.cyan.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(content.isEmpty ? "思考中" : content)
                        .font(.body)
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.95))
                    if !content.isEmpty {
                        Text("▊")
                            .font(.body)
                            .foregroundColor(.cyan)
                            .opacity(0.8)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                .cornerRadius(16)
                
                if content.isEmpty {
                    HStack(spacing: 6) {
                        DotView(delay: 0)
                        DotView(delay: 0.2)
                        DotView(delay: 0.4)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
            }
            
            Spacer()
        }
    }
}

struct DotView: View {
    let delay: Double
    @State private var show = false
    
    var body: some View {
        Circle()
            .fill(Color.cyan)
            .frame(width: 6, height: 6)
            .opacity(show ? 1 : 0.2)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever().delay(delay)) {
                    show.toggle()
                }
            }
    }
}

// MARK: - Model Row
struct ModelRow: View {
    let model: AIModel
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: model.provider.iconName)
                .font(.title2)
                .foregroundColor(modelColor(model.provider))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(model.name)
                    .font(.body.weight(.medium))
                Text(model.provider.rawValue + " · \(model.contextLength / 1000)K 上下文")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.cyan)
            }
            
            if model.isFree {
                Text("免费")
                    .font(.caption2)
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cyan.opacity(0.15))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helper
func modelColor(_ provider: AIProvider) -> Color {
    switch provider {
    case .deepseek: return .blue
    case .openAI: return .green
    case .anthropic: return .orange
    case .google: return .red
    case .mistral: return .purple
    case .local: return .gray
    }
}
