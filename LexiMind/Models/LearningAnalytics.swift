import Foundation
import FirebaseFirestore
import SwiftUI

// MARK: - Learning Analytics
public struct LearningAnalytics: Codable, Identifiable {
    public let id: String
    public let userId: String
    public let trends: [Trend]
    public let weakAreas: [WeakArea]
    public let wordMap: WordMap
    public let calendar: LearningCalendar
    public var studyGoals: [StudyGoal]
    public var activeReviews: [ActiveReviewSession]
    
    enum CodingKeys: String, CodingKey {
        case id, userId, trends, weakAreas, wordMap, calendar, studyGoals, activeReviews
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        trends = try container.decode([Trend].self, forKey: .trends)
        weakAreas = try container.decode([WeakArea].self, forKey: .weakAreas)
        wordMap = try container.decode(WordMap.self, forKey: .wordMap)
        calendar = try container.decode(LearningCalendar.self, forKey: .calendar)
        studyGoals = try container.decode([StudyGoal].self, forKey: .studyGoals)
        activeReviews = try container.decode([ActiveReviewSession].self, forKey: .activeReviews)
    }
    
    public init(id: String = UUID().uuidString,
         userId: String,
         trends: [Trend] = [],
         weakAreas: [WeakArea] = [],
         wordMap: WordMap,
         calendar: LearningCalendar,
         studyGoals: [StudyGoal] = [],
         activeReviews: [ActiveReviewSession] = []) {
        self.id = id
        self.userId = userId
        self.trends = trends
        self.weakAreas = weakAreas
        self.wordMap = wordMap
        self.calendar = calendar
        self.studyGoals = studyGoals
        self.activeReviews = activeReviews
    }
}

// MARK: - Calendar
public struct LearningCalendar: Codable {
    public let scheduledLessons: [ScheduledLesson]
    public let reviewSchedules: [ReviewSchedule]
    
    public init(scheduledLessons: [ScheduledLesson] = [], reviewSchedules: [ReviewSchedule] = []) {
        self.scheduledLessons = scheduledLessons
        self.reviewSchedules = reviewSchedules
    }
}

// MARK: - Scheduled Lesson
public struct ScheduledLesson: Codable, Identifiable {
    public let id: String
    public let title: String
    public let datetime: Date
    public let duration: TimeInterval
    public let priority: Priority
    public let type: LessonType
    
    public enum LessonType: String, Codable {
        case vocabulary
        case grammar
        case pronunciation
        case conversation
        case review
    }
    
    public init(id: String = UUID().uuidString,
         title: String,
         datetime: Date,
         duration: TimeInterval,
         priority: Priority = .medium,
         type: LessonType) {
        self.id = id
        self.title = title
        self.datetime = datetime
        self.duration = duration
        self.priority = priority
        self.type = type
    }
}

// MARK: - Review Type
public enum ReviewType: String, Codable {
    case daily = "Günlük"
    case weekly = "Haftalık"
    case monthly = "Aylık"
    case spaced = "Aralıklı"
    case intensive = "Yoğun"
    case quick = "Hızlı"
    case comprehensive = "Kapsamlı"
    
    public var displayName: String {
        switch self {
        case .daily: return "Günlük Tekrar"
        case .weekly: return "Haftalık Tekrar"
        case .monthly: return "Aylık Tekrar"
        case .spaced: return "Aralıklı Tekrar"
        case .intensive: return "Yoğun Tekrar"
        case .quick: return "Hızlı Tekrar"
        case .comprehensive: return "Kapsamlı Tekrar"
        }
    }
    
    public var defaultDuration: TimeInterval {
        switch self {
        case .daily: return 10 * 60
        case .weekly: return 20 * 60
        case .monthly: return 30 * 60
        case .spaced: return 15 * 60
        case .intensive: return 30 * 60
        case .quick: return 5 * 60
        case .comprehensive: return 45 * 60
        }
    }
}

// MARK: - Review Schedule
public struct ReviewSchedule: Codable, Identifiable {
    public let id: String
    public let words: [String]
    public let scheduledDate: Date
    public let type: ReviewType
    public let estimatedDuration: TimeInterval
    public let priority: Priority
    
    public init(id: String = UUID().uuidString,
         words: [String],
         scheduledDate: Date,
         type: ReviewType,
         estimatedDuration: TimeInterval? = nil,
         priority: Priority = .medium) {
        self.id = id
        self.words = words
        self.scheduledDate = scheduledDate
        self.type = type
        self.estimatedDuration = estimatedDuration ?? type.defaultDuration
        self.priority = priority
    }
}

