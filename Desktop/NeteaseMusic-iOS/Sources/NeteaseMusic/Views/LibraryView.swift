import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var playlists: [Playlist] = []
    @State private var likedSongs: [Song] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = auth.currentUser {
                        HStack(spacing: 16) {
                            CoverImage(url: user.avatarUrl, size: 80, cornerRadius: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.nickname)
                                    .font(.title2.bold())
                                Text(user.signature ?? "暂无签名")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    if !likedSongs.isEmpty {
                        sectionTitle("我喜欢的音乐")
                        LazyVStack(spacing: 4) {
                            ForEach(likedSongs.prefix(20)) { song in
                                SongRowView(song: song)
                                    .onTapGesture {
                                        PlayerManager.shared.playQueue(likedSongs, startingAt: likedSongs.firstIndex(where: { $0.id == song.id }) ?? 0)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !playlists.isEmpty {
                        sectionTitle("我的歌单")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(playlists) { playlist in
                                NavigationLink(value: playlist) {
                                    PlaylistCardView(playlist: playlist)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("音乐库")
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: Playlist.self) { playlist in
                PlaylistDetailView(playlist: playlist)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("退出") {
                        auth.logout()
                    }
                }
            }
            .task {
                await loadLibrary()
            }
            .refreshable {
                await loadLibrary()
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .padding(.horizontal)
    }

    private func loadLibrary() async {
        guard let uid = auth.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let lists = try await NeteaseMusicService.shared.userPlaylists(uid: uid)
            playlists = lists

            if let likedList = lists.first(where: { $0.name.contains("我喜欢的音乐") }) {
                let songs = try await NeteaseMusicService.shared.playlistTracks(id: likedList.id)
                likedSongs = songs
            }
        } catch {
            print("加载音乐库失败: \(error)")
        }
    }
}
