import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var showCopiedAlert = false
    @State private var selectedEntry: TranscriptionEntry?
    @State private var showDeleteAlert = false
    @State private var entryToDelete: TranscriptionEntry?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.transcriptionHistory) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.fullText)
                            .lineLimit(3)
                            .font(.body)
                        
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
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry = entry
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteTranscriptions(at: indexSet)
                }
            }
            .navigationTitle("VoiceTyper History")
            .navigationBarTitleDisplayMode(.large)
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Text copied to clipboard")
            }
            .alert("Delete Entry", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        viewModel.deleteTranscription(entry)
                        selectedEntry = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this entry?")
            }
            .sheet(item: $selectedEntry) { entry in
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(entry.fullText)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                    .navigationTitle("VoiceTyper Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                selectedEntry = nil
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            HStack {
                                Button(action: {
                                    viewModel.copyToClipboard(entry.fullText)
                                    showCopiedAlert = true
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                
                                Button(action: {
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 

