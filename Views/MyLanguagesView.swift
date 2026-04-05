import SwiftUI
import Combine

struct MyLanguagesView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoadingLanguages {
                    ProgressView("Loading Languages...")
                } else if viewModel.myLanguages.isEmpty {
                    VStack {
                        Text("You haven't joined any languages yet.")
                            .foregroundColor(.gray)
                            .padding()
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                } else {
                    List(viewModel.myLanguages) { language in
                        NavigationLink(destination: CategoriesView(language: language)) {
                            HStack {
                                if let flag = language.flag, let url = URL(string: flag) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit().frame(width: 40, height: 40).cornerRadius(8)
                                    } placeholder: {
                                        ProgressView().frame(width: 40, height: 40)
                                    }
                                } else {
                                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40).cornerRadius(8)
                                }
                                
                                Text(language.name)
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Languages")
            .task {
                if viewModel.myLanguages.isEmpty {
                    await viewModel.fetchMyLanguages()
                }
            }
        }
    }
}
