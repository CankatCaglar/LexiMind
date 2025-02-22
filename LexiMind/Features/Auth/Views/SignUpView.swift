import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    init() {}
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: themeManager.gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Hoş Geldin!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.textColor)
                            
                            Text("Hadi öğrenmeye başlayalım")
                                .font(.title3)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.top, 40)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Username
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(themeManager.textColor.opacity(0.6))
                                    .frame(width: 24)
                                
                                TextField("Kullanıcı Adı", text: $username)
                                    .foregroundColor(themeManager.textColor)
                            }
                            .padding()
                            .background(themeManager.inputBackgroundColor)
                            .cornerRadius(12)
                            
                            // Email
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(themeManager.textColor.opacity(0.6))
                                    .frame(width: 24)
                                
                                TextField("E-posta", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .foregroundColor(themeManager.textColor)
                            }
                            .padding()
                            .background(themeManager.inputBackgroundColor)
                            .cornerRadius(12)
                            
                            // Password
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(themeManager.textColor.opacity(0.6))
                                    .frame(width: 24)
                                
                                if showPassword {
                                    TextField("Şifre", text: $password)
                                        .foregroundColor(themeManager.textColor)
                                } else {
                                    SecureField("Şifre", text: $password)
                                        .foregroundColor(themeManager.textColor)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(themeManager.textColor.opacity(0.6))
                                }
                            }
                            .padding()
                            .background(themeManager.inputBackgroundColor)
                            .cornerRadius(12)
                            
                            // Confirm Password
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(themeManager.textColor.opacity(0.6))
                                    .frame(width: 24)
                                
                                if showConfirmPassword {
                                    TextField("Şifreyi Tekrarla", text: $confirmPassword)
                                        .foregroundColor(themeManager.textColor)
                                } else {
                                    SecureField("Şifreyi Tekrarla", text: $confirmPassword)
                                        .foregroundColor(themeManager.textColor)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(themeManager.textColor.opacity(0.6))
                                }
                            }
                            .padding()
                            .background(themeManager.inputBackgroundColor)
                            .cornerRadius(12)
                        }
                        .padding(.top, 20)
                        
                        // Error Message
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Sign Up Button
                        Button(action: signUp) {
                            Text("Kaydol")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 29/255, green: 161/255, blue: 242/255))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .padding(.top, 20)
                        
                        // Terms and Privacy
                        Text("Kaydolarak Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz.")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.textColor)
                    }
                }
            }
        }
    }
    
    private func signUp() {
        // Validate fields
        guard !username.isEmpty else {
            showError(message: "Lütfen kullanıcı adı girin")
            return
        }
        
        guard !email.isEmpty else {
            showError(message: "Lütfen e-posta adresinizi girin")
            return
        }
        
        guard !password.isEmpty else {
            showError(message: "Lütfen şifrenizi girin")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "Şifreler eşleşmiyor")
            return
        }
        
        // Call sign up method
        Task {
            do {
                try await authViewModel.signUp(email: email, password: password, username: username)
                dismiss()
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
} 