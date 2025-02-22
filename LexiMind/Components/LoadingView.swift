import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.7)
    }
    
    private var containerColor: Color {
        colorScheme == .dark ? Color(red: 0.13, green: 0.15, blue: 0.19) : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(textColor)
                
                Text("Yükleniyor...")
                    .font(.headline)
                    .foregroundColor(textColor)
            }
            .padding(30)
            .background(containerColor)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
        }
    }
}

#Preview {
    Group {
        LoadingView()
            .preferredColorScheme(.light)
        
        LoadingView()
            .preferredColorScheme(.dark)
    }
} 