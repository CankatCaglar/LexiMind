import SwiftUI
import FirebaseCore
import Kingfisher
import SwiftMessages

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 200 // 200 MB
        
        SwiftMessages.defaultConfig.presentationStyle = .top
        SwiftMessages.defaultConfig.duration = .seconds(seconds: 3)
        
        return true
    }
}

@main
struct LexiMindApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var isAnimating = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    SplashScreenView()
                        .environmentObject(themeManager)
                } else {
                    if authViewModel.isAuthenticated {
                        ZStack(alignment: .bottom) {
                            TabView(selection: $selectedTab) {
                                DashboardView()
                                    .tabItem {
                                        Image(systemName: "house")
                                            .environment(\.symbolVariants, .fill)
                                            .imageScale(.large)
                                    }
                                    .tag(0)
                                
                                LessonMapView()
                                    .tabItem {
                                        Image(systemName: "book.pages.fill")
                                            .imageScale(.large)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.green)
                                    }
                                    .tag(1)
                                
                                PracticeView()
                                    .tabItem {
                                        Image(systemName: "waveform.circle")
                                            .environment(\.symbolVariants, .fill)
                                            .imageScale(.large)
                                    }
                                    .tag(2)
                                
                                SocialView()
                                    .tabItem {
                                        Image(systemName: "chart.bar.fill")
                                            .environment(\.symbolVariants, .fill)
                                            .imageScale(.large)
                                    }
                                    .tag(3)
                                
                                ProfileView()
                                    .tabItem {
                                        Image(systemName: "person")
                                            .environment(\.symbolVariants, .fill)
                                            .imageScale(.large)
                                    }
                                    .tag(4)
                            }
                            .tint(Color(red: 0.35, green: 0.8, blue: 0.3))
                            
                            // Tab bar separator line
                            Rectangle()
                                .frame(height: 0.3)
                                .foregroundColor(Color.gray.opacity(0.15))
                                .offset(y: -49)
                        }
                        .environmentObject(authViewModel)
                        .environmentObject(themeManager)
                    } else {
                        LoginView()
                            .environmentObject(authViewModel)
                            .environmentObject(themeManager)
                    }
                }
            }
            .syncColorScheme(with: themeManager)
            .onAppear {
                // Splash screen duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct SplashScreenView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var scale = 0.7
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Solid background color
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // App Icon - colorful brain image
                Image("BrainOnly")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                
                Spacer()
                
                // App Name at bottom
                Text("LexiMind")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.textColor)
                    .padding(.bottom, 40)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}
