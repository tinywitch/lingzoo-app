import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Editable fields
    @Published var name: String = ""
    @Published var password = "" // Optional update

    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: BaseResponse<User> = try await APIClient.shared.request(path: "/member/profile")
            if let fetchedUser = response.data {
                self.user = fetchedUser
                self.name = fetchedUser.name
            }
        } catch {
            self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateProfile() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        do {
            var bodyString = "name=\(name)"
            if !password.isEmpty {
                bodyString += "&password=\(password)"
            }
            let bodyData = bodyString.data(using: .utf8)
            let response: BaseResponse<User> = try await APIClient.shared.request(
                path: "/member/profile",
                method: "POST", // API specifies POST for update
                body: bodyData
            )
            if let updatedUser = response.data {
                self.user = updatedUser
                self.name = updatedUser.name
                self.password = ""
                self.successMessage = response.message ?? "Profile updated successfully"
            }
        } catch {
            self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
        isSaving = false
    }
}
