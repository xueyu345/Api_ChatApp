import Foundation

// MARK: - AI Provider
enum AIProvider: String, Codable, CaseIterable, Identifiable {
    case deepseek = "DeepSeek"
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case mistral = "Mistral"
    case local = "Local"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .deepseek: return "d.circle.fill"
        case .openAI: return "sparkles"
        case .anthropic: return "a.circle.fill"
        case .google: return "g.circle.fill"
        case .mistral: return "m.circle.fill"
        case .local: return "laptopcomputer"
        }
    }
    
    var color: String {
        switch self {
        case .deepseek: return "blue"
        case .openAI: return "green"
        case .anthropic: return "orange"
        case .google: return "red"
        case .mistral: return "purple"
        case .local: return "gray"
        }
    }
}

// MARK: - AI Model
struct AIModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let provider: AIProvider
    let isFree: Bool
    let description: String
    let contextLength: Int
    
    static let freeModels: [AIModel] = [
        AIModel(id: "deepseek-chat", name: "DeepSeek V3", provider: .deepseek, isFree: true, description: "免费对话额度", contextLength: 64000),
        AIModel(id: "deepseek-reasoner", name: "DeepSeek R1", provider: .deepseek, isFree: true, description: "免费推理模型", contextLength: 64000),
    ]
    
    static let premiumModels: [AIModel] = [
        AIModel(id: "gpt-4o", name: "GPT-4o", provider: .openAI, isFree: false, description: "需要 API Key", contextLength: 128000),
        AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini", provider: .openAI, isFree: false, description: "需要 API Key", contextLength: 128000),
        AIModel(id: "claude-3-5-sonnet", name: "Claude 3.5 Sonnet", provider: .anthropic, isFree: false, description: "需要 API Key", contextLength: 200000),
        AIModel(id: "claude-3-5-haiku", name: "Claude 3.5 Haiku", provider: .anthropic, isFree: false, description: "需要 API Key", contextLength: 200000),
        AIModel(id: "gemini-2.0-flash", name: "Gemini 2.0 Flash", provider: .google, isFree: false, description: "需要 API Key", contextLength: 1000000),
        AIModel(id: "gemini-2.0-pro", name: "Gemini 2.0 Pro", provider: .google, isFree: false, description: "需要 API Key", contextLength: 1000000),
        AIModel(id: "mistral-large", name: "Mistral Large", provider: .mistral, isFree: false, description: "需要 API Key", contextLength: 128000),
    ]
    
    static var all: [AIModel] { freeModels + premiumModels }
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    let modelId: String?
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date(), modelId: String? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.modelId = modelId
    }
    
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
}

// MARK: - Subscription Plan
enum SubscriptionPlan: String, Codable, CaseIterable {
    case free = "免费"
    case pro = "Pro"
    
    var dailyMessageLimit: Int {
        switch self {
        case .free: return 10
        case .pro: return 9999
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .free: return "免费"
        case .pro: return "¥29/月"
        }
    }
}
