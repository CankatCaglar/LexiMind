import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let backgroundColor: UIColor
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.2)
            
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    TabBarItem(
                        isSelected: selectedTab == index,
                        icon: getIcon(for: index),
                        onTap: { selectedTab = index }
                    )
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
        .background(Color(backgroundColor))
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "book.fill"
        case 2: return "mic.fill"
        case 3: return "trophy.fill"
        case 4: return "person.fill"
        default: return "house.fill"
        }
    }
}

struct TabBarItem: View {
    let isSelected: Bool
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(isSelected ? Color(red: 88/255, green: 204/255, blue: 2/255) : Color(red: 180/255, green: 180/255, blue: 180/255))
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0), backgroundColor: .systemBackground)
} 