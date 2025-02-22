import Foundation
import FirebaseFirestore
import FirebaseAuth

// Import models from the same module
@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var analytics: LearningAnalytics
    private let db: Firestore = Firestore.firestore()
    
    init() {
        // Initialize with empty data
        let defaultWordMap = WordMap(
            categories: [],
            connections: [:],
            mastery: []
        )
        
        let defaultCalendar = LearningCalendar(
            scheduledLessons: [],
            reviewSchedules: []
        )
        
        // Initialize with default values
        self.analytics = LearningAnalytics(
            userId: Auth.auth().currentUser?.uid ?? "",
            wordMap: defaultWordMap,
            calendar: defaultCalendar
        )
        
        Task {
            await refreshAnalytics()
        }
    }
    
    func refreshAnalytics() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Fetch user's learning analytics
            let analyticsDoc = try await db.collection("users")
                .document(userId)
                .collection("analytics")
                .document("overview")
                .getDocument()
            
            if let analytics = try? analyticsDoc.data(as: LearningAnalytics.self) {
                self.analytics = analytics
            }
        } catch {
            print("Error refreshing analytics: \(error)")
        }
    }
}

// MARK: - Errors
enum AnalyticsError: Error {
    case fetchFailed
    case invalidData
    case userNotAuthenticated
} 