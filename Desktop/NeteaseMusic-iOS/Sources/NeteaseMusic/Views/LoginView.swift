import SwiftUI

enum LoginMethod: String, CaseIterable {
    case captcha = "验证码登录"
    case password = "密码登录"
    case cookie = "Cookie登录"
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedMethod: LoginMethod = .captcha

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.2), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "music.note.list")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)

                Text(Constants.appName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("第三方网易云音乐客户端")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                VStack(spacing: 16) {
                    Picker("登录方式", selection: $selectedMethod) {
                        ForEach(LoginMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .colorMultiply(.white)

                    switch selectedMethod {
                    case .captcha:
                        captchaLoginForm
                    case .password:
                        passwordLoginForm
                    case .cookie:
                        cookieLoginForm
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
    }

    private var captchaLoginForm: some View {
        VStack(spacing: 12) {
            TextField("手机号", text: $auth.phone)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)

            HStack(spacing: 12) {
                TextField("验证码", text: $auth.captcha)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)

                Button(action: { auth.sendCaptcha() }) {
                    Text(auth.captchaCountdown > 0 ? "\(auth.captchaCountdown)s" : "获取验证码")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(width: 100)
                        .padding(.vertical, 12)
                        .background(auth.captchaCountdown > 0 ? Color.gray : Color.pink)
                        .cornerRadius(12)
                }
                .disabled(auth.captchaCountdown > 0 || auth.phone.count != 11)
            }

            Button(action: { auth.loginWithPhoneCaptcha() }) {
                HStack {
                    if auth.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("登录")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(16)
            }
            .disabled(auth.isLoading)
        }
    }

    private var passwordLoginForm: some View {
        VStack(spacing: 12) {
            TextField("手机号", text: $auth.phone)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)

            SecureField("密码", text: $auth.password)
                .textContentType(.password)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)

            Button(action: { auth.loginWithPhonePassword() }) {
                HStack {
                    if auth.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("登录")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(16)
            }
            .disabled(auth.isLoading)
        }
    }

    private var cookieLoginForm: some View {
        VStack(spacing: 12) {
            TextEditor(text: $auth.cookieInput)
                .frame(height: 100)
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(12)
                .foregroundStyle(.primary)

            Text("在 music.163.com 登录后，复制完整 Cookie 字符串")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(action: { auth.loginWithCookie() }) {
                HStack {
                    if auth.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Cookie 登录")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(16)
            }
            .disabled(auth.isLoading)
        }
    }
}
