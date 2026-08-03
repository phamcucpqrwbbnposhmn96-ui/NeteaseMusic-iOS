import SwiftUI

struct SearchView: View {
    @State private var keyword = ""
    @State private var songs: [Song] = []
    @State private var playlists: [Playlist] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $keyword, onSubmit: performSearch)
                    .padding()

                if isSearching {
                    ProgressView()
                        .padding()
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if !songs.isEmpty {
                            sectionHeader("歌曲")
                            ForEach(songs) { song in
                                SongRowView(song: song)
                                    .onTapGesture {
                                        if let index = songs.firstIndex(where: { $0.id == song.id }) {
                                            PlayerManager.shared.playQueue(songs, startingAt: index)
                                        }
                                    }
                            }
                        }

                        if !playlists.isEmpty {
                            sectionHeader("歌单")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(playlists) { playlist in
                                    PlaylistCardView(playlist: playlist)
                                }
                            }
                            .padding(.horizontal)
                        }

                        if songs.isEmpty && playlists.isEmpty && !keyword.isEmpty && !isSearching {
                            ContentUnavailableView("无结果", systemImage: "magnifyingglass")
                        }
                    }
                }
            }
            .navigationTitle("搜索")
            .background(Color(.systemGroupedBackground))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func performSearch() {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        Task {
            isSearching = true
            defer { isSearching = false }

            do {
                async let songsTask = NeteaseMusicService.shared.search(keywords: trimmed, type: 1, limit: 30)
                async let playlistsTask = NeteaseMusicService.shared.search(keywords: trimmed, type: 1000, limit: 10)
                let (songResult, playlistResult) = try await (songsTask, playlistsTask)
                songs = songResult.songs ?? []
                playlists = playlistResult.playlists ?? []
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索歌曲、歌单、歌手", text: $text)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
