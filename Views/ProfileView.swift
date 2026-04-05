import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                if viewModel.isLoading {
                    ProgressView("Loading Profile...")
                } else {
                    Section(header: Text("User Information")) {
                        if let avatar = viewModel.user?.avatar, let url = URL(string: avatar) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit().frame(width: 80, height: 80).clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        TextField("Name", text: $viewModel.name)
                        Text(viewModel.user?.username ?? "")
                            .foregroundColor(.gray)
                        Text(viewModel.user?.email ?? "")
                            .foregroundColor(.gray)
                    }
                    
                    Section(header: Text("Security")) {
                        SecureField("New Password (Optional)", text: $viewModel.password)
                    }
                    
                    if let success = viewModel.successMessage {
                        Text(success).foregroundColor(.green)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)
                    }
                    
                    Section {
                        Button(action: {
                            Task { await viewModel.updateProfile() }
                        }) {
                            Text(viewModel.isSaving ? "Saving..." : "Save Changes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.isSaving || viewModel.name.isEmpty)
                    }
                    
                    Section {
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                if viewModel.user == nil {
                    await viewModel.fetchProfile()
                }
            }
        }
    }
}
