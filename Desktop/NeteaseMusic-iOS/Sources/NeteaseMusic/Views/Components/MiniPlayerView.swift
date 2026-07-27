import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var player: PlayerManager

    var body: some View {
        HStack(spacing: 12) {
            CoverImage(url: player.currentSong?.highQualityCoverURL, size: 44, cornerRadius: 8)
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.currentSong?.name ?? "未在播放")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(player.currentSong?.artistNames ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 20) {
                Button(action: { player.previous() }) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }

                Button(action: { player.togglePlay() }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.pink)
                }

                Button(action: { player.next() }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(height: 64)
        .contentShape(Rectangle())
        .onTapGesture {
            if player.currentSong != nil {
                player.isExpanded = true
            }
        }
    }
}
