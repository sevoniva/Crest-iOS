import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    
    @State private var username = "admin"
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Crest")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("数据可视化平台")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                TextField("用户名", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("密码", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 32)
            }
            
            Button {
                Task {
                    await login()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("登录")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 32)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            
            Spacer()
        }
        .alert("登录失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "未知错误")
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
                showError = true
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
}
