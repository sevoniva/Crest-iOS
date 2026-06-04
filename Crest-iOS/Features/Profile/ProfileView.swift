import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.userInfo?.name ?? appState.userInfo?.username ?? "未知用户")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(appState.userInfo?.username ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("账户信息") {
                if let email = appState.userInfo?.email {
                    Label(email, systemImage: "envelope")
                }
                if let phone = appState.userInfo?.phone {
                    Label(phone, systemImage: "phone")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        if let token = appState.token {
                            await AuthAPI.logout(token: token)
                        }
                        await MainActor.run {
                            appState.logout()
                        }
                    }
                } label: {
                    Label("退出登录", systemImage: "arrow.right.circle")
                }
            }
        }
        .navigationTitle("个人中心")
    }
}
