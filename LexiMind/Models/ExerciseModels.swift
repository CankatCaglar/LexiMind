import Foundation

// MARK: - Exercise Types
enum ExerciseCategory: String, Codable {
    case listening
    case speaking
    case reading
    case writing
    
    var displayName: String {
        switch self {
        case .listening: return "Dinleme"
        case .speaking: return "Konuşma"
        case .reading: return "Okuma"
        case .writing: return "Yazma"
        }
    }
}

// MARK: - Performance Metrics
struct PerformanceMetrics: Codable {
    let exerciseAccuracy: ExerciseTypeAccuracy
    let exerciseSpeed: ExerciseTypeSpeed
    let wordRetention: WordRetention
    let dailyProgress: DailyProgress
    
    init(exerciseAccuracy: ExerciseTypeAccuracy = ExerciseTypeAccuracy(),
         exerciseSpeed: ExerciseTypeSpeed = ExerciseTypeSpeed(),
         wordRetention: WordRetention = WordRetention(),
         dailyProgress: DailyProgress = DailyProgress()) {
        self.exerciseAccuracy = exerciseAccuracy
        self.exerciseSpeed = exerciseSpeed
        self.wordRetention = wordRetention
        self.dailyProgress = dailyProgress
    }
}

struct ExerciseTypeAccuracy: Codable {
    let listening: Double
    let speaking: Double
    let reading: Double
    let writing: Double
    
    init(listening: Double = 0, speaking: Double = 0, reading: Double = 0, writing: Double = 0) {
        self.listening = listening
        self.speaking = speaking
        self.reading = reading
        self.writing = writing
    }
}

struct ExerciseTypeSpeed: Codable {
    let listening: TimeInterval
    let speaking: TimeInterval
    let reading: TimeInterval
    let writing: TimeInterval
    
    init(listening: TimeInterval = 0, speaking: TimeInterval = 0, reading: TimeInterval = 0, writing: TimeInterval = 0) {
        self.listening = listening
        self.speaking = speaking
        self.reading = reading
        self.writing = writing
    }
}

struct WordRetention: Codable {
    let shortTerm: Double
    let mediumTerm: Double
    let longTerm: Double
    
    init(shortTerm: Double = 0, mediumTerm: Double = 0, longTerm: Double = 0) {
        self.shortTerm = shortTerm
        self.mediumTerm = mediumTerm
        self.longTerm = longTerm
    }
}

struct DailyProgress: Codable {
    let wordsLearned: Int
    let exercisesCompleted: Int
    let timeSpent: TimeInterval
    let streakDays: Int
    
    init(wordsLearned: Int = 0, exercisesCompleted: Int = 0, timeSpent: TimeInterval = 0, streakDays: Int = 0) {
        self.wordsLearned = wordsLearned
        self.exercisesCompleted = exercisesCompleted
        self.timeSpent = timeSpent
        self.streakDays = streakDays
    }
}

// MARK: - Word Connections
struct WordConnection: Codable, Identifiable {
    let id: String
    let fromWord: String
    let toWord: String
    let connectionType: ConnectionType
    let strength: Double
    
    init(id: String = UUID().uuidString,
         fromWord: String,
         toWord: String,
         connectionType: ConnectionType,
         strength: Double = 0) {
        self.id = id
        self.fromWord = fromWord
        self.toWord = toWord
        self.connectionType = connectionType
        self.strength = strength
    }
}

enum ConnectionType: String, Codable {
    case synonym
    case antonym
    case related
    case compound
    case root
    case derivative
} 