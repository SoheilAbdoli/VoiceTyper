import SwiftUI

struct TextSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var textSize: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Text Settings")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom)
            
            // Font Size Section
            VStack(alignment: .leading, spacing: 15) {
                Text("FONT SIZE")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("A")
                        .font(.system(size: 14))
                    
                    Slider(value: Binding(
                        get: { Double((textSize - 14) / (40 - 14)) },
                        set: { value in
                            textSize = 14 + (40 - 14) * CGFloat(value)
                        }
                    ))
                    .accentColor(.blue)
                    
                    Text("A")
                        .font(.system(size: 28))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
    }
} 