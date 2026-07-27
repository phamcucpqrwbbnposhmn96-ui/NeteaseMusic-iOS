import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @State private var songs: [Song] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CoverImage(url: playlist.coverImgURL, size: 180, cornerRadius: 16)
                    .shadow(radius: 12)

                Text(playlist.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let desc = playlist.description {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .padding(.horizontal)
                }

                HStack(spacing: 20) {
                    Label(playlist.formattedPlayCount, systemImage: "play.fill")
                    Label("\(playlist.trackCount)首", systemImage: "music.note")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Button(action: { PlayerManager.shared.playQueue(songs) }) {
                    Label("播放全部", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(16)
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView()
                        .padding()
                }

                LazyVStack(spacing: 4) {
                    ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                        SongRowView(song: song, index: index + 1)
                            .onTapGesture {
                                PlayerManager.shared.playQueue(songs, startingAt: index)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("歌单详情")
        .background(Color(.systemGroupedBackground))
        .task {
            await loadSongs()
        }
    }

    private func loadSongs() async {
        isLoading = true
        defer { isLoading = false }
        do {
            songs = try await NeteaseMusicService.shared.playlistTracks(id: playlist.id)
        } catch {
            print("加载歌单失败: \(error)")
        }
    }
}
