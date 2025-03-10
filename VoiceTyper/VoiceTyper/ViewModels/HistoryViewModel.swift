import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    func addItem(_ text: String) {
        let item = HistoryItem(text: text)
        historyItems.insert(item, at: 0) // Add new items at the beginning
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
} 