import Foundation
import Speech
import AVFoundation
import NaturalLanguage

class TranscriptionManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var summarizationError: String?
    
    func summarizeText(_ text: String) async -> String {
        guard !text.isEmpty else { return "" }
        
        // Clean up the text first
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split into sentences more reliably
        var sentences = cleanText.components(separatedBy: ". ")
            .flatMap { $0.components(separatedBy: "! ") }
            .flatMap { $0.components(separatedBy: "? ") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Remove any empty sentences and duplicates
        sentences = Array(Set(sentences))
        
        // If we have 5 or fewer sentences, return the original text
        if sentences.count <= 5 {
            return cleanText
        }
        
        // Initialize NLP tools
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        var scoredSentences: [(text: String, score: Double, index: Int)] = []
        
        // Score each sentence
        for (index, sentence) in sentences.enumerated() {
            var score = 0.0
            
            // 1. Position scoring
            if index == 0 {
                score += 100 // First sentence is very important
            } else if index == sentences.count - 1 {
                score += 50 // Last sentence is important
            } else if index == 1 {
                score += 75 // Second sentence is quite important
            }
            
            // 2. Length scoring
            let words = sentence.split(separator: " ")
            if words.count >= 5 && words.count <= 20 {
                score += 50 // Prefer medium-length sentences
            }
            
            // 3. Content scoring
            tagger.string = sentence
            var keywordCount = 0
            
            tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, 
                               unit: .word,
                               scheme: .lexicalClass,
                               options: [.omitWhitespace, .omitPunctuation]) { tag, _ in
                if let tag = tag {
                    switch tag {
                    case .noun:
                        keywordCount += 3
                    case .verb:
                        keywordCount += 2
                    case .adjective:
                        keywordCount += 1
                    default:
                        break
                    }
                }
                return true
            }
            
            score += Double(keywordCount) * 2
            
            // Add to scored sentences array
            scoredSentences.append((sentence, score, index))
        }
        
        // Select top 5 sentences and sort them by original position
        let selectedSentences = scoredSentences
            .sorted { $0.score > $1.score }
            .prefix(5)
            .sorted { $0.index < $1.index }
        
        // Build final summary
        let summary = selectedSentences
            .map { sentence in
                var formatted = sentence.text
                if !formatted.hasSuffix(".") && !formatted.hasSuffix("!") && !formatted.hasSuffix("?") {
                    formatted += "."
                }
                return formatted
            }
            .joined(separator: " ")
        
        return summary
    }
    
    func startRecording() throws {
        // Reset the previous task if any
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "TranscriptionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        // Enable partial results for real-time updates
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation
        
        // Start recognition with real-time updates
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    // Update UI with transcribed text in real-time
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
    
    func requestPermissions() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
} 
