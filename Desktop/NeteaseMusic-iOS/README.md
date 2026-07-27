# 云音 - 第三方网易云音乐 iOS 客户端

高颜值 SwiftUI 网易云音乐客户端，支持搜索、歌单、最近播放、私人 FM、电台、一起听。

## 项目结构

```
NeteaseMusic-iOS/
├── Sources/                 # Swift 源码
│   ├── NeteaseMusicApp.swift
│   ├── Models/             # 数据模型
│   ├── Services/           # 网络与播放器
│   ├── ViewModels/         # 状态管理
│   ├── Views/              # 界面
│   └── Utils/              # 常量
├── Resources/              # 图片资源
├── project.yml             # XcodeGen 项目配置
├── Package.swift           # Swift Package Manager
└── .github/workflows/      # GitHub Actions 自动打包
```

## 运行前准备

### 1. 部署后端 API

进入 `NeteaseMusic-API` 目录：

```bash
cd NeteaseMusic-API
npm install
npm start
```

默认运行在 `http://localhost:3000`。

如果你的 iPhone 和电脑不在同一台机器，需要把 `Sources/NeteaseMusic/Utils/Constants.swift` 里的 `apiBaseURL` 改成你电脑的局域网 IP，例如：

```swift
static let apiBaseURL = "http://192.168.1.5:3000/api"
```

### 2. 登录方式

App 支持三种登录方式：

- **手机号 + 验证码**（推荐）
- **手机号 + 密码**
- **网页 Cookie 登录**（备用）

登录成功后，后端会自动返回并保存 Cookie，后续所有请求都会自动带上。

## 无 Mac 安装到 iPhone（推荐方案）

没有 Mac 也能装到手机上，思路是：**GitHub Actions 出未签名 IPA → Sideloadly 免费签名安装**。

### 步骤 1：把代码传到 GitHub

```bash
cd /path/to/NeteaseMusic-iOS
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin https://github.com/你的用户名/NeteaseMusic-iOS.git
git push -u origin main
```

### 步骤 2：触发 GitHub Actions 打包

1. 打开 GitHub 仓库 → Actions → **Build Unsigned IPA**
2. 点击 **Run workflow**
3. 等待 10–20 分钟
4. 完成后在日志底部或 FILEBIN 下载 IPA

默认会上传到 FILEBIN：`https://filebin.net/neteasemusic-ios/NeteaseMusic-unsigned-XXX.ipa`

### 步骤 3：用 Sideloadly 签名安装（Windows 可用）

1. 电脑下载 [Sideloadly](https://sideloadly.io/)
2. iPhone 用数据线连电脑
3. 打开 Sideloadly，选择你的 iPhone
4. 把下载的 IPA 拖进去
5. 输入你的 Apple ID（普通免费账号即可）
6. 点击 Start，等待安装完成
7. 手机上 **设置 → 通用 → VPN 与设备管理** → 信任你的 Apple ID

> 免费 Apple ID 签名的 App **7 天后会过期**，到期需要重新用 Sideloadly 安装一次。

### 替代工具

- [AltStore](https://altstore.io/)
- [SideStore](https://github.com/SideStore/SideStore)

## 有 Mac 时的开发/打包

```bash
cd NeteaseMusic-iOS
brew install xcodegen
xcodegen generate
open NeteaseMusic.xcodeproj
```

在 Xcode 中修改 Bundle Identifier，登录 Apple ID，即可运行或 Archive 导出 IPA。

## 注意事项

- 本项目仅供个人学习和使用，请勿用于商业用途或上架 App Store。
- 部分歌曲可能因版权或会员限制无法播放。
- 一起听功能为简化实现，完整同步需要额外的 WebSocket 信令服务。
- 使用 Sideloadly 等工具安装属于个人侧载，请遵守当地法律法规。
