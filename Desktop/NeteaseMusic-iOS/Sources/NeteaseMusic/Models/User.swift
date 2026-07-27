import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: Int
    let nickname: String
    let avatarUrl: String?
    let signature: String?
}

struct LoginResponse: Codable {
    let code: Int
    let account: Account?
    let profile: User?
    let cookie: String?
    let message: String?
}

struct Account: Codable {
    let id: Int
    let userName: String?
}
