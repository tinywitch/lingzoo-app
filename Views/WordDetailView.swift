import SwiftUI

struct WordDetailView: View {
    let word: Word
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                        Text(pronunciation)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Synonyms
                if let synonyms = word.synonym, !synonyms.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synonyms")
                            .font(.headline).padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(synonyms, id: \.self) { syn in
                                    Text(syn)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Divider()
                }
                
                // Meanings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Meanings")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(Array(word.meaning.enumerated()), id: \.offset) { index, meaning in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(meaning.meaning)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    if let usage = meaning.usage, !usage.isEmpty {
                                        Text(usage)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .italic()
                                    }
                                }
                            }
                            
                            if let examples = meaning.examples, !examples.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Examples:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                    
                                    ForEach(Array(examples.enumerated()), id: \.offset) { exIndex, example in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("• \(example.original)")
                                                .font(.body)
                                            Text("  \(example.translation)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
    }
}
