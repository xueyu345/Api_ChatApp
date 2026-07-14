import SwiftUI

struct SidebarView: View {
    @Environment(AppStore.self) var store
    @State private var showSettings = false
    @State private var animateList = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with traffic light spacing (native macOS handles this)
            HStack {
                Image(systemName: "message.and.waveform.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("AI Chat")
                    .font(.headline.weight(.bold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Conversations list
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    // New conversation button
                    Button(action: { store.createNewConversation() }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.cyan)
                                .font(.title3)
                            Text("新对话")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Text("对话记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                    
                    if store.conversations.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("暂无对话")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.5))
                            Text("点击上方按钮开始新对话")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        ForEach(store.conversations) { conversation in
                            ConversationRow(conversation: conversation)
                                .onTapGesture {
                                    store.selectConversation(conversation.id)
                                }
                                .contextMenu {
                                    Button("删除对话", role: .destructive) {
                                        store.deleteConversation(conversation.id)
                                    }
                                }
                        }
                    }
                }
            }
            
            Divider()
            
            // Bottom section: Model management and settings
            VStack(spacing: 0) {
                // Plan info
                HStack {
                    Image(systemName: store.subscriptionPlan == .free ? "gift" : "crown.fill")
                        .foregroundColor(store.subscriptionPlan == .free ? .orange : .yellow)
                    Text(store.subscriptionPlan.rawValue + " 版")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(store.dailyMessagesRemaining)条/日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.cyan.opacity(0.05))
                
                Divider()
                
                // Upgrade button (only for free)
                if store.subscriptionPlan == .free {
                    Button(action: { showSettings = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.blue)
                            Text("升级到 Pro")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("¥29/月")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                }
                
                // Settings button
                Button(action: { showSettings = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .foregroundColor(.secondary)
                        Text("设置")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 220, idealWidth: 260)
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                animateList = true
            }
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(conversation.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .foregroundColor(.white)
            
            if !conversation.lastMessage.isEmpty {
                Text(conversation.lastMessage)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .padding(.horizontal, 4)
    }
}
