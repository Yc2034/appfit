import AVFoundation
import Foundation

@MainActor
final class AudioPlaybackManager: NSObject, ObservableObject {
    @Published private(set) var isAvailable: Bool = false
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var errorMessage: String?

    private let track: CourseAudioGuide
    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    init(track: CourseAudioGuide) {
        self.track = track
        super.init()
        prepareTrack()
    }

    deinit {
        progressTimer?.invalidate()
    }

    var progressValue: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    func togglePlayback() {
        guard isAvailable else { return }

        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func restart() {
        guard isAvailable, let player else { return }
        player.currentTime = 0
        currentTime = 0

        if !isPlaying {
            play()
        }
    }

    func seek(progress: Double) {
        guard isAvailable, let player, duration > 0 else { return }
        let clamped = min(max(progress, 0), 1)
        let targetTime = clamped * duration
        player.currentTime = targetTime
        currentTime = targetTime
    }

    func timeString(for value: TimeInterval) -> String {
        let totalSeconds = max(0, Int(value.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func play() {
        guard let player else { return }
        configureAudioSessionIfNeeded()
        player.play()
        isPlaying = true
        startTimer()
    }

    private func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    private func prepareTrack() {
        let name = (track.fileName as NSString).deletingPathExtension
        let ext = (track.fileName as NSString).pathExtension

        guard !name.isEmpty,
              !ext.isEmpty,
              let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            errorMessage = "未找到本地音频文件：\(track.fileName)"
            isAvailable = false
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            player = audioPlayer
            duration = audioPlayer.duration
            currentTime = audioPlayer.currentTime
            isAvailable = true
            errorMessage = nil
        } catch {
            errorMessage = "音频加载失败：\(error.localizedDescription)"
            isAvailable = false
        }
    }

    private func startTimer() {
        stopTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self, let player else { return }
            self.currentTime = player.currentTime

            if !player.isPlaying {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }

    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func configureAudioSessionIfNeeded() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Ignore audio session setup failures to avoid interrupting local playback attempts.
        }
    }
}
