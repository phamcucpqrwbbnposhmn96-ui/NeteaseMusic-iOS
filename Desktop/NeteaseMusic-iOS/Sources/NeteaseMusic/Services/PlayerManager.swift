import Foundation
import AVFoundation
import Combine
import MediaPlayer

@MainActor
final class PlayerManager: ObservableObject {
    static let shared = PlayerManager()

    @Published var currentSong: Song?
    @Published var isPlaying = false
    @Published var playbackProgress: Double = 0
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var queue: [Song] = []
    @Published var currentIndex: Int = 0
    @Published var isExpanded = false

    private var player: AVPlayer?
    private var timeObserver: Any?

    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous()
            return .success
        }
    }

    func play(song: Song, queue: [Song] = [], index: Int = 0) {
        self.currentSong = song
        self.queue = queue.isEmpty ? [song] : queue
        self.currentIndex = index
        loadAndPlay(song: song)
    }

    func playQueue(_ songs: [Song], startingAt index: Int = 0) {
        guard index < songs.count else { return }
        self.queue = songs
        self.currentIndex = index
        play(song: songs[index], queue: songs, index: index)
    }

    private func loadAndPlay(song: Song) {
        Task {
            do {
                guard let urlString = try await NeteaseMusicService.shared.songURL(id: song.id),
                      let url = URL(string: urlString) else {
                    print("无法获取歌曲播放地址")
                    return
                }

                let item = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: item)
                player?.play()
                isPlaying = true
                observeProgress()
                updateNowPlayingInfo()
            } catch {
                print("播放失败: \(error)")
            }
        }
    }

    private func observeProgress() {
        removeTimeObserver()
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let currentItem = self.player?.currentItem else { return }
            self.currentTime = time.seconds
            self.duration = currentItem.duration.isNumeric ? currentItem.duration.seconds : 0
            self.playbackProgress = self.duration > 0 ? self.currentTime / self.duration : 0
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func togglePlay() {
        isPlaying ? pause() : play()
    }

    func next() {
        guard !queue.isEmpty else { return }
        let nextIndex = (currentIndex + 1) % queue.count
        currentIndex = nextIndex
        play(song: queue[nextIndex], queue: queue, index: nextIndex)
    }

    func previous() {
        guard !queue.isEmpty else { return }
        let prevIndex = (currentIndex - 1 + queue.count) % queue.count
        currentIndex = prevIndex
        play(song: queue[prevIndex], queue: queue, index: prevIndex)
    }

    func seek(to progress: Double) {
        guard let player = player, duration > 0 else { return }
        let targetTime = CMTime(seconds: progress * duration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: targetTime)
    }

    private func updateNowPlayingInfo() {
        var info: [String: Any] = [:]
        if let song = currentSong {
            info[MPMediaItemPropertyTitle] = song.name
            info[MPMediaItemPropertyArtist] = song.artistNames
            info[MPMediaItemPropertyPlaybackDuration] = duration
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
