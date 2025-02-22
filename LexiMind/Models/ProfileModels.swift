import Foundation
import FirebaseFirestore
import SwiftUI

// MARK: - Profile Models
public struct ProfileCustomization: Codable {
    public var selectedTheme: String?
    public var selectedAvatar: String?
    public var selectedTitle: String?
    public var customBio: String
    public var displayStats: [StatType]
    public var showcaseAchievements: [String]
    
    public init(selectedTheme: String? = nil,
         selectedAvatar: String? = nil,
         selectedTitle: String? = nil,
         customBio: String = "",
         displayStats: [StatType] = [],
         showcaseAchievements: [String] = []) {
        self.selectedTheme = selectedTheme
        self.selectedAvatar = selectedAvatar
        self.selectedTitle = selectedTitle
        self.customBio = customBio
        self.displayStats = displayStats
        self.showcaseAchievements = showcaseAchievements
    }
}

public struct Avatar: Codable, Identifiable {
    public let id: String
    public let name: String
    public let category: AvatarCategory
    public let imageUrl: String
    public let isAnimated: Bool
    public let animationSequence: AnimationSequence?
    public let isLocked: Bool
    public let requirement: UnlockRequirement?
    public let level: Int?
    
    public init(id: String = UUID().uuidString,
         name: String,
         category: AvatarCategory,
         imageUrl: String,
         isAnimated: Bool = false,
         animationSequence: AnimationSequence? = nil,
         isLocked: Bool = false,
         requirement: UnlockRequirement? = nil,
         level: Int? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.imageUrl = imageUrl
        self.isAnimated = isAnimated
        self.animationSequence = animationSequence
        self.isLocked = isLocked
        self.requirement = requirement
        self.level = level
    }
    
    public var imageURL: String { imageUrl } // For backward compatibility
}

public enum AvatarCategory: String, Codable {
    case basic
    case premium
    case achievement
    case seasonal
    case special
}

public struct AnimationSequence: Codable {
    public let frames: [String]
    public let duration: Double
    public let repeatCount: Int
    public let triggers: Set<AnimationTrigger>
    
    public init(frames: [String],
         duration: Double,
         repeatCount: Int,
         triggers: Set<AnimationTrigger>) {
        self.frames = frames
        self.duration = duration
        self.repeatCount = repeatCount
        self.triggers = triggers
    }
}

public enum AnimationTrigger: String, Codable {
    case onAppear
    case onTap
    case continuous
}

public struct Title: Codable, Identifiable {
    public let id: String
    public let text: String
    public let rarity: TitleRarity
    public let unlockRequirement: UnlockRequirement?
    public let isLocked: Bool
    
    public init(id: String = UUID().uuidString,
         text: String,
         rarity: TitleRarity,
         unlockRequirement: UnlockRequirement? = nil,
         isLocked: Bool = false) {
        self.id = id
        self.text = text
        self.rarity = rarity
        self.unlockRequirement = unlockRequirement
        self.isLocked = isLocked
    }
}

public enum TitleRarity: String, Codable {
    case common
    case rare
    case epic
    case legendary
    
    public var color: Color {
        switch self {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .orange
        }
    }
}

public struct Achievement: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public var currentProgress: Int
    public let requirement: Double
    public let reward: AchievementReward
    public var isCompleted: Bool
    public var completionDate: Date?
    public let category: AchievementCategory
    
    public init(id: String = UUID().uuidString,
         title: String,
         description: String,
         currentProgress: Int = 0,
         requirement: Double,
         reward: AchievementReward,
         isCompleted: Bool = false,
         completionDate: Date? = nil,
         category: AchievementCategory) {
        self.id = id
        self.title = title
        self.description = description
        self.currentProgress = currentProgress
        self.requirement = requirement
        self.reward = reward
        self.isCompleted = isCompleted
        self.completionDate = completionDate
        self.category = category
    }
    
    public var progress: Double {
        Double(currentProgress) / requirement
    }
}

public enum AchievementCategory: String, Codable {
    case learning
    case social
    case streak
    case mastery
    case special
    
    public var displayName: String {
        switch self {
        case .learning: return "Öğrenme"
        case .social: return "Sosyal"
        case .streak: return "Seri"
        case .mastery: return "Ustalık"
        case .special: return "Özel"
        }
    }
    
    public var icon: String {
        switch self {
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        case .streak: return "flame.fill"
        case .mastery: return "star.fill"
        case .special: return "sparkles"
        }
    }
}

public enum AchievementReward: Codable {
    case gems(amount: Int)
    case title(Title)
    case avatar(Avatar)
    case theme(Theme)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case amount
        case data
    }
    
    private enum RewardType: String, Codable {
        case gems
        case title
        case avatar
        case theme
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gems(let amount):
            try container.encode(RewardType.gems, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .title(let title):
            try container.encode(RewardType.title, forKey: .type)
            try container.encode(title, forKey: .data)
        case .avatar(let avatar):
            try container.encode(RewardType.avatar, forKey: .type)
            try container.encode(avatar, forKey: .data)
        case .theme(let theme):
            try container.encode(RewardType.theme, forKey: .type)
            try container.encode(theme, forKey: .data)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RewardType.self, forKey: .type)
        
        switch type {
        case .gems:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .gems(amount: amount)
        case .title:
            let title = try container.decode(Title.self, forKey: .data)
            self = .title(title)
        case .avatar:
            let avatar = try container.decode(Avatar.self, forKey: .data)
            self = .avatar(avatar)
        case .theme:
            let theme = try container.decode(Theme.self, forKey: .data)
            self = .theme(theme)
        }
    }
}

public enum StatType: String, Codable {
    case wordsLearned
    case lessonsCompleted
    case streakDays
    case accuracy
    case totalTime
    case perfectLessons
    
    public var icon: String {
        switch self {
        case .wordsLearned: return "book.fill"
        case .lessonsCompleted: return "checkmark.circle.fill"
        case .streakDays: return "flame.fill"
        case .accuracy: return "target"
        case .totalTime: return "clock.fill"
        case .perfectLessons: return "star.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .wordsLearned: return "Öğrenilen Kelimeler"
        case .lessonsCompleted: return "Tamamlanan Dersler"
        case .streakDays: return "Seri Günler"
        case .accuracy: return "Doğruluk"
        case .totalTime: return "Toplam Süre"
        case .perfectLessons: return "Mükemmel Dersler"
        }
    }
}

extension StatType: CaseIterable {
    public static var allCases: [StatType] = [
        .wordsLearned,
        .lessonsCompleted,
        .streakDays,
        .accuracy,
        .totalTime,
        .perfectLessons
    ]
    
    public static var totalXP: StatType { .wordsLearned }
} 