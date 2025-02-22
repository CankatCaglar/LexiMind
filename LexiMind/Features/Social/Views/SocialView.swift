import SwiftUI

struct SocialView: View {
    @StateObject private var viewModel = SocialViewModel()
    @State private var selectedTab = 0
    @State private var tabTextWidths: [CGFloat] = [0, 0, 0]
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Tab Selector
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(0..<3) { index in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = index
                                    }
                                }) {
                                    Text(getTabTitle(for: index))
                                        .font(.system(size: 15, weight: selectedTab == index ? .bold : .regular))
                                        .foregroundColor(selectedTab == index ? themeManager.textColor : themeManager.secondaryTextColor)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            GeometryReader { geometry in
                                                Color.clear.preference(
                                                    key: TabWidthPreferenceKey.self,
                                                    value: [TabWidth(index: index, width: geometry.size.width)]
                                                )
                                            }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onPreferenceChange(TabWidthPreferenceKey.self) { preferences in
                            for p in preferences {
                                tabTextWidths[p.index] = p.width
                            }
                        }
                        
                        // Animated indicator
                        TabIndicator(totalTabs: 3, selectedTab: selectedTab, tabTextWidths: tabTextWidths)
                            .padding(.horizontal)
                    }
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        LeaderboardView(viewModel: viewModel)
                            .tag(0)
                        
                        FriendsView(viewModel: viewModel)
                            .tag(1)
                        
                        ActivityFeedView(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.showAddFriend = true }) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(themeManager.textColor)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer()
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showAddFriend) {
                    AddFriendView(viewModel: viewModel)
                }
            }
        }
    }
    
    private func getTabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Liderlik Tablosu"
        case 1: return "Arkadaşlar"
        case 2: return "Aktiviteler"
        default: return ""
        }
    }
}

struct LeaderboardView: View {
    @ObservedObject var viewModel: SocialViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List {
            ForEach(viewModel.friendsLeaderboard) { entry in
                LeaderboardRow(entry: entry)
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.backgroundColor)
        .refreshable {
            await viewModel.refreshLeaderboard()
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // Profile image
            Circle()
                .fill(themeManager.inputBackgroundColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(entry.username.prefix(1).uppercased())
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                )
            
            VStack(alignment: .leading) {
                Text(entry.username)
                    .font(.headline)
                    .foregroundColor(themeManager.textColor)
                
                HStack {
                    Label("\(entry.totalXP) XP", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Label("\(entry.streak) gün", systemImage: "flame.fill")
                        .foregroundColor(.orange)
                }
                .font(.caption)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .listRowBackground(themeManager.inputBackgroundColor)
    }
}

struct FriendsView: View {
    @ObservedObject var viewModel: SocialViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List {
            // Friend requests
            if !viewModel.friendRequests.isEmpty {
                Section("Arkadaşlık İstekleri") {
                    ForEach(viewModel.friendRequests, id: \.fromUserId) { request in
                        FriendRequestRow(request: request) { accepted in
                            if accepted {
                                Task {
                                    await viewModel.acceptFriendRequest(request)
                                }
                            }
                        }
                    }
                }
            }
            
            // Friends list
            Section("Arkadaşlarım") {
                ForEach(viewModel.friends, id: \.userId) { friend in
                    FriendRow(friend: friend)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.backgroundColor)
        .refreshable {
            await viewModel.refreshFriends()
        }
    }
}

struct FriendRequestRow: View {
    let request: FriendRequest
    let onResponse: (Bool) -> Void
    
    var body: some View {
        HStack {
            // Profile image
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text("@username") // Replace with actual username
                .font(.headline)
            
            Spacer()
            
            // Accept/Reject buttons
            HStack {
                Button(action: { onResponse(true) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Button(action: { onResponse(false) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct FriendRow: View {
    let friend: LeaderboardEntry
    
    var body: some View {
        HStack {
            // Profile image
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(friend.username.prefix(1).uppercased())
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading) {
                Text(friend.username)
                    .font(.headline)
                
                HStack {
                    Label("\(friend.totalXP) XP", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Label("\(friend.streak) gün", systemImage: "flame.fill")
                        .foregroundColor(.orange)
                }
                .font(.caption)
            }
            
            Spacer()
        }
    }
}

struct ActivityFeedView: View {
    @ObservedObject var viewModel: SocialViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List {
            ForEach(viewModel.activities, id: \.timestamp) { activity in
                ActivityRow(activity: activity)
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.backgroundColor)
        .refreshable {
            await viewModel.refreshActivities()
        }
    }
}

struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack {
            // Activity icon
            Circle()
                .fill(getActivityColor())
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: getActivityIcon())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text(activity.description)
                    .font(.headline)
                
                if activity.xpEarned > 0 {
                    Label("\(activity.xpEarned) XP kazandı", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    private func getActivityColor() -> Color {
        switch activity.type {
        case .completedLesson:
            return .blue
        case .achievementUnlocked, .unlockAchievement:
            return .green
        case .levelUp:
            return .purple
        case .streakMilestone, .achievedStreak:
            return .orange
        case .challengeCompleted:
            return .red
        }
    }
    
    private func getActivityIcon() -> String {
        switch activity.type {
        case .completedLesson:
            return "checkmark.circle.fill"
        case .achievementUnlocked, .unlockAchievement:
            return "trophy.fill"
        case .levelUp:
            return "level.fill"
        case .streakMilestone, .achievedStreak:
            return "flame.fill"
        case .challengeCompleted:
            return "star.fill"
        }
    }
}

struct AddFriendView: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.searchResults, id: \.userId) { user in
                    Button(action: {
                        Task {
                            await viewModel.sendFriendRequest(to: user.userId)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(user.username.prefix(1).uppercased())
                                        .fontWeight(.bold)
                                )
                            
                            Text(user.username)
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                Task {
                    await viewModel.searchUsers(query: newValue)
                }
            }
            .navigationTitle("Arkadaş Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SocialView()
} 