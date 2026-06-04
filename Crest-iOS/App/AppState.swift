import SwiftUI
import Observation

@Observable
final class AppState {
    var isLoggedIn: Bool {
        didSet {
            if isLoggedIn {
                token = TokenStorage.loadToken()
            }
        }
    }
    
    var token: String?
    var userInfo: UserInfo?
    
    init() {
        self.token = TokenStorage.loadToken()
        self.isLoggedIn = token != nil && !token!.isEmpty
    }
    
    func login(token: String, userInfo: UserInfo) {
        self.token = token
        self.userInfo = userInfo
        self.isLoggedIn = true
        TokenStorage.saveToken(token)
    }
    
    func logout() {
        self.token = nil
        self.userInfo = nil
        self.isLoggedIn = false
        TokenStorage.deleteToken()
    }
}
