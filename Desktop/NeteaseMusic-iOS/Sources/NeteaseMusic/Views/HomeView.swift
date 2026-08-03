import SwiftUI

struct HomeView: View {
    @State private var recommendSongs: [Song] = []
    @State private var recentSongs: [Song] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !recentSongs.isEmpty {
                        sectionTitle("最近播放")
                        SongCarousel(songs: recentSongs)
                    }

                    if !recommendSongs.isEmpty {
                        sectionTitle("每日推荐")
                        LazyVStack(spacing: 8) {
                            ForEach(recommendSongs.prefix(10)) { song in
                                SongRowView(song: song, showMenu: false)
                                    .onTapGesture {
                                        if let index = recommendSongs.firstIndex(where: { $0.id == song.id }) {
                                            PlayerManager.shared.playQueue(recommendSongs, startingAt: index)
                                        }
                                    }
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
            .navigationTitle("发现音乐")
            .background(Color(.systemGroupedBackground))
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .padding(.horizontal)
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        async let recentTask = NeteaseMusicService.shared.recentSongs(limit: 20)
        async let recommendTask = NeteaseMusicService.shared.recommendSongs()

        do {
            let (recent, recommend) = try await (recentTask, recommendTask)
            recentSongs = recent
            recommendSongs = recommend
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SongCarousel: View {
    let songs: [Song]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(songs) { song in
                    VStack(alignment: .leading, spacing: 8) {
                        CoverImage(url: song.highQualityCoverURL, size: 140)
                        Text(song.name)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text(song.artistNames)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 140)
                    .onTapGesture {
                        PlayerManager.shared.playQueue(songs, startingAt: songs.firstIndex(where: { $0.id == song.id }) ?? 0)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
