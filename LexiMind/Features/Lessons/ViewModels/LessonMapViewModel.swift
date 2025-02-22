import Foundation
import SwiftUI

class LessonMapViewModel: ObservableObject {
    @Published var lessonUnits: [LessonUnit] = []
    
    init() {
        loadLessonUnits()
    }
    
    private func loadLessonUnits() {
        // Mock data for now
        lessonUnits = [
            LessonUnit(
                id: 1,
                title: "Temel Seviye 1",
                progress: 0.8,
                isCompleted: true,
                lessons: [
                    Lesson(id: 1, title: "Selamlaşma", type: .vocabulary, isUnlocked: true, isCompleted: true),
                    Lesson(id: 2, title: "Sayılar", type: .vocabulary, isUnlocked: true, isCompleted: true),
                    Lesson(id: 3, title: "Renkler", type: .vocabulary, isUnlocked: true, isCompleted: false),
                    Lesson(id: 4, title: "Temel Cümleler", type: .speaking, isUnlocked: true, isCompleted: false)
                ]
            ),
            LessonUnit(
                id: 2,
                title: "Temel Seviye 2",
                progress: 0.3,
                isCompleted: false,
                lessons: [
                    Lesson(id: 5, title: "Aile", type: .vocabulary, isUnlocked: true, isCompleted: true),
                    Lesson(id: 6, title: "Meslekler", type: .vocabulary, isUnlocked: true, isCompleted: false),
                    Lesson(id: 7, title: "Yön Tarifleri", type: .speaking, isUnlocked: false, isCompleted: false),
                    Lesson(id: 8, title: "Hava Durumu", type: .listening, isUnlocked: false, isCompleted: false)
                ]
            )
        ]
    }
}

// MARK: - Models
struct LessonUnit: Identifiable {
    let id: Int
    let title: String
    var progress: Float
    var isCompleted: Bool
    var lessons: [Lesson]
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let type: LessonType
    var isUnlocked: Bool
    var isCompleted: Bool
    var hearts: Int = 4 // Default hearts for each lesson
    
    // Additional properties for lesson content
    var exercises: [Exercise] = []
    var xpReward: Int = 10
    var gemsReward: Int = 5
} 