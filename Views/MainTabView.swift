import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MyLanguagesView()
                .tabItem {
                    Label("My Languages", systemImage: "books.vertical")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

// Removed stubs
