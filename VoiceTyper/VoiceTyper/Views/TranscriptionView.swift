import SwiftUI

struct TranscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var textSize: CGFloat = 17
    @State private var showingTextSettings = false
    private let waveformView = WaveformView()
    
    var body: some View {
        VStack {
            // Top Bar with Controls
            HStack {
                // Close Button
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    }
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Font Size Button
                Button(action: {
                    showingTextSettings = true
                }) {
                    Image(systemName: "textformat.size")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Spacer()
            
            // Transcription Text
            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.currentTranscription.isEmpty ? "Start speaking..." : viewModel.currentTranscription)
                        .font(.system(size: textSize))
                        .foregroundColor(viewModel.currentTranscription.isEmpty ? .gray : .primary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .id("transcriptionText")
                }
                .onChange(of: viewModel.currentTranscription) { _ in
                    withAnimation {
                        proxy.scrollTo("transcriptionText", anchor: .center)
                    }
                }
            }
            
            Spacer()
            
            // Waveform Animation
            if viewModel.isRecording {
                waveformView
                    .frame(height: 50)
                    .padding(.bottom, 20)
            }
            
            // Recording Controls
            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                    waveformView.stopAnimating()
                } else {
                    viewModel.startRecording()
                    waveformView.startAnimating()
                }
                HapticManager.shared.vibrate()
            }) {
                VStack {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 60))
                    Text(viewModel.isRecording ? "Stop" : "Start")
                        .font(.headline)
                }
                .foregroundColor(viewModel.isRecording ? .red : .blue)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingTextSettings) {
            TextSettingsView(textSize: $textSize)
                .presentationDetents([.height(200)])
        }
        .onAppear {
            if viewModel.shouldStartRecordingAutomatically {
                viewModel.startRecording()
                waveformView.startAnimating()
                viewModel.shouldStartRecordingAutomatically = false
            }
        }
    }
} 