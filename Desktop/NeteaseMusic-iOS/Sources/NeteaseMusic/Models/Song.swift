import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let artists: [Artist]
    let album: Album?
    let duration: Int?
    let coverURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists = "ar"
        case album = "al"
        case duration = "dt"
        case coverURL
    }

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    var formattedDuration: String {
        guard let duration = duration, duration > 0 else { return "00:00" }
        let seconds = duration / 1000
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var highQualityCoverURL: String? {
        guard let url = coverURL ?? album?.picUrl else { return nil }
        return url.replacingOccurrences(of: "http://", with: "https://")
    }
}

struct Artist: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
}

struct Album: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let picUrl: String?
}
