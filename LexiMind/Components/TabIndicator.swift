import SwiftUI

struct TabWidth: Equatable {
    let index: Int
    let width: CGFloat
}

struct TabWidthPreferenceKey: PreferenceKey {
    static var defaultValue: [TabWidth] = []
    
    static func reduce(value: inout [TabWidth], nextValue: () -> [TabWidth]) {
        value.append(contentsOf: nextValue())
    }
}

struct TabIndicator: View {
    let totalTabs: Int
    let selectedTab: Int
    let tabTextWidths: [CGFloat]
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let tabWidth = totalWidth / CGFloat(totalTabs)
            let currentTabWidth = tabTextWidths[selectedTab]
            let indicatorWidth = max(currentTabWidth * 0.7, 40) // 70% of text width, minimum 40
            
            // Calculate cumulative widths before the selected tab
            let previousTabsWidth = (0..<selectedTab).reduce(0) { sum, index in
                sum + tabWidth
            }
            
            // Calculate the center position of the current tab
            let tabCenter = previousTabsWidth + (tabWidth / 2)
            
            // Center the indicator around the tab center
            let indicatorOffset = tabCenter - (indicatorWidth / 2)
            
            Rectangle()
                .fill(Color(red: 0.11, green: 0.69, blue: 0.96)) // Duolingo blue
                .frame(width: indicatorWidth, height: 3)
                .offset(x: indicatorOffset)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
        }
        .frame(height: 3)
    }
} 