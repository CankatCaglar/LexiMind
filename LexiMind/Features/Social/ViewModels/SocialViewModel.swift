import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class SocialViewModel: ObservableObject {
    @Published var globalLeaderboard: [LeaderboardEntry] = []
    @Published var friendsLeaderboard: [LeaderboardEntry] = []
    @Published var friends: [LeaderboardEntry] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var activities: [UserActivity] = []
    @Published var searchResults: [LeaderboardEntry] = []
    @Published var showAddFriend = false
    
    private let socialService = SocialService.shared
    
    init() {
        Task {
            await refreshAll()
        }
    }
    
    func refreshAll() async {
        await refreshLeaderboard()
        await refreshFriends()
        await refreshActivities()
    }
    
    func refreshLeaderboard() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            async let globalEntries = socialService.getLeaderboard()
            async let friendEntries = socialService.getFriendsLeaderboard(userId: userId)
            
            let (global, friends) = await (try globalEntries, try friendEntries)
            
            globalLeaderboard = global
            friendsLeaderboard = friends
        } catch {
            print("Error refreshing leaderboard: \(error)")
        }
    }
    
    func refreshFriends() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            friends = try await socialService.getFriendsLeaderboard(userId: userId)
        } catch {
            print("Error refreshing friends: \(error)")
        }
    }
    
    func refreshActivities() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            activities = try await socialService.getFriendsActivity(userId: userId)
        } catch {
            print("Error refreshing activities: \(error)")
        }
    }
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Mock data for testing
        let defaultAvatar = Avatar(
            name: "Default",
            category: .basic,
            imageUrl: "default_avatar"
        )
        
        searchResults = [
            LeaderboardEntry(
                userId: "1",
                username: "john_doe",
                avatar: defaultAvatar,
                score: 1000,
                rank: 1,
                stats: [.wordsLearned: 1000],
                streak: 5,
                xpEarned: 1000
            ),
            LeaderboardEntry(
                userId: "2",
                username: "jane_smith",
                avatar: defaultAvatar,
                score: 800,
                rank: 2,
                stats: [.wordsLearned: 800],
                streak: 3,
                xpEarned: 800
            )
        ]
    }
    
    func addFriend(username: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await socialService.sendFriendRequest(to: userId)
            await refreshLeaderboard()
        } catch {
            print("Error adding friend: \(error)")
        }
    }
    
    func postActivity(type: ActivityType, details: [String: Any], xpEarned: Int = 0) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let activity = UserActivity(
            userId: userId,
            type: type,
            details: details,
            xpEarned: xpEarned
        )
        
        do {
            try await socialService.postActivity(activity)
            await refreshActivities()
        } catch {
            print("Error posting activity: \(error)")
        }
    }
    
    func sendFriendRequest(to userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let request = FriendRequest(
                fromUserId: currentUserId,
                toUserId: userId,
                status: .pending
            )
            try await socialService.sendFriendRequest(to: userId)
            await refreshFriends()
        } catch {
            print("Error sending friend request: \(error)")
        }
    }
    
    func acceptFriendRequest(_ request: FriendRequest) async {
        do {
            try await socialService.respondToFriendRequest(request, accept: true)
            await refreshFriends()
        } catch {
            print("Error accepting friend request: \(error)")
        }
    }
    
    // MARK: - Activity Posting
    func postLessonCompletion(lessonId: String, xpEarned: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let activity = UserActivity(
            userId: userId,
            type: .completedLesson,
            details: ["lessonId": lessonId],
            xpEarned: xpEarned
        )
        
        do {
            try await socialService.postActivity(activity)
        } catch {
            print("Error posting activity: \(error)")
        }
    }
    
    func postStreakAchievement(days: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let activity = UserActivity(
            userId: userId,
            type: .achievedStreak,
            details: ["days": days]
        )
        
        do {
            try await socialService.postActivity(activity)
        } catch {
            print("Error posting activity: \(error)")
        }
    }
    
    func postLevelUp(level: Int) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let activity = UserActivity(
            userId: userId,
            type: .levelUp,
            details: ["level": level]
        )
        
        do {
            try await socialService.postActivity(activity)
        } catch {
            print("Error posting activity: \(error)")
        }
    }
    
    func postAchievement(title: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let activity = UserActivity(
            userId: userId,
            type: .unlockAchievement,
            details: ["title": title]
        )
        
        do {
            try await socialService.postActivity(activity)
        } catch {
            print("Error posting activity: \(error)")
        }
    }
} 