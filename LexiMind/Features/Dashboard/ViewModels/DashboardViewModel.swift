import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var dailyProgress: Float = 0.6
    @Published var streak: Int = 5
    @Published var remainingXP: Int = 50
    @Published var recommendedLessons: [LessonItem] = []
    @Published var aiSuggestions: [String] = []
    
    init() {
        loadDashboardData()
    }
    
    private func loadDashboardData() {
        // Mock data for now
        recommendedLessons = [
            LessonItem(id: 1, title: "Temel Kelimeler", type: .vocabulary, progress: 0.3),
            LessonItem(id: 2, title: "Günlük Konuşma", type: .speaking, progress: 0.0),
            LessonItem(id: 3, title: "Gramer Yapıları", type: .grammar, progress: 0.5)
        ]
        
        aiSuggestions = [
            "Hello - Merhaba",
            "Good morning - Günaydın",
            "Thank you - Teşekkür ederim"
        ]
    }
    
    func openProfile() {
        // Profile navigation logic will be implemented here
    }
}

// MARK: - Models
enum LessonType {
    case vocabulary
    case speaking
    case grammar
    case listening
    
    var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .speaking: return "mic.fill"
        case .grammar: return "text.book.closed.fill"
        case .listening: return "ear.fill"
        }
    }
}

struct LessonItem: Identifiable {
    let id: Int
    let title: String
    let type: LessonType
    var progress: Float
} 