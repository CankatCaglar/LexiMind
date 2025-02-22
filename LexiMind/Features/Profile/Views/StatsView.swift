import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(StatType.allCases, id: \.self) { stat in
                    StatCard(type: stat, value: profileViewModel.getStatValue(stat))
                }
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .navigationTitle("İstatistikler")
    }
}

struct StatCard: View {
    let type: StatType
    let value: Int
    @EnvironmentObject private var themeManager: ThemeManager
    
    var icon: String {
        switch type {
        case .wordsLearned: return "book.fill"
        case .lessonsCompleted: return "checkmark.circle.fill"
        case .streakDays: return "flame.fill"
        case .accuracy: return "target"
        case .totalTime: return "clock.fill"
        case .perfectLessons: return "star.fill"
        }
    }
    
    var title: String {
        switch type {
        case .wordsLearned: return "Öğrenilen Kelimeler"
        case .lessonsCompleted: return "Tamamlanan Dersler"
        case .streakDays: return "Seri Günler"
        case .accuracy: return "Doğruluk"
        case .totalTime: return "Toplam Süre"
        case .perfectLessons: return "Mükemmel Dersler"
        }
    }
    
    var formattedValue: String {
        switch type {
        case .accuracy:
            return "\(value)%"
        case .totalTime:
            let hours = value / 3600
            return "\(hours) saat"
        default:
            return "\(value)"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(themeManager.accentColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            Text(formattedValue)
                .font(.title2.bold())
                .foregroundColor(themeManager.textColor)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding()
        .background(themeManager.inputBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(ProfileViewModel())
        .environmentObject(ThemeManager.shared)
} 