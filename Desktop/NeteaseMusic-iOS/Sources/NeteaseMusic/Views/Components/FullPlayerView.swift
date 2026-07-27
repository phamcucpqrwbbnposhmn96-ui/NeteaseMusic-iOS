import SwiftUI

struct FullPlayerView: View {
    @EnvironmentObject var player: PlayerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.2), Color.purple.opacity(0.15), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Text("正在播放")
                        .font(.subheadline.bold())
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)

                Spacer()

                CoverImage(url: player.currentSong?.highQualityCoverURL, size: 280, cornerRadius: 24)
                    .shadow(radius: 24)

                VStack(spacing: 8) {
                    Text(player.currentSong?.name ?? "")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text(player.currentSong?.artistNames ?? "")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 16) {
                    Slider(value: $player.playbackProgress, in: 0...1) { editing in
                        if !editing {
                            player.seek(to: player.playbackProgress)
                        }
                    }
                    .tint(.white)

                    HStack {
                        Text(formatTime(player.currentTime))
                        Spacer()
                        Text(formatTime(player.duration))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal)

                HStack(spacing: 48) {
                    Button(action: { player.previous() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }

                    Button(action: { player.togglePlay() }) {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.white)
                    }

                    Button(action: { player.next() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
    }

    private func formatTime(_ time: Double) -> String {
        let total = Int(time)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