// MARK: - Active Review Session
public struct ActiveReviewSession: Codable, Identifiable {
    public let id: String
    public let words: [String]
    public let startTime: Date
    public let endTime: Date?
    public let type: ReviewType
    public let progress: Double
    public let results: [ReviewResult]
    public let completed: Bool
    
    public init(id: String = UUID().uuidString,
         words: [String],
         startTime: Date = Date(),
         endTime: Date? = nil,
         type: ReviewType,
         progress: Double = 0.0,
         results: [ReviewResult] = [],
         completed: Bool = false) {
        self.id = id
        self.words = words
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
        self.progress = progress
        self.results = results
        self.completed = completed
    }
}

// MARK: - Review Result
public struct ReviewResult: Codable, Identifiable {
    public let id: String
    public let wordId: String
    public let accuracy: Double
    public let speed: TimeInterval
    public let mistakes: [String]
    public let needsReinforcement: Bool
    
    public init(id: String = UUID().uuidString,
         wordId: String,
         accuracy: Double,
         speed: TimeInterval,
         mistakes: [String] = [],
         needsReinforcement: Bool = false) {
        self.id = id
        self.wordId = wordId
        self.accuracy = accuracy
        self.speed = speed
        self.mistakes = mistakes
        self.needsReinforcement = needsReinforcement
    }
}

// MARK: - Study Goal
public struct StudyGoal: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let target: GoalTarget
    public let deadline: Date
    public let progress: Double
    public let type: GoalType
    
    public enum GoalType: String, Codable {
        case daily
        case weekly
        case monthly
        case custom
    }
}

// MARK: - Goal Target
public struct GoalTarget: Codable {
    public let value: Int
    public let unit: GoalUnit
    public let category: GoalCategory
    
    public enum GoalUnit: String, Codable {
        case words
        case lessons
        case minutes
        case exercises
    }
    
    public enum GoalCategory: String, Codable {
        case learning
        case practice
        case review
        case speaking
    }
}

// MARK: - Analytics Models
public struct Trend: Codable, Identifiable {
    public let id: String
    public let type: String
    public let data: [Double]
    public let labels: [String]
    public let period: String
    
    public init(id: String = UUID().uuidString,
         type: String,
         data: [Double],
         labels: [String],
         period: String) {
        self.id = id
        self.type = type
        self.data = data
        self.labels = labels
        self.period = period
    }
}

public struct WeakArea: Codable, Identifiable {
    public let id: String
    public let category: WordCategory
    public let accuracy: Double
    public let recommendedExercises: [String]
    
    public init(id: String = UUID().uuidString,
         category: WordCategory,
         accuracy: Double,
         recommendedExercises: [String] = []) {
        self.id = id
        self.category = category
        self.accuracy = accuracy
        self.recommendedExercises = recommendedExercises
    }
}

public struct WordMap: Codable {
    public let categories: [WordCategory]
    public let connections: [String: [String]]
    public let mastery: [WordMastery]
    
    public init(categories: [WordCategory] = [],
         connections: [String: [String]] = [:],
         mastery: [WordMastery] = []) {
        self.categories = categories
        self.connections = connections
        self.mastery = mastery
    }
}

public struct WordCategory: Codable, Identifiable {
    public let id: String
    public let name: String
    public let level: Int
    public let words: [String]
    
    public init(id: String = UUID().uuidString,
         name: String,
         level: Int,
         words: [String] = []) {
        self.id = id
        self.name = name
        self.level = level
        self.words = words
    }
}

public struct WordMastery: Codable, Identifiable {
    public let id: String
    public let word: String
    public let level: MasteryLevel
    
    public enum MasteryLevel: String, Codable {
        case learning = "Öğreniliyor"
        case practicing = "Pratik"
        case mastered = "Uzman"
        
        public var color: Color {
            switch self {
            case .learning: return .orange
            case .practicing: return .blue
            case .mastered: return .green
            }
        }
    }
    
    public init(id: String = UUID().uuidString,
         word: String,
         level: MasteryLevel) {
        self.id = id
        self.word = word
        self.level = level
    }
}

public enum Priority: String, Codable {
    case high = "Yüksek"
    case medium = "Orta"
    case low = "Düşük"
} 