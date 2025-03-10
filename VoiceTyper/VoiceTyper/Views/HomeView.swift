import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var navigateToTranscription = false
    @State private var navigateToHistory = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Recent History Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Recent History")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { navigateToHistory = true }) {
                            Text("See All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if viewModel.transcriptionHistory.isEmpty {
                        Text("No transcriptions yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(viewModel.transcriptionHistory.prefix(3)) { entry in
                            Button(action: { navigateToHistory = true }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.fullText)
                                        .lineLimit(2)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack {
                                        Text(entry.date.formatted())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Transcribe Button
                Button(action: {
                    viewModel.shouldStartRecordingAutomatically = true
                    navigateToTranscription = true
                    HapticManager.shared.vibrate()
                }) {
                    VStack {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 60))
                        Text("Transcribe")
                            .font(.title2)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("VoiceTyper")
            .sheet(isPresented: $navigateToTranscription) {
                TranscriptionView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                HistoryView(viewModel: viewModel)
            }
            .alert("Microphone Access Required", isPresented: $viewModel.showingPermissionAlert) {
                Button("OK", role: .cancel) { }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please allow microphone access in Settings to use the transcription feature.")
            }
        }
    }
}
#Preview {
    HomeView()
}
