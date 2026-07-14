import Foundation

final class AIService {
    
    static let shared = AIService()
    private init() {}
    
    enum AIError: Error, LocalizedError {
        case noApiKey
        case networkError(String)
        case rateLimited
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .noApiKey: return "未设置 API Key"
            case .networkError(let detail): return "网络错误: \(detail)"
            case .rateLimited: return "请求过于频繁，请稍后重试"
            case .invalidResponse: return "无效的响应"
            }
        }
    }
    
    func sendMessage(content: String, model: AIModel, apiKey: String) async throws -> String {
        let url: URL
        var headers: [String: String] = [:]
        var body: [String: Any] = [:]
        
        switch model.provider {
        case .deepseek:
            url = URL(string: "https://api.deepseek.com/chat/completions")!
            headers = [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
            body = [
                "model": model.id,
                "messages": [["role": "user", "content": content]]
            ]
            
        case .openAI:
            url = URL(string: "https://api.openai.com/v1/chat/completions")!
            headers = [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
            body = [
                "model": model.id,
                "messages": [["role": "user", "content": content]]
            ]
            
        case .anthropic:
            url = URL(string: "https://api.anthropic.com/v1/messages")!
            headers = [
                "x-api-key": apiKey,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json"
            ]
            body = [
                "model": model.id,
                "messages": [["role": "user", "content": content]],
                "max_tokens": 4096
            ]
            
        case .google:
            url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model.id):generateContent?key=\(apiKey)")!
            headers = ["Content-Type": "application/json"]
            body = ["contents": [["parts": [["text": content]]]]]
            
        case .mistral:
            url = URL(string: "https://api.mistral.ai/v1/chat/completions")!
            headers = [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
            body = [
                "model": model.id,
                "messages": [["role": "user", "content": content]]
            ]
            
        case .local:
            throw AIError.networkError("本地模型暂未支持")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw AIError.rateLimited
            }
            throw AIError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        // Parse response based on provider
        return parseResponse(data: data, provider: model.provider)
    }
    
    private func parseResponse(data: Data, provider: AIProvider) -> String {
        switch provider {
        case .anthropic:
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let first = content.first,
               let text = first["text"] as? String {
                return text
            }
        case .google:
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let first = candidates.first,
               let content = first["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text
            }
        default:
            // OpenAI-style response (DeepSeek, OpenAI, Mistral)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let message = first["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        }
        return "抱歉，无法解析响应。"
    }
}
