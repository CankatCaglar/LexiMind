import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                ForEach(profileViewModel.allAchievements) { achievement in
                    AchievementCardView(achievement: achievement)
                }
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle("Başarılar")
    }
}

private struct AchievementCardView: View {
    let achievement: Achievement
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(themeManager.textColor)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
                .lineLimit(2)
            
            ProgressView(value: achievement.progress)
                .tint(themeManager.accentColor)
            
            Text("\(Int(achievement.currentProgress))/\(Int(achievement.requirement))")
                .font(.caption2)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding()
        .background(themeManager.inputBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    AchievementsView()
        .environmentObject(ProfileViewModel())
        .environmentObject(ThemeManager.shared)
} 