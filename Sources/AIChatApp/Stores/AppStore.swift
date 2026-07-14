import Foundation
import Observation

@Observable
final class AppStore {
    
    // MARK: - Registration
    var isRegistered: Bool = false
    var selectedCountry: CountryCode = CountryCode.all[0]
    var phoneNumber: String = ""
    var verificationCode: String = ""
    var sentCode: Bool = false
    var isVerifying: Bool = false
    
    // MARK: - Subscription
    var subscriptionPlan: SubscriptionPlan = .free
    var messagesUsed: Int = 0
    var lastResetDate: Date = Date()
    
    var dailyMessagesRemaining: Int {
        if Calendar.current.isDateInToday(lastResetDate) {
            return subscriptionPlan.dailyMessageLimit - messagesUsed
        } else {
            return subscriptionPlan.dailyMessageLimit
        }
    }
    
    // MARK: - API Keys
    var apiKeys: [AIProvider: String] = [:]
    
    func hasValidApiKey(for provider: AIProvider) -> Bool {
        guard let key = apiKeys[provider] else { return false }
        return !key.isEmpty
    }
    
    // MARK: - Chat
    var messages: [ChatMessage] = []
    var selectedModel: AIModel = AIModel.freeModels[0]
    var isStreaming: Bool = false
    var streamingContent: String = ""
    
    // MARK: - Conversation
    var conversations: [Conversation] = []
    var selectedConversationId: UUID?
    
    var currentConversation: Conversation? {
        conversations.first { $0.id == selectedConversationId }
    }
    
    // MARK: - Sidebar
    var isSidebarVisible: Bool = true
    
    // MARK: - Persistence
    private let defaults = UserDefaults.standard
    private let registrationKey = "isRegistered"
    private let phoneKey = "phoneNumber"
    private let countryKey = "selectedCountry"
    private let apiKeysKey = "apiKeys"
    private let messagesKey = "savedMessages"
    private let conversationsKey = "savedConversations"
    private let messagesUsedKey = "messagesUsed"
    private let lastResetKey = "lastResetDate"
    private let subscriptionKey = "subscriptionPlan"
    
    init() {
        loadState()
    }
    
    // MARK: - Registration
    func sendVerificationCode() {
        guard !phoneNumber.isEmpty else { return }
        sentCode = true
        // In a real app, send SMS here
    }
    
