import SwiftUI

struct StoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Gems
                        VStack(spacing: 8) {
                            Image(systemName: "diamond.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.cyan)
                            Text("1645")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(themeManager.textColor)
                            Text("Gems")
                                .font(.headline)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.vertical)
                        
                        // Gem Packages
                        VStack(spacing: 16) {
                            // Best Value Package
                            GemPackageButton(
                                gems: 2000,
                                price: "$9.99",
                                isBestValue: true,
                                action: {}
                            )
                            
                            // Other Packages
                            GemPackageButton(
                                gems: 1000,
                                price: "$4.99",
                                action: {}
                            )
                            
                            GemPackageButton(
                                gems: 500,
                                price: "$2.99",
                                action: {}
                            )
                            
                            GemPackageButton(
                                gems: 200,
                                price: "$0.99",
                                action: {}
                            )
                        }
                        .padding(.horizontal)
                        
                        // Free Gems Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Free Gems")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.textColor)
                                .padding(.horizontal)
                            
                            // Watch Ad Button
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "play.rectangle.fill")
                                    Text("Watch Ad")
                                    Spacer()
                                    Image(systemName: "diamond.fill")
                                        .foregroundColor(.cyan)
                                    Text("5")
                                        .foregroundColor(.cyan)
                                }
                                .padding()
                                .background(themeManager.inputBackgroundColor)
                                .cornerRadius(12)
                            }
                            .foregroundColor(themeManager.textColor)
                            .padding(.horizontal)
                            
                            // Complete Challenges Button
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text("Complete Challenges")
                                    Spacer()
                                    Image(systemName: "diamond.fill")
                                        .foregroundColor(.cyan)
                                    Text("10-50")
                                        .foregroundColor(.cyan)
                                }
                                .padding()
                                .background(themeManager.inputBackgroundColor)
                                .cornerRadius(12)
                            }
                            .foregroundColor(themeManager.textColor)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Store")
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

struct GemPackageButton: View {
    let gems: Int
    let price: String
    var isBestValue: Bool = false
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Gems amount
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.cyan)
                    Text("\(gems)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                Spacer()
                
                // Price
                Text(price)
                    .font(.headline)
                    .foregroundColor(themeManager.textColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.inputBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isBestValue ? Color.cyan : Color.clear, lineWidth: 2)
                    )
            )
        }
        .overlay(
            Group {
                if isBestValue {
                    Text("BEST VALUE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan)
                        .cornerRadius(8)
                        .offset(y: -12)
                }
            },
            alignment: .top
        )
    }
}

#Preview {
    StoreView()
        .environmentObject(ThemeManager.shared)
} 