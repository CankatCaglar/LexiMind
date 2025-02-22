import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    Text("Pratik")
                        .font(.largeTitle)
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Text("Yakında...")
                        .font(.title)
                        .foregroundColor(themeManager.secondaryTextColor)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PracticeView()
        .environmentObject(ThemeManager.shared)
} 