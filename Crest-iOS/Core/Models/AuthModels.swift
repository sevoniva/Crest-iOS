import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let code: Int
    let data: LoginData?
    let message: String?
}

struct LoginData: Codable {
    let token: String?
    let exp: TimeInterval?
}

struct PublicKeyResponse: Codable {
    let code: Int
    let data: String?
}

struct UserInfo: Codable {
    let id: Int?
    let username: String?
    let name: String?
    let email: String?
    let phone: String?
    let avatar: String?
}

struct UserInfoResponse: Codable {
    let code: Int
    let data: UserInfo?
}
