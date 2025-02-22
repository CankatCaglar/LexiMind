import SwiftUI

struct LessonCard: View {
    let lesson: LessonItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Type
            HStack {
                Image(systemName: lesson.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Progress indicator
                Text("\(Int(lesson.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Title
            Text(lesson.title)
                .font(.headline)
                .lineLimit(2)
            
            // Progress Bar
            ProgressView(value: lesson.progress)
                .tint(.blue)
        }
        .padding()
        .frame(width: 160, height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    LessonCard(lesson: LessonItem(
        id: 1,
        title: "Temel Kelimeler",
        type: .vocabulary,
        progress: 0.3
    ))
} 