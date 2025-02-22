import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Performans").tag(0)
                    Text("Kelime Haritası").tag(1)
                    Text("Takvim").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    PerformanceView(analytics: viewModel.analytics)
                        .tag(0)
                    
                    WordMapView(wordMap: viewModel.analytics.wordMap)
                        .tag(1)
                    
                    LearningCalendarView(calendar: viewModel.analytics.calendar)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Öğrenme Analizi")
            .refreshable {
                await viewModel.refreshAnalytics()
            }
        }
    }
}

struct PerformanceView: View {
    let analytics: LearningAnalytics
    @State private var timeRange: TimeRange = .week
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Trends Chart
                ChartSection(title: "Öğrenme Trendleri") {
                    ForEach(analytics.trends) { trend in
                        Chart(Array(zip(trend.labels, trend.data)), id: \.0) { item in
                            LineMark(
                                x: .value("Tarih", item.0),
                                y: .value("Değer", item.1)
                            )
                            .foregroundStyle(Color.blue.gradient)
                        }
                        .frame(height: 200)
                    }
                }
                
                // Weak Areas
                VStack(alignment: .leading, spacing: 10) {
                    Text("Geliştirilmesi Gereken Alanlar")
                        .font(.headline)
                    
                    ForEach(analytics.weakAreas) { area in
                        WeakAreaRow(area: area)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding()
        }
    }
}

struct WordMapView: View {
    let wordMap: WordMap
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Categories Progress
                ChartSection(title: "Kategori İlerlemesi") {
                    ForEach(wordMap.categories) { category in
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.subheadline)
                            
                            HStack {
                                Text("\(category.words.count) kelime")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("Seviye \(category.level)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                }
                
                // Word Mastery
                VStack(alignment: .leading, spacing: 10) {
                    Text("Kelime Hakimiyeti")
                        .font(.headline)
                    
                    ForEach(wordMap.mastery) { mastery in
                        WordMasteryRow(mastery: mastery)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding()
        }
    }
}

struct LearningCalendarView: View {
    let calendar: LearningCalendar
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Scheduled Lessons
                VStack(alignment: .leading, spacing: 10) {
                    Text("Planlanan Dersler")
                        .font(.headline)
                    
                    ForEach(calendar.scheduledLessons) { lesson in
                        ScheduledLessonRow(lesson: lesson)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
                
                // Review Schedule
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tekrar Programı")
                        .font(.headline)
                    
                    ForEach(calendar.reviewSchedules) { review in
                        ReviewScheduleRow(review: review)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding()
        }
    }
}

// Helper Views
struct ChartSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct WeakAreaRow: View {
    let area: WeakArea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(area.category.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            ProgressView(value: area.accuracy)
                .tint(.orange)
            
            Text("Önerilen Egzersizler:")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                ForEach(area.recommendedExercises, id: \.self) { exercise in
                    Text(exercise)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct WordMasteryRow: View {
    let mastery: WordMastery
    
    var body: some View {
        HStack {
            Text(mastery.word)
                .font(.subheadline)
            
            Spacer()
            
            Text(mastery.level.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(mastery.level.color.opacity(0.1))
                .foregroundColor(mastery.level.color)
                .cornerRadius(8)
        }
    }
}

struct ScheduledLessonRow: View {
    let lesson: ScheduledLesson
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(lesson.datetime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            PriorityBadge(priority: lesson.priority)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ReviewScheduleRow: View {
    let review: ReviewSchedule
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(review.words.count) Kelime")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(review.scheduledDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(review.type.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(8)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct PriorityBadge: View {
    let priority: Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(getPriorityColor().opacity(0.1))
            .foregroundColor(getPriorityColor())
            .cornerRadius(8)
    }
    
    private func getPriorityColor() -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

enum TimeRange {
    case week
    case month
    case year
}

#Preview {
    AnalyticsView()
} 