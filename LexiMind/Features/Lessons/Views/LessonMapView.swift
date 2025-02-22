import SwiftUI

struct LessonMapView: View {
    @StateObject private var viewModel = LessonMapViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(viewModel.lessonUnits) { unit in
                            LessonUnitView(unit: unit)
                        }
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct LessonUnitView: View {
    let unit: LessonUnit
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Unit Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(unit.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    if unit.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                // Unit Progress
                ProgressView(value: unit.progress)
                    .tint(themeManager.accentColor)
            }
            
            // Lessons Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(unit.lessons) { lesson in
                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                        LessonNodeView(lesson: lesson)
                    }
                    .disabled(!lesson.isUnlocked)
                }
            }
        }
    }
}

struct LessonNodeView: View {
    let lesson: Lesson
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Lesson Icon
            ZStack {
                Circle()
                    .fill(lesson.isUnlocked ? themeManager.accentColor : themeManager.inputBackgroundColor)
                    .frame(width: 60, height: 60)
                
                Image(systemName: lesson.type.icon)
                    .font(.title2)
                    .foregroundColor(lesson.isUnlocked ? .white : themeManager.secondaryTextColor)
            }
            
            // Lesson Title
            Text(lesson.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(lesson.isUnlocked ? themeManager.textColor : themeManager.secondaryTextColor)
            
            if lesson.isCompleted {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .opacity(lesson.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Preview
#Preview {
    LessonMapView()
        .environmentObject(ThemeManager.shared)
} 