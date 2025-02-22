import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Models
public struct LeaderboardEntry: Codable, Identifiable {
    public let id: String
    public let userId: String
    public let username: String
    public let avatar: Avatar
    public let score: Int
    public let rank: Int
    public let stats: [StatType: Double]
    public let streak: Int
    public let xpEarned: Int
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        username: String,
        avatar: Avatar,
        score: Int,
        rank: Int,
        stats: [StatType: Double],
        streak: Int,
        xpEarned: Int
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.avatar = avatar
        self.score = score
        self.rank = rank
        self.stats = stats
        self.streak = streak
        self.xpEarned = xpEarned
    }
    
    public var totalXP: Int {
        Int(stats[.wordsLearned] ?? 0)
    }
}

public struct FriendRequest: Codable, Identifiable {
    public let id: String
    public let fromUserId: String
    public let toUserId: String
    public let status: RequestStatus
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        fromUserId: String,
        toUserId: String,
        status: RequestStatus,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.timestamp = timestamp
    }
}

public enum RequestStatus: String, Codable {
    case pending
    case accepted
    case rejected
}

public struct UserActivity: Codable, Identifiable {
    public let id: String
    public let userId: String
    public let type: ActivityType
    public let details: [String: Any]
    public let timestamp: Date
    public let xpEarned: Int
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        type: ActivityType,
        details: [String: Any] = [:],
        timestamp: Date = Date(),
        xpEarned: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.details = details
        self.timestamp = timestamp
        self.xpEarned = xpEarned
    }
    
    public var description: String {
        switch type {
        case .completedLesson:
            return "completed a lesson"
        case .achievementUnlocked:
            return "unlocked an achievement"
        case .levelUp:
            return "leveled up"
        case .streakMilestone:
            return "reached a streak milestone"
        case .challengeCompleted:
            return "completed a challenge"
        case .achievedStreak:
            return "achieved a new streak"
        case .unlockAchievement:
            return "unlocked a new achievement"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case type
        case details
        case timestamp
        case xpEarned
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        type = try container.decode(ActivityType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        xpEarned = try container.decode(Int.self, forKey: .xpEarned)
        
        if let detailsData = try? container.decode(Data.self, forKey: .details),
           let details = try? JSONSerialization.jsonObject(with: detailsData) as? [String: Any] {
            self.details = details
        } else {
            self.details = [:]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(xpEarned, forKey: .xpEarned)
        
        if let detailsData = try? JSONSerialization.data(withJSONObject: details) {
            try container.encode(detailsData, forKey: .details)
        }
    }
}

public enum ActivityType: String, Codable {
    case completedLesson
    case achievementUnlocked
    case levelUp
    case streakMilestone
    case challengeCompleted
    case achievedStreak
    case unlockAchievement
}

// MARK: - Service
public class SocialService {
    public static let shared = SocialService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    public func getLeaderboard() async throws -> [LeaderboardEntry] {
        let snapshot = try await db.collection("leaderboard")
            .order(by: "score", descending: true)
            .limit(to: 100)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: LeaderboardEntry.self)
        }
    }
    
    public func getFriendsLeaderboard(userId: String) async throws -> [LeaderboardEntry] {
        let friendsDoc = try await db.collection("users")
            .document(userId)
            .collection("friends")
            .getDocuments()
        
        let friendIds = friendsDoc.documents.map { $0.documentID }
        
        let snapshot = try await db.collection("leaderboard")
            .whereField("userId", in: friendIds)
            .order(by: "score", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: LeaderboardEntry.self)
        }
    }
    
    public func getFriendsActivity(userId: String) async throws -> [UserActivity] {
        let friendsDoc = try await db.collection("users")
            .document(userId)
            .collection("friends")
            .getDocuments()
        
        let friendIds = friendsDoc.documents.map { $0.documentID }
        
        let snapshot = try await db.collection("activity")
            .whereField("userId", in: friendIds)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: UserActivity.self)
        }
    }
    
    public func postActivity(_ activity: UserActivity) async throws {
        try await db.collection("activity")
            .document(activity.id)
            .setData(from: activity)
    }
    
    public func sendFriendRequest(to userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let request = FriendRequest(
            id: UUID().uuidString,
            fromUserId: currentUserId,
            toUserId: userId,
            status: .pending,
            timestamp: Date()
        )
        
        try await db.collection("friendRequests")
            .document(request.id)
            .setData(from: request)
    }
    
    public func respondToFriendRequest(_ request: FriendRequest, accept: Bool) async throws {
        let status: RequestStatus = accept ? .accepted : .rejected
        
        try await db.collection("friendRequests")
            .document(request.id)
            .updateData(["status": status.rawValue])
        
        if accept {
            // Add to friends collection for both users
            try await db.collection("users")
                .document(request.fromUserId)
                .collection("friends")
                .document(request.toUserId)
                .setData(["timestamp": Date()])
            
            try await db.collection("users")
                .document(request.toUserId)
                .collection("friends")
                .document(request.fromUserId)
                .setData(["timestamp": Date()])
        }
    }
} 