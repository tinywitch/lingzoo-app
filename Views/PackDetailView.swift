import SwiftUI
import Combine

struct PackDetailView: View {
    let packId: String
    let packName: String
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoadingPackDetails {
                ProgressView("Loading Pack...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                packContentView
            }
        }
        .navigationTitle(packName)
        .task {
            await viewModel.fetchPackDetails(packId: packId)
        }
    }
    
    @ViewBuilder
    private var packContentView: some View {
        if let pack = viewModel.currentPackDetails {
            if let words = pack.words, !words.isEmpty {
                List(words, id: \.id) { word in
                    NavigationLink(destination: WordDetailView(word: word)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(word.word)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            if let firstMeaning = word.meaning.first {
                                Text(firstMeaning.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            } else {
                Text("No words in this pack yet.")
                    .foregroundColor(.gray)
            }
        } else {
            Color.clear
        }
    }
}
