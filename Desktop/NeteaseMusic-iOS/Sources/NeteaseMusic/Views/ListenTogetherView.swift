import SwiftUI

struct ListenTogetherView: View {
    @State private var status: ListenTogetherStatus?
    @State private var isLoading = false
    @State private var roomId = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "person.2.wave.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink)

                Text("一起听")
                    .font(.largeTitle.bold())

                Text("和好友同步听歌、切歌、暂停")
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 16) {
                    Button(action: { createRoom() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("创建房间")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(16)
                    }

                    HStack {
                        TextField("输入房间号加入", text: $roomId)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)

                        Button(action: { joinRoom() }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.pink)
                        }
                    }
                }
                .padding(.horizontal)

                if let status = status, let data = status.data, let users = data.users {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("当前房间: \(data.roomId ?? "未知")")
                            .font(.headline)
                        ForEach(users, id: \.userId) { user in
                            HStack {
                                CoverImage(url: user.avatarUrl, size: 40, cornerRadius: 20)
                                Text(user.nickname)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                if isLoading {
                    ProgressView()
                }

                Spacer()
            }
            .navigationTitle("一起听")
            .background(Color(.systemGroupedBackground))
        }
    }

    private func createRoom() {
        Task {
            isLoading = true
            defer { isLoading = false }
            status = try? await NeteaseMusicService.shared.listenTogetherStatus()
        }
    }

    private func joinRoom() {
        guard !roomId.isEmpty else { return }
        // 实际实现需要调用 join 接口，这里仅作占位
        Task {
            isLoading = true
            defer { isLoading = false }
            status = try? await NeteaseMusicService.shared.listenTogetherStatus()
        }
    }
}
