import Foundation

actor NeteaseMusicService {
    static let shared = NeteaseMusicService()
    private init() {}

    private var cookie: String {
        UserDefaults.standard.string(forKey: "netease_cookie") ?? ""
    }

    private func request<T: Decodable>(
        module: String,
        method: String = "GET",
        params: [String: Any] = [:]
    ) async throws -> T {
        var components = URLComponents(string: Constants.apiBaseURL + "/" + module)!

        var queryItems: [URLQueryItem] = []
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(cookie, forHTTPHeaderField: "X-Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - 登录
    func loginStatus() async throws -> LoginResponse {
        try await request(module: "login_status")
    }

    func loginWithCookie(_ cookieString: String) async throws -> LoginResponse {
        UserDefaults.standard.set(cookieString, forKey: "netease_cookie")
        return try await loginStatus()
    }

    /// 手机号 + 密码登录
    func loginWithPhone(_ phone: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            module: "login_cellphone",
            params: ["phone": phone, "password": password]
        )
        if let cookie = response.cookie {
            UserDefaults.standard.set(cookie, forKey: "netease_cookie")
        }
        return response
    }

    /// 发送验证码
    func sendCaptcha(phone: String) async throws {
        struct CaptchaResponse: Decodable {
            let code: Int
            let message: String?
        }
        let response: CaptchaResponse = try await request(
            module: "captcha_sent",
            params: ["phone": phone]
        )
        guard response.code == 200 else {
            throw NSError(domain: "NeteaseMusic", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.message ?? "发送验证码失败"])
        }
    }

    /// 手机号 + 验证码登录
    func loginWithCaptcha(phone: String, captcha: String) async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            module: "login_cellphone",
            params: ["phone": phone, "captcha": captcha]
        )
        if let cookie = response.cookie {
            UserDefaults.standard.set(cookie, forKey: "netease_cookie")
        }
        return response
    }

    nonisolated func logout() {
        UserDefaults.standard.removeObject(forKey: "netease_cookie")
    }

    // MARK: - 用户信息
    func userDetail(uid: Int) async throws -> User {
        struct Response: Decodable {
            let profile: User
        }
        let result: Response = try await request(module: "user_detail", params: ["uid": uid])
        return result.profile
    }

    func userPlaylists(uid: Int) async throws -> [Playlist] {
        struct Response: Decodable {
            let playlist: [Playlist]
        }
        let result: Response = try await request(module: "user_playlist", params: ["uid": uid, "limit": 1000])
        return result.playlist
    }

    func recentSongs(limit: Int = 100) async throws -> [Song] {
        struct Response: Decodable {
            let data: [RecentSongItem]
        }
        struct RecentSongItem: Decodable {
            let resourceId: Int?
            let data: Song?
        }
        let result: Response = try await request(module: "record_recent_song", params: ["limit": limit])
        return result.data.compactMap { $0.data }
    }

    // MARK: - 歌单
    func playlistTracks(id: Int, limit: Int = 1000) async throws -> [Song] {
        struct Response: Decodable {
            let songs: [Song]
        }
        let result: Response = try await request(module: "playlist_track_all", params: ["id": id, "limit": limit])
        return result.songs
    }

    // MARK: - 搜索
    func search(keywords: String, type: Int = 1, limit: Int = 30, offset: Int = 0) async throws -> SearchResult {
        let response: SearchResponse = try await request(
            module: "search",
            params: ["keywords": keywords, "type": type, "limit": limit, "offset": offset]
        )
        return response.result ?? SearchResult(songs: nil, playlists: nil, artists: nil, albums: nil, songCount: 0)
    }

    // MARK: - 播放地址
    func songURL(id: Int, quality: Int = 999000) async throws -> String? {
        struct Response: Decodable {
            let data: [SongURLItem]
        }
        struct SongURLItem: Decodable {
            let id: Int
            let url: String?
        }
        let result: Response = try await request(module: "song_url", params: ["id": id, "br": quality])
        return result.data.first?.url
    }

    // MARK: - 歌词
    func lyrics(id: Int) async throws -> String {
        struct Response: Decodable {
            let lrc: LRC?
        }
        struct LRC: Decodable {
            let lyric: String?
        }
        let result: Response = try await request(module: "lyric", params: ["id": id])
        return result.lrc?.lyric ?? ""
    }

    // MARK: - 喜欢音乐
    func likeSong(id: Int, like: Bool = true) async throws {
        struct LikeResponse: Decodable {
            let code: Int
        }
        _ = try await request(
            module: "like",
            params: ["id": id, "like": like]
        ) as LikeResponse
    }

    // MARK: - 推荐 / FM
    func personalFM() async throws -> [Song] {
        struct Response: Decodable {
            let data: [Song]
        }
        let result: Response = try await request(module: "personal_fm")
        return result.data
    }

    func recommendSongs() async throws -> [Song] {
        struct Response: Decodable {
            let data: [DailyRecommendItem]
        }
        struct DailyRecommendItem: Decodable {
            let id: Int
            let name: String
            let ar: [Artist]
            let al: Album
            let dt: Int?
        }
        let result: Response = try await request(module: "recommend_songs")
        return result.data.map {
            Song(id: $0.id, name: $0.name, artists: $0.ar, album: $0.al, duration: $0.dt, coverURL: nil)
        }
    }

    // MARK: - 电台
    func djRecommend() async throws -> [Playlist] {
        struct Response: Decodable {
            let djRadios: [Playlist]
        }
        let result: Response = try await request(module: "dj_recommend")
        return result.djRadios
    }

    func djPrograms(rid: Int, limit: Int = 30) async throws -> [Song] {
        struct Response: Decodable {
            let programs: [DJProgram]
        }
        struct DJProgram: Decodable {
            let id: Int
            let name: String
            let dj: User
            let coverUrl: String?
            let mainSong: MainSong?
        }
        struct MainSong: Decodable {
            let id: Int
            let name: String
            let artists: [Artist]
            let duration: Int?
            let album: Album?
        }
        let result: Response = try await request(module: "dj_program", params: ["rid": rid, "limit": limit])
        return result.programs.compactMap { program in
            guard let mainSong = program.mainSong else { return nil }
            return Song(
                id: mainSong.id,
                name: mainSong.name,
                artists: mainSong.artists,
                album: mainSong.album,
                duration: mainSong.duration,
                coverURL: program.coverUrl
            )
        }
    }

    // MARK: - 一起听（简化版：获取状态/创建房间）
    func listenTogetherStatus() async throws -> ListenTogetherStatus {
        try await request(module: "listen_together_status")
    }
}

struct ListenTogetherStatus: Decodable {
    let code: Int
    let data: ListenTogetherData?
}

struct ListenTogetherData: Decodable {
    let roomId: String?
    let users: [ListenTogetherUser]?
}

struct ListenTogetherUser: Decodable {
    let userId: Int
    let nickname: String
    let avatarUrl: String?
}
