import SwiftUI

struct ContentView: View {
    // Determine whether to show login or main app based on token presence
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isLoggedIn {
            MainTabView()
                .environmentObject(authViewModel)
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
