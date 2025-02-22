import SwiftUI
import FirebaseAuth

struct EmailLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private var gradientColors: [Color] {
        colorScheme == .dark ? [
            Color(red: 0.13, green: 0.15, blue: 0.19),
            Color(red: 0.15, green: 0.17, blue: 0.22)
        ] : [.white, Color(.systemGray6)]
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var inputBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.17, green: 0.19, blue: 0.24) : Color(.systemGray6)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Tekrar Hoş Geldin!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                        
                        Text("Öğrenmeye devam edelim")
                            .font(.title3)
                            .foregroundColor(textColor.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        // Email
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(textColor.opacity(0.6))
                                .frame(width: 24)
                            
                            TextField("E-posta", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundColor(textColor)
                        }
                        .padding()
                        .background(inputBackgroundColor)
                        .cornerRadius(12)
                        
                        // Password with visibility toggle
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(textColor.opacity(0.6))
                                .frame(width: 24)
                            
                            if showPassword {
                                TextField("Şifre", text: $password)
                                    .foregroundColor(textColor)
                            } else {
                                SecureField("Şifre", text: $password)
                                    .foregroundColor(textColor)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(textColor.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(inputBackgroundColor)
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    
                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Login Button
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Giriş Yap")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 29/255, green: 161/255, blue: 242/255))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .padding(.top, 20)
                    .disabled(isLoading)
                    
                    // Forgot Password
                    Button("Şifremi Unuttum") {
                        // Handle password reset
                    }
                    .foregroundColor(Color(red: 29/255, green: 161/255, blue: 242/255))
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(textColor)
                }
            }
        }
    }
    
    private func signIn() {
        guard !email.isEmpty && !password.isEmpty else {
            showError(message: "Lütfen e-posta ve şifrenizi girin")
            return
        }
        
        isLoading = true
        showError = false
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                showError(message: error.localizedDescription)
            } else {
                authViewModel.isAuthenticated = true
                dismiss()
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    NavigationView {
        EmailLoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
    }
} 