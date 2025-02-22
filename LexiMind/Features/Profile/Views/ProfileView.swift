import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Image
                        Image("BrainOnly")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top, 20)
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(Auth.auth().currentUser?.email ?? "Kullanıcı")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.textColor)
                            
                            Text("Seviye 1")
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        
                        // Statistics
                        HStack(spacing: 40) {
                            VStack {
                                Text("5")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Gün")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Text("150")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("XP")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Text("3")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Ders")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(themeManager.textColor)
                        .padding(.vertical)
                        
                        // Settings Menu
                        VStack(spacing: 16) {
                            ProfileMenuButton(icon: "person.fill", text: "Profili Düzenle")
                            ProfileMenuButton(icon: "bell.fill", text: "Bildirimler")
                            ProfileMenuButton(icon: "gear", text: "Ayarlar")
                            ProfileMenuButton(icon: "questionmark.circle.fill", text: "Yardım")
                        }
                        .padding(.top)
                        
                        // Sign Out Button
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            Text("Çıkış Yap")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(themeManager.inputBackgroundColor)
                                .cornerRadius(12)
                        }
                        .padding(.top, 32)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Çıkış Yapmak İstiyor musunuz?", isPresented: $showSignOutAlert) {
                Button("İptal", role: .cancel) { }
                Button("Çıkış Yap", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Hesabınızdan çıkış yapılacak. Tekrar giriş yapmanız gerekecek.")
            }
        }
    }
}

struct ProfileMenuButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.textColor)
                    .frame(width: 24)
                
                Text(text)
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding()
            .background(themeManager.inputBackgroundColor)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
} 