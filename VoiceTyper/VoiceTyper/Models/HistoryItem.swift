import Foundation

struct HistoryItem: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    
    init(text: String, timestamp: Date = Date()) {
        self.text = text
        self.timestamp = timestamp
    }
} 