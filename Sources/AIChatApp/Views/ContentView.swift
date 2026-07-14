import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) var store
    
    var body: some View {
        if store.isRegistered {
            MainView()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            RegistrationView()
                .transition(.opacity)
        }
    }
}

struct MainView: View {
    @Environment(AppStore.self) var store
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            ChatView()
        }
        .navigationSplitViewStyle(.balanced)
    }
}
