import Foundation

enum Environment {
    enum Keys {
        static let baseURL = "BASE_URL"
    }
    
    // Defaulting to the local host for local development. In production, this can come from an Info.plist or Build Settings.
    static var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: Keys.baseURL) as? String ?? "https://lingzoo.test/api"
    }
}
