import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username = ""
    @Published var level = 1
    @Published var totalXP = 0
    @Published var currentStreak = 0
    @Published var lessonsCompleted = 0
    @Published var customization: ProfileCustomization
    @Published var currentTheme: Theme?
    @Published var currentAvatar: Avatar?
    @Published var currentTitle: Title?
    @Published var availableThemes: [Theme] = []
    @Published var availableAvatars: [Avatar] = []
    @Published var availableTitles: [Title] = []
    @Published var allAchievements: [Achievement] = []
    @Published var showcaseAchievements: [Achievement] = []
    @Published var stats: [StatType: Int] = [:]
    
    private let db = Firestore.firestore()
    
    init() {
        // Initialize with default values
        self.customization = ProfileCustomization(
            selectedTheme: "default",
            selectedAvatar: "default",
            selectedTitle: nil,
            customBio: "",
            displayStats: [.wordsLearned, .streakDays, .lessonsCompleted],
            showcaseAchievements: []
        )
        
        Task {
            await loadUserProfile()
            await loadCustomizationOptions()
        }
    }
    
    // MARK: - Data Loading
    private func loadUserProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            let data = document.data() ?? [:]
            
            username = data["username"] as? String ?? ""
            level = data["level"] as? Int ?? 1
            totalXP = data["totalXP"] as? Int ?? 0
            currentStreak = data["currentStreak"] as? Int ?? 0
            lessonsCompleted = data["lessonsCompleted"] as? Int ?? 0
            
            if let customizationData = data["customization"] as? [String: Any] {
                customization = try JSONDecoder().decode(
                    ProfileCustomization.self,
                    from: JSONSerialization.data(withJSONObject: customizationData)
                )
            }
            
            await loadStats()
            await loadShowcaseAchievements()
        } catch {
            print("Error loading profile: \(error)")
        }
    }
    
    private func loadCustomizationOptions() async {
        do {
            // Load themes
            let themesSnapshot = try await db.collection("themes").getDocuments()
            availableThemes = themesSnapshot.documents.compactMap { document in
                try? document.data(as: Theme.self)
            }
            
            if let themeId = customization.selectedTheme {
                currentTheme = availableThemes.first { $0.id == themeId }
            }
            
            // Load avatars
            let avatarsSnapshot = try await db.collection("avatars").getDocuments()
            availableAvatars = avatarsSnapshot.documents.compactMap { document in
                try? document.data(as: Avatar.self)
            }
            
            if let avatarId = customization.selectedAvatar {
                currentAvatar = availableAvatars.first { $0.id == avatarId }
            }
            
            // Load titles
            let titlesSnapshot = try await db.collection("titles").getDocuments()
            availableTitles = titlesSnapshot.documents.compactMap { document in
                try? document.data(as: Title.self)
            }
            
            if let titleId = customization.selectedTitle {
                currentTitle = availableTitles.first { $0.id == titleId }
            }
        } catch {
            print("Error loading customization options: \(error)")
        }
    }
    
    private func loadStats() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users").document(userId).collection("stats").document("overview").getDocument()
            let data = document.data() ?? [:]
            
            for stat in StatType.allCases {
                stats[stat] = data[stat.rawValue] as? Int ?? 0
            }
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    private func loadShowcaseAchievements() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Load all achievements
            let achievementsSnapshot = try await db.collection("achievements").getDocuments()
            allAchievements = achievementsSnapshot.documents.compactMap { document in
                try? document.data(as: Achievement.self)
            }
            
            // Load user's achievement progress
            let userAchievementsSnapshot = try await db.collection("users")
                .document(userId)
                .collection("achievements")
                .getDocuments()
            
            let userAchievements = userAchievementsSnapshot.documents.reduce(into: [String: [String: Any]]()) { result, document in
                result[document.documentID] = document.data()
            }
            
            // Update achievement progress
            allAchievements = allAchievements.map { achievement in
                var updatedAchievement = achievement
                if let progress = userAchievements[achievement.id] {
                    updatedAchievement.currentProgress = progress["progress"] as? Int ?? 0
                    updatedAchievement.isCompleted = progress["isCompleted"] as? Bool ?? false
                    updatedAchievement.completionDate = (progress["completionDate"] as? Timestamp)?.dateValue()
                }
                return updatedAchievement
            }
            
            // Load showcase achievements
            showcaseAchievements = allAchievements.filter { customization.showcaseAchievements.contains($0.id) }
        } catch {
            print("Error loading achievements: \(error)")
        }
    }
    
    // MARK: - Customization Methods
    func selectTheme(_ theme: Theme) {
        guard !theme.isLocked else { return }
        customization.selectedTheme = theme.id
        currentTheme = theme
        saveCustomization()
    }
    
    func selectAvatar(_ avatar: Avatar) {
        guard !avatar.isLocked else { return }
        customization.selectedAvatar = avatar.id
        currentAvatar = avatar
        saveCustomization()
    }
    
    func selectTitle(_ title: Title?) {
        customization.selectedTitle = title?.id
        currentTitle = title
        saveCustomization()
    }
    
    func toggleShowcaseAchievement(_ achievement: Achievement) {
        if customization.showcaseAchievements.contains(achievement.id) {
            customization.showcaseAchievements.removeAll { $0 == achievement.id }
        } else {
            if customization.showcaseAchievements.count < 3 {
                customization.showcaseAchievements.append(achievement.id)
            }
        }
        saveCustomization()
    }
    
    func isAchievementShowcased(_ achievement: Achievement) -> Bool {
        customization.showcaseAchievements.contains(achievement.id)
    }
    
    // MARK: - Helper Methods
    func getStatValue(_ stat: StatType) -> Int {
        stats[stat] ?? 0
    }
    
    private func saveCustomization() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let data = try JSONEncoder().encode(customization)
                let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                
                try await db.collection("users").document(userId).updateData([
                    "customization": dict
                ])
            } catch {
                print("Error saving customization: \(error)")
            }
        }
    }
}

// MARK: - Mock Data
extension ProfileViewModel {
    static var mockThemes: [Theme] {
        [
            Theme(
                id: "default",
                name: "Varsayılan",
                description: "Klasik LexiMind teması",
                previewImageURL: nil,
                colors: ThemeColors(
                    primary: "#007AFF",
                    secondary: "#5856D6",
                    accent: "#FF2D55",
                    background: "#FFFFFF"
                ),
                isLocked: false,
                unlockRequirement: nil
            ),
            Theme(
                id: "dark",
                name: "Karanlık",
                description: "Koyu renkli tema",
                previewImageURL: nil,
                colors: ThemeColors(
                    primary: "#0A84FF",
                    secondary: "#5E5CE6",
                    accent: "#FF375F",
                    background: "#000000"
                ),
                isLocked: true,
                unlockRequirement: .premium
            )
        ]
    }
    
    static var mockAvatars: [Avatar] {
        [
            Avatar(
                id: "default",
                name: "Default Avatar",
                category: .basic,
                imageUrl: "default_avatar",
                isLocked: false
            ),
            Avatar(
                id: "premium_1",
                name: "Premium Avatar",
                category: .premium,
                imageUrl: "premium_avatar_1",
                isLocked: true,
                requirement: .premium
            )
        ]
    }
    
    static var mockTitles: [Title] {
        [
            Title(
                id: "beginner",
                text: "Başlangıç",
                rarity: .common,
                unlockRequirement: .level(1)
            ),
            Title(
                id: "master",
                text: "Dil Ustası",
                rarity: .legendary,
                unlockRequirement: .level(50)
            )
        ]
    }
} 