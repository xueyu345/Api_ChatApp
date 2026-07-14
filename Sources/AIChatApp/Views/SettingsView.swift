import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppStore.self) var store
    
    @State private var deepseekKey: String = ""
    @State private var openAIKey: String = ""
    @State private var anthropicKey: String = ""
    @State private var googleKey: String = ""
    @State private var mistralKey: String = ""
    @State private var showProFeatures = false
    @State private var saveFeedback = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.cyan)
                    Text("设置")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("完成") {
                        saveKeys()
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.cyan)
                    .fontWeight(.semibold)
                }
                
                Divider()
                
                // Account section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                            VStack(alignment: .leading) {
                                Text("账号信息")
                                    .font(.headline)
                                if !store.phoneNumber.isEmpty {
                                    Text("\(store.selectedCountry.flag) \(store.selectedCountry.code) \(store.phoneNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        HStack {
                            Text("当前套餐")
                                .font(.subheadline)
                            Spacer()
                            Text(store.subscriptionPlan.rawValue + " 版")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(store.subscriptionPlan == .free ? .orange : .yellow)
                        }
                        
                        HStack {
                            Text("今日消息数")
                                .font(.subheadline)
                            Spacer()
                            Text("\(store.messagesUsed) / \(store.subscriptionPlan.dailyMessageLimit)")
                                .font(.subheadline)
                                .foregroundColor(store.dailyMessagesRemaining > 0 ? .secondary : .red)
                        }
                    }
                    .padding(12)
                }
                .groupBoxStyle(DarkGroupBoxStyle())
                
                // Upgrade section
                if store.subscriptionPlan == .free {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading) {
                                    Text("升级到 Pro")
                                        .font(.headline)
                                    Text("解锁所有功能，无限制对话")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                                .background(.gray.opacity(0.3))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ProFeatureRow(icon: "infinity", text: "无限消息量", color: .blue)
                                ProFeatureRow(icon: "globe", text: "所有模型", color: .green)
                                ProFeatureRow(icon: "key.fill", text: "无需 API Key", color: .orange)
                                ProFeatureRow(icon: "bolt.fill", text: "优先响应", color: .purple)
                            }
                            
                            Button(action: {
                                store.subscriptionPlan = .pro
                                store.saveState()
                                withAnimation { saveFeedback = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    saveFeedback = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                    Text("立即升级 - ¥29/月")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                    }
                    .groupBoxStyle(DarkGroupBoxStyle())
                }
                
                // API Keys section
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "key.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                            VStack(alignment: .leading) {
                                Text("API Keys")
                                    .font(.headline)
                                Text("配置各模型的 API Key 以使用高级功能")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                            .background(.gray.opacity(0.3))
                        
                        ApiKeyField(
                            provider: .deepseek,
                            placeholder: "sk-...",
                            key: $deepseekKey
                        )
                        
                        ApiKeyField(
                            provider: .openAI,
                            placeholder: "sk-...",
                            key: $openAIKey
                        )
                        
                        ApiKeyField(
                            provider: .anthropic,
                            placeholder: "sk-ant-...",
                            key: $anthropicKey
                        )
                        
                        ApiKeyField(
                            provider: .google,
                            placeholder: "AIza...",
                            key: $googleKey
                        )
                        
                        ApiKeyField(
                            provider: .mistral,
                            placeholder: "Enter Mistral API Key",
                            key: $mistralKey
                        )
                        
                        if saveFeedback {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("已保存")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(12)
                }
                .groupBoxStyle(DarkGroupBoxStyle())
                
                // About
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("关于")
                            .font(.headline)
                        HStack {
                            Text("版本")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                        }
                    }
                    .padding(12)
                }
                .groupBoxStyle(DarkGroupBoxStyle())
            }
            .padding(20)
        }
        .frame(width: 460, height: 580)
        .background(Color(red: 0.06, green: 0.06, blue: 0.09))
        .onAppear {
            loadKeys()
        }
    }
    
    private func loadKeys() {
        deepseekKey = store.apiKeys[.deepseek] ?? ""
        openAIKey = store.apiKeys[.openAI] ?? ""
        anthropicKey = store.apiKeys[.anthropic] ?? ""
        googleKey = store.apiKeys[.google] ?? ""
        mistralKey = store.apiKeys[.mistral] ?? ""
    }
    
    private func saveKeys() {
        store.apiKeys[.deepseek] = deepseekKey
        store.apiKeys[.openAI] = openAIKey
        store.apiKeys[.anthropic] = anthropicKey
        store.apiKeys[.google] = googleKey
        store.apiKeys[.mistral] = mistralKey
        store.saveState()
        withAnimation { saveFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { saveFeedback = false }
        }
    }
}

// MARK: - API Key Field
struct ApiKeyField: View {
    let provider: AIProvider
    let placeholder: String
    @Binding var key: String
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: provider.iconName)
                    .foregroundColor(modelColor(provider))
                Text(provider.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            
            HStack {
                if isVisible {
                    TextField("", text: $key, prompt: Text(placeholder).foregroundColor(.gray.opacity(0.4)))
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .font(.body.monospaced())
                } else {
                    SecureField("", text: $key, prompt: Text(placeholder).foregroundColor(.gray.opacity(0.4)))
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .font(.body.monospaced())
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.06))
            .cornerRadius(8)
        }
    }
}

// MARK: - Pro Feature Row
struct ProFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Dark GroupBox Style
struct DarkGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.content
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
