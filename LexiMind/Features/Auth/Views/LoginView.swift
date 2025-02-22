import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSignUp = false
    @State private var showEmailLogin = false
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var gradientColors: [Color] {
        colorScheme == .dark ? [
            Color(red: 0.13, green: 0.15, blue: 0.19),  // Koyu mavi-gri
            Color(red: 0.15, green: 0.17, blue: 0.22)   // Biraz daha açık mavi-gri
        ] : [.white, Color(.systemGray6)]
    }
    
    init() {}
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App Icon with animation
                    Image("BrainOnly")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                    
                    // App Name
                    Text("LexiMind")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Text("Dil Öğrenmenin Yeni Yolu")
                        .font(.title3)
                        .foregroundColor(textColor.opacity(0.8))
                    
                    Spacer()
                    
                    // Login Buttons
                    VStack(spacing: 16) {
                        // Apple Login
                        Button(action: { authViewModel.signInWithApple() }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .imageScale(.medium)
                                Text("Apple ile Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(colorScheme == .dark ? Color.white : Color.black)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Google Login
                        Button(action: { authViewModel.signInWithGoogle() }) {
                            HStack {
                                Image("GoogleIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Google ile Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 234/255, green: 67/255, blue: 53/255))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Email Login
                        NavigationLink(destination: EmailLoginView()) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .imageScale(.medium)
                                Text("E-posta ile Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 29/255, green: 161/255, blue: 242/255))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Sign Up Button
                        Button(action: { showSignUp = true }) {
                            Text("Hesabın yok mu? Kaydol")
                                .fontWeight(.medium)
                                .foregroundColor(textColor)
                        }
                        .padding(.top, 8)
                        .disabled(authViewModel.isLoading)
                    }
                    .padding(.horizontal, 24)
                    .opacity(authViewModel.isLoading ? 0.6 : 1.0)
                    
                    Spacer()
                    
                    // Terms and Conditions
                    Text("Giriş yaparak Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz.")
                        .font(.caption)
                        .foregroundColor(textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
                
                // Loading overlay
                if authViewModel.isLoading {
                    LoadingView()
                        .transition(.opacity)
                }
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

#Preview {
    Group {
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
            .preferredColorScheme(.light)
        
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
            .preferredColorScheme(.dark)
    }
} 