    func verifyCode() {
        guard !verificationCode.isEmpty else { return }
        isVerifying = true
        // Simulate verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isRegistered = true
            self.isVerifying = false
            self.saveState()
        }
    }
    
    func completeRegistration() {
        isRegistered = true
        saveState()
    }
    
    // MARK: - Chat
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: content, modelId: selectedModel.id)
        messages.append(userMessage)
        
        // Update conversation
        if let convId = selectedConversationId {
            if var conv = conversations.first(where: { $0.id == convId }) {
                conv.lastMessage = content
                conv.timestamp = Date()
                conversations.removeAll { $0.id == convId }
                conversations.insert(conv, at: 0)
            }
        }
        
        // Track daily usage
        if Calendar.current.isDateInToday(lastResetDate) {
            messagesUsed += 1
        } else {
            messagesUsed = 1
            lastResetDate = Date()
        }
        saveState()
        
        // Free tier check
        if subscriptionPlan == .free && messagesUsed > subscriptionPlan.dailyMessageLimit {
            let limitMessage = ChatMessage(
                role: .assistant,
                content: "今日免费额度已用完（\(subscriptionPlan.dailyMessageLimit)条）。升级到 Pro 或添加 API Key 以继续对话。",
                modelId: selectedModel.id
            )
            messages.append(limitMessage)
            return
        }
        
        // Check API key for non-free models
        if !selectedModel.isFree {
            if !hasValidApiKey(for: selectedModel.provider) {
                let keyMessage = ChatMessage(
                    role: .assistant,
                    content: "请在设置中添加 \(selectedModel.provider.rawValue) 的 API Key 以使用此模型。",
                    modelId: selectedModel.id
                )
                messages.append(keyMessage)
                return
            }
        }
        
        // Simulate response
        isStreaming = true
        streamingContent = ""
        
        let model = selectedModel
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            let responses: [String: String] = [
                "deepseek-chat": "这是 DeepSeek V3 的回复。我可以帮你回答问题、编写代码、分析数据等等。请问还有什么需要帮助的吗？",
                "deepseek-reasoner": "让我仔细思考一下这个问题...\n\n经过推理分析，我的回答如下：\n\n这是一个很好的问题。DeepSeek R1 擅长处理需要深度推理的任务。如果你有更具体的问题，欢迎继续提问！",
                "gpt-4o": "Hello! I'm GPT-4o. I can help with a wide range of tasks in multiple languages. How can I assist you today?",
                "claude-3-5-sonnet": "你好！我是 Claude 3.5 Sonnet。我很乐意帮你处理各种任务，从编程到创意写作都可以。请告诉我你的需求！",
                "gemini-2.0-flash": "Hey there! Gemini 2.0 Flash here. I'm fast and efficient for quick tasks and questions. What's on your mind?",
            ]
            
            let response = responses[model.id] ?? "收到你的消息了！我是一个 AI 助手，很高兴为你服务。"
            self.streamingContent = response
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else { return }
                let assistantMessage = ChatMessage(role: .assistant, content: response, modelId: model.id)
                self.messages.append(assistantMessage)
                self.isStreaming = false
                self.streamingContent = ""
            }
        }
    }
    
    // MARK: - Conversations
    func createNewConversation() {
        let conv = Conversation(title: "新对话", lastMessage: "", modelId: selectedModel.id)
        conversations.insert(conv, at: 0)
        selectedConversationId = conv.id
        messages = []
        saveState()
    }
    
    func selectConversation(_ id: UUID) {
        selectedConversationId = id
        // In a real app, load messages for this conversation
        // For now, clear messages when selecting a different conversation
        messages = []
    }
    
    func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        if selectedConversationId == id {
            selectedConversationId = conversations.first?.id
            messages = []
        }
        saveState()
    }
    
    // MARK: - Persistence
    func saveState() {
        defaults.set(isRegistered, forKey: registrationKey)
        defaults.set(phoneNumber, forKey: phoneKey)
        defaults.set(selectedCountry.id, forKey: countryKey)
        
        let keyData = try? JSONEncoder().encode(apiKeys.mapValues { $0 })
        defaults.set(keyData, forKey: apiKeysKey)
        
        if let convData = try? JSONEncoder().encode(conversations) {
            defaults.set(convData, forKey: conversationsKey)
        }
        
        defaults.set(messagesUsed, forKey: messagesUsedKey)
        defaults.set(lastResetDate, forKey: lastResetKey)
        defaults.set(subscriptionPlan.rawValue, forKey: subscriptionKey)
    }
    
    private func loadState() {
        isRegistered = defaults.bool(forKey: registrationKey)
        phoneNumber = defaults.string(forKey: phoneKey) ?? ""
        
        if let countryId = defaults.string(forKey: countryKey) {
            selectedCountry = CountryCode.all.first { $0.id == countryId } ?? CountryCode.all[0]
        }
        
        if let keyData = defaults.data(forKey: apiKeysKey),
           let keys = try? JSONDecoder().decode([String: String].self, from: keyData) {
            apiKeys = Dictionary(uniqueKeysWithValues: keys.compactMap { key, value in
                guard let provider = AIProvider(rawValue: key) else { return nil }
                return (provider, value)
            })
        }
        
        if let convData = defaults.data(forKey: conversationsKey),
           let convs = try? JSONDecoder().decode([Conversation].self, from: convData) {
            conversations = convs
            selectedConversationId = conversations.first?.id
        }
        
        messagesUsed = defaults.integer(forKey: messagesUsedKey)
        lastResetDate = defaults.object(forKey: lastResetKey) as? Date ?? Date()
        
        if let planRaw = defaults.string(forKey: subscriptionKey),
           let plan = SubscriptionPlan(rawValue: planRaw) {
            subscriptionPlan = plan
        }
    }
    
    func resetDailyUsage() {
        messagesUsed = 0
        lastResetDate = Date()
        saveState()
    }
}

// MARK: - Conversation
struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var lastMessage: String
    var timestamp: Date
    var modelId: String
    
    init(id: UUID = UUID(), title: String, lastMessage: String = "", modelId: String = "") {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = Date()
        self.modelId = modelId
    }
}
