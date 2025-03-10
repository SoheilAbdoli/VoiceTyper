import SwiftUI

struct WaveformBar: View {
    let index: Int
    @State private var height: CGFloat = 5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.blue.opacity(0.8))
            .frame(width: 3, height: height)
    }
    
    func startAnimating() {
        withAnimation(
            .easeInOut(duration: 0.5)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.1)
        ) {
            height = CGFloat.random(in: 20...45)
        }
    }
    
    func stopAnimating() {
        withAnimation(.easeOut(duration: 0.2)) {
            height = 5
        }
    }
}

struct WaveformView: View {
    let numberOfBars = 25
    private var bars: [WaveformBar] = []
    
    init() {
        // Initialize bars
        bars = (0..<numberOfBars).map { WaveformBar(index: $0) }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                bars[index]
            }
        }
    }
    
    func startAnimating() {
        for bar in bars {
            bar.startAnimating()
        }
    }
    
    func stopAnimating() {
        for bar in bars {
            bar.stopAnimating()
        }
    }
} 