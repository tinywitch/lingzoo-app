import Foundation

public class WidgetDataManager {
    // Shared App Group name
    public static let appGroupName = "group.com.lingzoo.widget"
    
    private let userDefaults: UserDefaults?
    private let storageKey = "learning_words"
    
    public static let shared = WidgetDataManager()
    
    private init() {
        userDefaults = UserDefaults(suiteName: WidgetDataManager.appGroupName)
    }
    
    public func getWords() -> [WidgetWord] {
        guard let data = userDefaults?.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let words = try JSONDecoder().decode([WidgetWord].self, from: data)
            return words
        } catch {
            print("Failed to decode widget words: \(error)")
            return []
        }
    }
    
    private func saveWords(_ words: [WidgetWord]) {
        do {
            let data = try JSONEncoder().encode(words)
            userDefaults?.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode widget words: \(error)")
        }
    }
    
    public func addWords(packId: String, newWords: [WidgetWord]) {
        var currentWords = getWords()
        // Ensure no duplicates from this same pack if toggled again unexpectedly
        currentWords.removeAll { $0.packId == packId }
        currentWords.append(contentsOf: newWords)
        saveWords(currentWords)
    }
    
    public func removeWords(packId: String) {
        var currentWords = getWords()
        currentWords.removeAll { $0.packId == packId }
        saveWords(currentWords)
    }
}
