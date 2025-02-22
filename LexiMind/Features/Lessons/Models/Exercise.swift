import Foundation

enum ExerciseType {
    case wordMatching
    case speechRecognition
    case fillInBlanks
    case listening
    case quiz
    case multipleChoice
    case speaking
}

struct Exercise: Identifiable {
    let id: Int
    let type: ExerciseType
    let question: String
    let correctAnswer: String
    var options: [String]? // For multiple choice questions
    var audioURL: URL? // For listening exercises
    
    // Additional properties based on exercise type
    var imageURL: URL?
    var hint: String?
    var explanation: String?
    
    var isMultipleChoice: Bool {
        type == .multipleChoice
    }
    
    var isListening: Bool {
        type == .listening
    }
    
    var isSpeaking: Bool {
        type == .speaking
    }
}

// MARK: - Exercise Templates
extension Exercise {
    static func wordMatching(id: Int, word: String, translation: String, options: [String]) -> Exercise {
        Exercise(
            id: id,
            type: .wordMatching,
            question: "'\(word)' kelimesinin anlamı nedir?",
            correctAnswer: translation,
            options: options
        )
    }
    
    static func speechRecognition(id: Int, phrase: String) -> Exercise {
        Exercise(
            id: id,
            type: .speechRecognition,
            question: "Aşağıdaki cümleyi söyleyin:",
            correctAnswer: phrase
        )
    }
    
    static func fillInBlanks(id: Int, sentence: String, answer: String, hint: String? = nil) -> Exercise {
        Exercise(
            id: id,
            type: .fillInBlanks,
            question: sentence,
            correctAnswer: answer,
            hint: hint
        )
    }
    
    static func listening(id: Int, audioURL: URL, correctAnswer: String) -> Exercise {
        Exercise(
            id: id,
            type: .listening,
            question: "Dinlediğiniz cümleyi yazın:",
            correctAnswer: correctAnswer,
            audioURL: audioURL
        )
    }
    
    static func quiz(id: Int, question: String, correctAnswer: String, options: [String], explanation: String? = nil) -> Exercise {
        Exercise(
            id: id,
            type: .quiz,
            question: question,
            correctAnswer: correctAnswer,
            options: options,
            explanation: explanation
        )
    }
} 