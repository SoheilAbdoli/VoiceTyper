import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
} 