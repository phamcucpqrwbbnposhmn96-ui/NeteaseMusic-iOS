import Foundation

struct Playlist: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let coverImgURL: String?
    let playCount: Int?
    let trackCount: Int
    let creator: User?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coverImgURL = "coverImgUrl"
        case playCount
        case trackCount
        case creator
        case description
    }

    var formattedPlayCount: String {
        guard let count = playCount else { return "0" }
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000)
        }
        return "\(count)"
    }
}

struct PlaylistDetail: Codable {
    let playlist: Playlist
    let tracks: [Song]?
}
