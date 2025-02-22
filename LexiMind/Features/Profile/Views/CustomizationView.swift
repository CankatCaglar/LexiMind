import SwiftUI
import Kingfisher

struct CustomizationView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack {
                    // Tab selector
                    Picker("", selection: $selectedTab) {
                        Text("Tema").tag(0)
                        Text("Avatar").tag(1)
                        Text("Başlık").tag(2)
                        Text("Profil").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        ThemeCustomizationView()
                            .tag(0)
                        
                        AvatarCustomizationView()
                            .tag(1)
                        
                        TitleCustomizationView()
                            .tag(2)
                        
                        ProfileCustomizationView()
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Özelleştir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.textColor)
                }
            }
        }
    }
}

struct ThemeCustomizationView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(profileViewModel.availableThemes) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: theme.id == profileViewModel.customization.selectedTheme
                    ) {
                        profileViewModel.selectTheme(theme)
                    }
                }
            }
            .padding()
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Preview
                if let previewURLString = theme.previewImageURL,
                   let previewURL = URL(string: previewURLString) {
                    AsyncImage(url: previewURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        themeManager.inputBackgroundColor
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    // Color preview
                    HStack(spacing: 5) {
                        theme.primaryColor
                        theme.secondaryColor
                        theme.accentColor
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Theme info
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .lineLimit(2)
                }
                
                // Lock status
                if theme.isLocked {
                    if let requirement = theme.unlockRequirement {
                        UnlockRequirementView(requirement: requirement)
                    }
                }
            }
            .padding()
            .background(themeManager.inputBackgroundColor)
            .cornerRadius(15)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 3)
            )
            .opacity(theme.isLocked ? 0.6 : 1)
        }
        .disabled(theme.isLocked)
    }
}

struct AvatarCustomizationView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedCategory: AvatarCategory = .basic
    
    var body: some View {
        VStack {
            // Category selector
            Picker("Category", selection: $selectedCategory) {
                Text("Temel").tag(AvatarCategory.basic)
                Text("Premium").tag(AvatarCategory.premium)
                Text("Başarı").tag(AvatarCategory.achievement)
                Text("Sezonluk").tag(AvatarCategory.seasonal)
                Text("Özel").tag(AvatarCategory.special)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Avatars grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(profileViewModel.availableAvatars.filter { $0.category == selectedCategory }) { avatar in
                        AvatarCard(
                            avatar: avatar,
                            isSelected: avatar.id == profileViewModel.customization.selectedAvatar
                        ) {
                            profileViewModel.selectAvatar(avatar)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct AvatarCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                if avatar.isAnimated, let sequence = avatar.animationSequence {
                    AnimatedAvatarView(sequence: sequence)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 3)
                        )
                } else if let imageURL = URL(string: avatar.imageUrl) {
                    KFImage(imageURL)
                        .placeholder {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 3)
                        )
                }
                
                Text(avatar.name)
                    .font(.caption)
                    .foregroundColor(themeManager.textColor)
                    .lineLimit(1)
                
                if avatar.isLocked {
                    if let requirement = avatar.requirement {
                        UnlockRequirementView(requirement: requirement)
                    }
                }
                
                if avatar.isAnimated {
                    Label("Animasyonlu", systemImage: "sparkles")
                        .font(.caption2)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding()
            .background(themeManager.inputBackgroundColor)
            .cornerRadius(10)
            .shadow(radius: 3)
            .opacity(avatar.isLocked ? 0.6 : 1)
        }
        .disabled(avatar.isLocked)
    }
}

