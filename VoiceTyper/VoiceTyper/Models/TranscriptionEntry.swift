import Foundation

struct TranscriptionEntry: Identifiable, Codable {
    let id: UUID
    let fullText: String
    let summary: String
    let date: Date
    
    init(id: UUID = UUID(), fullText: String, summary: String, date: Date = Date()) {
        self.id = id
        self.fullText = fullText
        self.summary = summary
        self.date = date
    }
} 