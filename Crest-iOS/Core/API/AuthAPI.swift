import Foundation

enum AuthAPI {
    static func getPublicKey() async throws -> String {
        let response: PublicKeyResponse = try await APIService.shared.get(path: "/public-key")
        guard response.code == 0, let key = response.data else {
            throw APIError.serverError("获取公钥失败")
        }
        return key
    }
    
    static func login(username: String, password: String) async throws -> (token: String, userInfo: UserInfo) {
        let publicKey = try await getPublicKey()
        
        guard let encryptedPassword = RSAEncryptor.encrypt(string: password, publicKey: publicKey) else {
            throw APIError.serverError("密码加密失败")
        }
        
        let request = LoginRequest(username: username, password: encryptedPassword)
        let response: LoginResponse = try await APIService.shared.post(path: "/login/local-login", body: request)
        
        guard response.code == 0,
              let data = response.data,
              let token = data.token else {
            throw APIError.serverError(response.message ?? "登录失败")
        }
        
        let userInfo = try await getUserInfo(token: token)
        return (token, userInfo)
    }
    
    static func getUserInfo(token: String) async throws -> UserInfo {
        let response: UserInfoResponse = try await APIService.shared.get(path: "/user/info", token: token)
        guard response.code == 0, let userInfo = response.data else {
            throw APIError.serverError("获取用户信息失败")
        }
        return userInfo
    }
    
    static func logout(token: String) async {
        _ = try? await APIService.shared.get(path: "/logout", token: token)
    }
}
