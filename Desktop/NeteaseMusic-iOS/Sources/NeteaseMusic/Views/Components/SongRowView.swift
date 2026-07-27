import SwiftUI

struct SongRowView: View {
    let song: Song
    var index: Int? = nil
    var showMenu: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            if let index = index {
                Text("\(index)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .center)
            } else {
                CoverImage(url: song.highQualityCoverURL, size: 50, cornerRadius: 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(song.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(song.artistNames)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if showMenu {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
