import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                NavigationView {
                    VStack(spacing: 20) {
                        Text("Lingzoo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 40)
                        
                        TextField("Username", text: $viewModel.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            Text(viewModel.isLoading ? "Logging in..." : "Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                        
                        Spacer()
                    }
                    .padding()
                    .navigationBarHidden(true)
                }
            }
        }
    }
}
