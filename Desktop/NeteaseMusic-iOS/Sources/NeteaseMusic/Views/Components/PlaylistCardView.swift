import SwiftUI

struct PlaylistCardView: View {
    let playlist: Playlist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CoverImage(url: playlist.coverImgURL, size: 160, cornerRadius: 12)
                .overlay(
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "play.fill")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                            Spacer()
                        }
                    }
                    .padding(8)
                )

            Text(playlist.name)
                .font(.subheadline.bold())
                .lineLimit(2)
                .frame(height: 38, alignment: .top)

            Text(playlist.formattedPlayCount)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
