import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showStreakView = false
    @State private var showGemsStore = false
    @State private var showHeartsView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Fixed top bar
                    VStack(spacing: 0) {
                        // Top Stats Bar
                        HStack(spacing: 20) {
                            // Course Button
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.book.closed.fill")
                                        .foregroundColor(.blue)
                                    Text("TR-EN")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.textColor)
                                }
                            }
                            
                            Spacer()
                            
                            // Streak Button
                            Button(action: { showStreakView = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("\(viewModel.streak)")
                                        .foregroundColor(themeManager.textColor)
                                }
                            }
                            
                            // Gems Button
                            Button(action: { showGemsStore = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "diamond.fill")
                                        .foregroundColor(.cyan)
                                    Text("1645")
                                        .foregroundColor(themeManager.textColor)
                                }
                            }
                            
                            // Hearts Button
                            Button(action: { showHeartsView = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("5")
                                        .foregroundColor(themeManager.textColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(themeManager.backgroundColor)
                        
                        // Separator line
                        Rectangle()
                            .fill(Color.gray.opacity(0.05))
                            .frame(height: 0.2)
                    }
                    
                    ScrollView {
                        VStack(spacing: 30) { // Increased spacing between sections
                            // Progress Section
                            VStack(alignment: .leading, spacing: 24) { // Increased internal spacing
                                Text("Günlük İlerleme")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.textColor)
                                
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 8)
                                            .opacity(0.3)
                                            .foregroundColor(.gray)
                                        
                                        Rectangle()
                                            .frame(width: min(CGFloat(viewModel.dailyProgress) * geometry.size.width, geometry.size.width), height: 8)
                                            .foregroundColor(themeManager.accentColor)
                                    }
                                    .cornerRadius(4)
                                }
                                .frame(height: 8)
                                
                                HStack {
                                    // Streak
                                    Label("\(viewModel.streak) gün", systemImage: "flame.fill")
                                        .foregroundColor(.orange)
                                    
                                    Spacer()
                                    
                                    // Remaining XP
                                    Label("\(viewModel.remainingXP) XP kaldı", systemImage: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Recommended Lessons
                            VStack(alignment: .leading, spacing: 24) {
                                Text("Önerilen Dersler")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(viewModel.recommendedLessons) { lesson in
                                            Button(action: {}) {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    HStack {
                                                        Image(systemName: lesson.type.icon)
                                                            .foregroundColor(themeManager.accentColor)
                                                        Text("\(Int(lesson.progress * 100))%")
                                                            .font(.caption)
                                                            .foregroundColor(themeManager.secondaryTextColor)
                                                    }
                                                    
                                                    Text(lesson.title)
                                                        .font(.headline)
                                                        .foregroundColor(themeManager.textColor)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    ProgressView(value: lesson.progress)
                                                        .tint(themeManager.accentColor)
                                                }
                                                .frame(width: 160)
                                                .padding()
                                                .background(themeManager.inputBackgroundColor)
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            
                            // AI Word Suggestions
                            VStack(alignment: .leading, spacing: 24) { // Increased internal spacing
                                Text("AI Kelime Önerileri")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.textColor)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(viewModel.aiSuggestions, id: \.self) { suggestion in
                                        Text(suggestion)
                                            .font(.body)
                                            .foregroundColor(themeManager.textColor)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(themeManager.inputBackgroundColor)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showStreakView) {
            StreakView()
                .background(themeManager.backgroundColor)
        }
        .sheet(isPresented: $showGemsStore) {
            StoreView()
                .background(themeManager.backgroundColor)
        }
        .sheet(isPresented: $showHeartsView) {
            HeartsView()
                .background(themeManager.backgroundColor)
        }
    }
}

// MARK: - Hearts View
struct HeartsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Hearts Display
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                    Text("You have full hearts")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    
                    // Unlimited Hearts Button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "infinity")
                            Text("UNLIMITED HEARTS")
                                .fontWeight(.bold)
                            Text("FREE TRIAL")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.teal, .purple], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Refill Hearts Button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("REFILL HEARTS")
                            Spacer()
                            Image(systemName: "diamond.fill")
                            Text("500")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.inputBackgroundColor)
                        .foregroundColor(themeManager.textColor)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Watch Ad Button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text("WATCH AD TO EARN HEARTS")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.inputBackgroundColor)
                        .foregroundColor(themeManager.textColor)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Hearts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.textColor)
                    }
                }
            }
        }
    }
}

// MARK: - Streak View
struct StreakView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab = 0
    @State private var currentMonth = Date()
    @State private var tabTextWidths: [CGFloat] = [0, 0]
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Custom Tab Selector
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(0..<2) { index in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = index
                                    }
                                }) {
                                    Text(index == 0 ? "Kişisel" : "Arkadaşlar")
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
                        TabIndicator(totalTabs: 2, selectedTab: selectedTab, tabTextWidths: tabTextWidths)
                            .padding(.horizontal)
                    }
                    
                    if selectedTab == 0 {
                        // Personal Streak
                        VStack(spacing: 30) {
                            Text("0")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(themeManager.textColor)
                            Text("günlük seri!")
                                .font(.title2)
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            // Calendar
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Şubat 2025")
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                    Spacer()
                                    Button(action: { }) {
                                        Image(systemName: "chevron.left")
                                    }
                                    Button(action: { }) {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                
                                // Stats
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading) {
                                        Text("2")
                                            .font(.title2.bold())
                                        Text("Pratik yapılan gün")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(themeManager.inputBackgroundColor)
                                    .cornerRadius(12)
                                    .overlay(
                                        Text("İYİ")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .offset(y: -12),
                                        alignment: .top
                                    )
                                    
                                    VStack(alignment: .leading) {
                                        Text("4")
                                            .font(.title2.bold())
                                        Text("Kullanılan dondurma")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(themeManager.inputBackgroundColor)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            
                            // Streak Society
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Seri Topluluğu")
                                    .font(.title3.bold())
                                    .foregroundColor(themeManager.textColor)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                    Text("7 günlük seriye ulaşarak Seri Topluluğuna katıl ve kazan")
                                        .font(.caption)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                            }
                            .padding()
                        }
                    } else {
                        // Friends Streak
                        Text("Yakında!")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Seri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.textColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(themeManager.textColor)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ThemeManager.shared)
} 
