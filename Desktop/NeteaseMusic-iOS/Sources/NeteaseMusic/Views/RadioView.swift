import SwiftUI

struct RadioView: View {
    @State private var fmSongs: [Song] = []
    @State private var djRadios: [Playlist] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    sectionTitle("私人 FM")

                    if !fmSongs.isEmpty {
                        VStack(spacing: 16) {
                            CoverImage(url: fmSongs.first?.highQualityCoverURL, size: 200, cornerRadius: 20)
                                .shadow(radius: 16)

                            if let first = fmSongs.first {
                                Text(first.name)
                                    .font(.title2.bold())
                                Text(first.artistNames)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 40) {
                                Button(action: { loadFM() }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }

                                Button(action: {
                                    PlayerManager.shared.playQueue(fmSongs)
                                }) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.pink)
                                }

                                Button(action: {
                                    Task {
                                        try? await NeteaseMusicService.shared.likeSong(id: fmSongs.first?.id ?? 0)
                                        loadFM()
                                    }
                                }) {
                                    Image(systemName: "heart.fill")
                                        .font(.title2)
                                        .foregroundStyle(.pink)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .padding(.horizontal)
                    }

                    if !djRadios.isEmpty {
                        sectionTitle("推荐电台")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(djRadios) { radio in
                                PlaylistCardView(playlist: radio)
                                    .onTapGesture {
                                        Task {
                                            let songs = try? await NeteaseMusicService.shared.djPrograms(rid: radio.id)
                                            if let songs = songs, !songs.isEmpty {
                                                PlayerManager.shared.playQueue(songs)
                                            }
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
            .navigationTitle("电台")
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

        async let fmTask = NeteaseMusicService.shared.personalFM()
        async let djTask = NeteaseMusicService.shared.djRecommend()

        do {
            let (fm, radios) = try await (fmTask, djTask)
            fmSongs = fm
            djRadios = radios
        } catch {
            print("加载电台失败: \(error)")
        }
    }

    private func loadFM() {
        Task {
            isLoading = true
            defer { isLoading = false }
            fmSongs = (try? await NeteaseMusicService.shared.personalFM()) ?? []
        }
    }
}
