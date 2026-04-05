import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    
    init() {
        self.isLoggedIn = APIClient.shared.isLoggedIn
    }
    
    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters: [String: Any] = [
                "username": username,
                "password": password,
                "device_name": "iOS App"
            ]
            
            let bodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let response: TokenResponse = try await APIClient.shared.request(
                path: "/member/token",
                method: "POST",
                body: bodyData,
                isMultipart: false
            )
            
            APIClient.shared.saveToken(response.access_token)
            self.isLoggedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        APIClient.shared.clearToken()
        self.isLoggedIn = false
    }
}
