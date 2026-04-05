import SwiftUI
import Combine

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
}
