import SwiftUI

enum Tab {
    case home
    case newSession
    case profile
}

struct MainTabView: View {
    @StateObject var sessionStore = WorkoutSessionStore()
    @StateObject var appState = AppState()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // Home Tab
            HomeView(sessionStore: sessionStore, selectedTab: $appState.selectedTab)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(Tab.home)

            // New Session Tab
            ContentView(sessionStore: sessionStore)
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("New Session")
                }
                .tag(Tab.newSession)

            // Profile Tab (Optional)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .environmentObject(appState) // Inject AppState into the environment
    }
}
