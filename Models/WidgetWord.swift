import Foundation

public struct WidgetWord: Codable, Identifiable {
    public var id = UUID()
    public let packId: String
    public let word: String
    public let meanings: [String]
    
    // Equatable / initialization automatically synthesized
}
