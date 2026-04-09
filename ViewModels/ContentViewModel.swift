import SwiftUI
import Combine
import WidgetKit

@MainActor
class ContentViewModel: ObservableObject {
    @Published var myLanguages: [Language] = []
    @Published var isLoadingLanguages = false
    
    @Published var rootCategories: [Category] = []
    @Published var isLoadingCategories = false
    
    @Published var currentCategoryDetails: Category?
    @Published var isLoadingCategoryDetails = false
    
    @Published var currentPackDetails: Pack?
    @Published var isLoadingPackDetails = false
    
    @Published var errorMessage: String?
    
    func fetchMyLanguages() async {
        isLoadingLanguages = true
        errorMessage = nil
        do {
            let response: BaseResponse<[Language]> = try await APIClient.shared.request(path: "/my-languages")
            self.myLanguages = response.data ?? []
        } catch {
            self.errorMessage = "Failed to load languages: \(error.localizedDescription)"
        }
        isLoadingLanguages = false
    }
    
    func fetchCategories(for languageId: String) async {
        isLoadingCategories = true
        errorMessage = nil
        do {
            let response: BaseResponse<[Category]> = try await APIClient.shared.request(path: "/categories?language_id=\(languageId)")
            self.rootCategories = response.data ?? []
        } catch {
            self.errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
        isLoadingCategories = false
    }
    
    func fetchCategoryDetails(categoryId: String) async {
        isLoadingCategoryDetails = true
        errorMessage = nil
        do {
            let response: BaseResponse<Category> = try await APIClient.shared.request(path: "/categories/\(categoryId)")
            self.currentCategoryDetails = response.data
        } catch {
            self.errorMessage = "Failed to load category details: \(error.localizedDescription)"
        }
        isLoadingCategoryDetails = false
    }
    
    func fetchPackDetails(packId: String) async {
        isLoadingPackDetails = true
        errorMessage = nil
    
        do {
            let response: BaseResponse<Pack> = try await APIClient.shared.request(path: "/packs/\(packId)")
            self.currentPackDetails = response.data
        } catch {
            self.errorMessage = "Failed to load pack details: \(error.localizedDescription)"
        }
        isLoadingPackDetails = false
    }

    @Published var isUpdatingPack = false
    
    func togglePackLearning(packId: String, isLearning: Bool) async {
        isUpdatingPack = true
        errorMessage = nil
        
        do {
            let value = isLearning ? 1: 0
            let response: BaseResponse<Pack> = try await APIClient.shared.requestMultipart(
                path: "/packs/\(packId)",
                method: "PUT",
                parameters: ["is_learning": value.description],
                imageData: nil
            )
            
            if let updatedPack = response.data, let existingPack = self.currentPackDetails {
                self.currentPackDetails = Pack(
                    id: existingPack.id,
                    category_id: existingPack.category_id,
                    name: updatedPack.name,
                    featured_image: existingPack.featured_image,
                    is_learning: updatedPack.is_learning,
                    category: existingPack.category,
                    words: existingPack.words
                )
                
                // Update Local Storage for Widget
                if isLearning {
                    var widgetWords: [WidgetWord] = []
                    if let words = existingPack.words {
                        for word in words {
                            let meaningsStr = word.meaning.map { $0.meaning }
                            let widgetWord = WidgetWord(packId: packId, word: word.word, meanings: meaningsStr)
                            widgetWords.append(widgetWord)
                        }
                    }
                    WidgetDataManager.shared.addWords(packId: packId, newWords: widgetWords)
                } else {
                    WidgetDataManager.shared.removeWords(packId: packId)
                }
                
                // Reload widget timelines
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            self.errorMessage = "Failed to update pack: \(error.localizedDescription)"
        }
        isUpdatingPack = false
    }
}
