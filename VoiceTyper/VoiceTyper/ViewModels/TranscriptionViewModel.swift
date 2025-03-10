import Foundation
import SwiftUI
import Combine

@MainActor
class TranscriptionViewModel: ObservableObject {
    @Published var transcriptionManager = TranscriptionManager()
    @Published var transcriptionHistory: [TranscriptionEntry] = []
    @Published var isRecording = false
    @Published var showingPermissionAlert = false
    @Published var currentTranscription = ""
    var shouldStartRecordingAutomatically = false
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "transcriptionHistory"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadHistory()
        setupTranscriptionObserver()
    }
    
    private func setupTranscriptionObserver() {
        transcriptionManager.$transcribedText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newText in
                self?.currentTranscription = newText
            }
            .store(in: &cancellables)
    }
    
    func startRecording() {
        Task {
            do {
                let authorized = await transcriptionManager.requestPermissions()
                if authorized {
                    currentTranscription = "" // Clear previous text
                    try transcriptionManager.startRecording()
                    await MainActor.run {
                        isRecording = true
                    }
                } else {
                    await MainActor.run {
                        showingPermissionAlert = true
                    }
                }
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }
    
    func stopRecording() {
        Task {
            transcriptionManager.stopRecording()
            await MainActor.run {
                isRecording = false
                let entry = TranscriptionEntry(fullText: currentTranscription, summary: "")
                transcriptionHistory.insert(entry, at: 0)
                saveHistory()
            }
        }
    }
    
    private func loadHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([TranscriptionEntry].self, from: data) {
            transcriptionHistory = history
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(transcriptionHistory) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    func deleteTranscriptions(at offsets: IndexSet) {
        transcriptionHistory.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func deleteTranscription(_ entry: TranscriptionEntry) {
        if let index = transcriptionHistory.firstIndex(where: { $0.id == entry.id }) {
            transcriptionHistory.remove(at: index)
            saveHistory()
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
} 