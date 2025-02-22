import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published private(set) var currentColorScheme: ColorScheme = .light
    
    // Make initializer internal (default) for preview purposes
    init() {}
    
    func updateColorScheme(_ colorScheme: ColorScheme) {
        currentColorScheme = colorScheme
    }
    
    // MARK: - Theme Properties
    var backgroundColor: Color {
        currentColorScheme == .dark ? 
            Color(red: 0.13, green: 0.15, blue: 0.19) : // Dark mode - matte dark blue
            Color.white    // Light mode - white
    }
    
    var gradientColors: [Color] {
        currentColorScheme == .dark ?
            [Color(red: 0.13, green: 0.15, blue: 0.19),
             Color(red: 0.15, green: 0.17, blue: 0.22)] :
            [Color.white,
             Color.white.opacity(0.95)]
    }
    
    var textColor: Color {
        currentColorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        currentColorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var inputBackgroundColor: Color {
        currentColorScheme == .dark ?
            Color(red: 0.17, green: 0.19, blue: 0.24) : // Dark mode - slightly lighter than background
            Color(.systemGray6) // Light mode - system gray background
    }
    
    var accentColor: Color {
        Color(red: 29/255, green: 161/255, blue: 242/255) // Twitter blue for both modes
    }
}

// MARK: - Color Scheme Modifier
struct ColorSchemeModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                themeManager.updateColorScheme(colorScheme)
            }
            .onChange(of: colorScheme) { newColorScheme in
                themeManager.updateColorScheme(newColorScheme)
            }
    }
}

extension View {
    func syncColorScheme(with themeManager: ThemeManager) -> some View {
        modifier(ColorSchemeModifier(themeManager: themeManager))
    }
} 