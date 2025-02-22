import Foundation
import SwiftUI

class LessonDetailViewModel: ObservableObject {
    private let lesson: Lesson
    private var exercises: [Exercise]
    
    @Published var currentExerciseIndex = 0
    @Published var remainingHearts: Int
    @Published var isAnswerSubmitted = false
    @Published var selectedOption: String?
    @Published var userInput: String = ""
    @Published var isRecording = false
    @Published var showCompletionAlert = false
    
    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var totalExercises: Int {
        exercises.count
    }
    
    var canSubmitAnswer: Bool {
        if isAnswerSubmitted { return true }
        
        guard let exercise = currentExercise else { return false }
        
        switch exercise.type {
        case .wordMatching, .quiz, .multipleChoice:
            return selectedOption != nil
        case .fillInBlanks, .listening:
            return !userInput.isEmpty
        case .speechRecognition, .speaking:
            return !userInput.isEmpty || isRecording
        }
    }
    
    var earnedXP: Int {
        lesson.xpReward
    }
    
    var earnedGems: Int {
        lesson.gemsReward
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self.remainingHearts = lesson.hearts
        
        // Mock exercises for the lesson
        self.exercises = [
            Exercise.wordMatching(
                id: 1,
                word: "Hello",
                translation: "Merhaba",
                options: ["Merhaba", "Güle güle", "Nasılsın", "İyi günler"]
            ),
            Exercise.fillInBlanks(
                id: 2,
                sentence: "How are you? = Nasıl___?",
                answer: "sın",
                hint: "İkinci tekil şahıs eki"
            ),
            Exercise.speechRecognition(
                id: 3,
                phrase: "İyi günler"
            )
        ]
    }
    
    func selectOption(_ option: String) {
        selectedOption = option
    }
    
    func checkAnswer() {
        if isAnswerSubmitted {
            moveToNextExercise()
            return
        }
        
        guard let exercise = currentExercise else { return }
        
        var isCorrect = false
        
        switch exercise.type {
        case .wordMatching, .quiz, .multipleChoice:
            isCorrect = selectedOption == exercise.correctAnswer
        case .fillInBlanks, .listening, .speechRecognition, .speaking:
            isCorrect = userInput.lowercased() == exercise.correctAnswer.lowercased()
        }
        
        if !isCorrect {
            remainingHearts -= 1
        }
        
        isAnswerSubmitted = true
    }
    
    private func moveToNextExercise() {
        if currentExerciseIndex + 1 < exercises.count {
            currentExerciseIndex += 1
            resetExerciseState()
        } else {
            completeLesson()
        }
    }
    
    private func resetExerciseState() {
        isAnswerSubmitted = false
        selectedOption = nil
        userInput = ""
        isRecording = false
    }
    
    private func completeLesson() {
        // Update lesson completion status
        // Save progress
        // Award XP and gems
        showCompletionAlert = true
    }
} 