import SwiftUI
import AppKit

@main
struct AIChatApp: App {
    @State private var store = AppStore()
    
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environment(store)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Ensure the app comes to the foreground
                    NSApp.setActivationPolicy(.regular)
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新对话") {
                    store.createNewConversation()
                }
                .keyboardShortcut("n")
            }
            
            CommandMenu("模型") {
                ForEach(AIModel.freeModels) { model in
                    Button(model.name) {
                        store.selectedModel = model
                    }
                }
                Divider()
                ForEach(AIModel.premiumModels) { model in
                    Button(model.name) {
                        if store.hasValidApiKey(for: model.provider) {
                            store.selectedModel = model
                        }
                    }
                }
            }
        }
    }
}
