import Foundation

// MARK: - API Responses
struct TokenResponse: Codable {
    let status: Int?
    let access_token: String
}

struct BaseResponse<T: Codable>: Codable {
    let message: String?
    let data: T?
}

// MARK: - Models
struct User: Codable {
    let id: String
    let name: String
    let username: String
    let email: String
    let avatar: String?
}

struct Language: Codable, Identifiable {
    let id: String
    let name: String
    let code: String
    let flag: String?
}

struct Category: Codable, Identifiable {
    let id: String
    let parent_id: String?
    let language_id: String
    let name: String
    let color: String?
    let packs: [Pack]?
    let children: [Category]?
}

struct Pack: Codable, Identifiable {
    let id: String
    let category_id: String
    let name: String
    let featured_image: String?
    let is_learning: Int?
    let category: Category?
    let words: [Word]?
}

struct Word: Codable, Identifiable {
    let id: String
    let pack_id: String
    let word: String
    let meaning: [Meaning]
    let pronunciation: String?
    let synonym: [String]?
}

struct Meaning: Codable {
    let usage: String?
    let meaning: String
    let examples: [Example]?
}

struct Example: Codable {
    let original: String
    let translation: String
}
