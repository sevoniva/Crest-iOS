import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogoutConfirm = false
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                        
                        Text(initials)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.userInfo?.name ?? appState.userInfo?.username ?? "未知用户")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("管理员")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("账户信息") {
                if let username = appState.userInfo?.username {
                    LabeledContent("用户名", value: username)
                }
                if let email = appState.userInfo?.email {
                    LabeledContent("邮箱", value: email)
                }
                if let phone = appState.userInfo?.phone {
                    LabeledContent("电话", value: phone)
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showLogoutConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("退出登录")
                    }
                }
            }
        }
        .navigationTitle("个人中心")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog("确认退出？", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("退出登录", role: .destructive) {
                Task {
                    if let token = appState.token {
                        await AuthAPI.logout(token: token)
                    }
                    await MainActor.run {
                        appState.logout()
                    }
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("退出后将清除本地登录状态")
        }
    }
    
    private var initials: String {
        let name = appState.userInfo?.name ?? appState.userInfo?.username ?? "U"
        return String(name.prefix(1)).uppercased()
    }
}
