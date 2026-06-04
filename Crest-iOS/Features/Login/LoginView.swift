import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    
    @State private var username = "admin"
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Crest")
                    .font(.system(size: 36, weight: .bold))
                
                Text("数据可视化平台")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 48)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户名")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                    
                    TextField("请输入用户名", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("密码")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                    
                    SecureField("请输入密码", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 32)
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 32)
                .padding(.top, 12)
            }
            
            Button {
                Task { await login() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("登录")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            .opacity(isLoading || username.isEmpty || password.isEmpty ? 0.6 : 1)
            
            Spacer()
            
            Text("© 2026 Sevoniva. All rights reserved.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 24)
        }
        .alert("登录失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "未知错误，请重试")
        }
        .onSubmit {
            if focusedField == .username {
                focusedField = .password
            } else if focusedField == .password {
                Task { await login() }
            }
        }
    }
    
    private func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await AuthAPI.login(username: username, password: password)
            await MainActor.run {
                appState.login(token: result.token, userInfo: result.userInfo)
                isLoading = false
            }
        } catch APIError.serverError(let msg) {
            await MainActor.run {
                errorMessage = msg
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "网络异常，请检查连接"
                isLoading = false
            }
        }
    }
}
