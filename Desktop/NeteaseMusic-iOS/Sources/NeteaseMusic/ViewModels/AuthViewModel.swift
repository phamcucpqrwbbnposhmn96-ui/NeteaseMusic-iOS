import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cookieInput = ""

    // 手机号登录相关
    @Published var phone = ""
    @Published var password = ""
    @Published var captcha = ""
    @Published var captchaCountdown = 0

    init() {
        checkLoginStatus()
    }

    func checkLoginStatus() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await NeteaseMusicService.shared.loginStatus()
                if response.code == 200, let profile = response.profile {
                    currentUser = profile
                    isLoggedIn = true
                } else {
                    isLoggedIn = false
                }
            } catch {
                isLoggedIn = false
                errorMessage = "登录状态检查失败: \(error.localizedDescription)"
            }
        }
    }

    func loginWithCookie() {
        let cookie = cookieInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cookie.isEmpty else {
            errorMessage = "Cookie 不能为空"
            return
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await NeteaseMusicService.shared.loginWithCookie(cookie)
                if response.code == 200, let profile = response.profile {
                    currentUser = profile
                    isLoggedIn = true
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "登录失败，请检查 Cookie"
                }
            } catch {
                errorMessage = "登录失败: \(error.localizedDescription)"
            }
        }
    }

    func loginWithPhonePassword() {
        let phone = phone.trimmingCharacters(in: .whitespaces)
        let password = password
        guard !phone.isEmpty, !password.isEmpty else {
            errorMessage = "手机号和密码不能为空"
            return
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await NeteaseMusicService.shared.loginWithPhone(phone, password: password)
                if response.code == 200, let profile = response.profile {
                    currentUser = profile
                    isLoggedIn = true
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "登录失败"
                }
            } catch {
                errorMessage = "登录失败: \(error.localizedDescription)"
            }
        }
    }

    func sendCaptcha() {
        let phone = phone.trimmingCharacters(in: .whitespaces)
        guard phone.count == 11 else {
            errorMessage = "请输入 11 位手机号"
            return
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await NeteaseMusicService.shared.sendCaptcha(phone: phone)
                errorMessage = nil
                startCountdown()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func loginWithPhoneCaptcha() {
        let phone = phone.trimmingCharacters(in: .whitespaces)
        let captcha = captcha.trimmingCharacters(in: .whitespaces)
        guard !phone.isEmpty, !captcha.isEmpty else {
            errorMessage = "手机号和验证码不能为空"
            return
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await NeteaseMusicService.shared.loginWithCaptcha(phone: phone, captcha: captcha)
                if response.code == 200, let profile = response.profile {
                    currentUser = profile
                    isLoggedIn = true
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "登录失败"
                }
            } catch {
                errorMessage = "登录失败: \(error.localizedDescription)"
            }
        }
    }

    private func startCountdown() {
        captchaCountdown = 60
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.captchaCountdown -= 1
            if self.captchaCountdown <= 0 {
                timer.invalidate()
            }
        }
    }

    func logout() {
        NeteaseMusicService.shared.logout()
        isLoggedIn = false
        currentUser = nil
        cookieInput = ""
        phone = ""
        password = ""
        captcha = ""
    }
}