struct AnimatedAvatarView: View {
    let sequence: AnimationSequence
    @State private var currentFrameIndex = 0
    @State private var isAnimating = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if currentFrameIndex < sequence.frames.count,
               let frameURL = URL(string: sequence.frames[currentFrameIndex]) {
                KFImage(frameURL)
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            if sequence.triggers.contains(.onAppear) {
                startAnimation()
            }
        }
        .onTapGesture {
            if sequence.triggers.contains(.onTap) {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        Timer.scheduledTimer(withTimeInterval: sequence.duration / Double(sequence.frames.count), repeats: true) { timer in
            currentFrameIndex = (currentFrameIndex + 1) % sequence.frames.count
            
            if currentFrameIndex == sequence.frames.count - 1 {
                if sequence.repeatCount > 0 {
                    timer.invalidate()
                    isAnimating = false
                }
            }
        }
    }
}

struct TitleCustomizationView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var selectedRarity: TitleRarity = .common
    
    var body: some View {
        VStack {
            // Rarity selector
            Picker("Rarity", selection: $selectedRarity) {
                Text("Normal").tag(TitleRarity.common)
                Text("Nadir").tag(TitleRarity.rare)
                Text("Epik").tag(TitleRarity.epic)
                Text("Efsanevi").tag(TitleRarity.legendary)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Titles list
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(profileViewModel.availableTitles.filter { $0.rarity == selectedRarity }) { title in
                        TitleCard(
                            title: title,
                            isSelected: title.id == profileViewModel.customization.selectedTitle
                        ) {
                            profileViewModel.selectTitle(title)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct TitleCard: View {
    let title: Title
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(title.text)
                    .font(.headline)
                    .foregroundColor(title.rarity.color)
                
                Spacer()
                
                if let requirement = title.unlockRequirement {
                    UnlockRequirementView(requirement: requirement)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding()
            .background(themeManager.inputBackgroundColor)
            .cornerRadius(10)
            .shadow(radius: 3)
            .opacity(title.isLocked ? 0.6 : 1)
        }
        .disabled(title.isLocked)
    }
}

private struct AchievementCard: View {
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
        .frame(width: 200)
    }
}

struct ProfileCustomizationView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bio
                VStack(alignment: .leading) {
                    Text("Hakkında")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    TextEditor(text: $profileViewModel.customization.customBio)
                        .frame(height: 100)
                        .padding(8)
                        .background(themeManager.inputBackgroundColor)
                        .cornerRadius(8)
                }
                
                // Display Stats
                VStack(alignment: .leading) {
                    Text("Gösterilecek İstatistikler")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    ForEach(StatType.allCases, id: \.self) { stat in
                        Toggle(isOn: Binding(
                            get: { profileViewModel.customization.displayStats.contains(stat) },
                            set: { isOn in
                                if isOn {
                                    profileViewModel.customization.displayStats.append(stat)
                                } else {
                                    profileViewModel.customization.displayStats.removeAll { $0 == stat }
                                }
                            }
                        )) {
                            Label(stat.description, systemImage: stat.icon)
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                }
                
                // Showcase Achievements
                VStack(alignment: .leading) {
                    Text("Vitrin Başarıları")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(profileViewModel.allAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                                    .onTapGesture {
                                        profileViewModel.toggleShowcaseAchievement(achievement)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(profileViewModel.isAchievementShowcased(achievement) ? themeManager.accentColor : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
    }
}

struct UnlockRequirementView: View {
    let requirement: UnlockRequirement
    
    var body: some View {
        HStack {
            Image(systemName: getIcon())
            Text(getText())
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
    
    private func getIcon() -> String {
        switch requirement {
        case .premium:
            return "crown.fill"
        case .achievement:
            return "trophy.fill"
        case .level:
            return "star.fill"
        case .purchase:
            return "diamond.fill"
        }
    }
    
    private func getText() -> String {
        switch requirement {
        case .premium:
            return "Premium"
        case .achievement(let id):
            return "Başarı Gerekli"
        case .level(let level):
            return "Seviye \(level)"
        case .purchase(let gems):
            return "\(gems) Gem"
        }
    }
}

#Preview {
    CustomizationView()
        .environmentObject(ProfileViewModel())
        .environmentObject(ThemeManager.shared)
} 