import Foundation

struct SearchResponse: Codable {
    let result: SearchResult?
    let code: Int?
}

struct SearchResult: Codable {
    let songs: [Song]?
    let playlists: [Playlist]?
    let artists: [Artist]?
    let albums: [Album]?
    let songCount: Int?
}
