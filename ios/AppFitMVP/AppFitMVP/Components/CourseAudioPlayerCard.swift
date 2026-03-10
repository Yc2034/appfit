import SwiftUI

struct CourseAudioPlayerCard: View {
    let track: CourseAudioGuide

    @StateObject private var player: AudioPlaybackManager

    init(track: CourseAudioGuide) {
        self.track = track
        _player = StateObject(wrappedValue: AudioPlaybackManager(track: track))
    }

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                HStack(spacing: AppLayout.space8) {
                    Image(systemName: "waveform")
                        .foregroundStyle(AppColor.accent)
                    Text(track.title)
                        .font(AppFont.headline())
                        .foregroundStyle(AppColor.textPrimary)
                }

                if player.isAvailable {
                    VStack(alignment: .leading, spacing: AppLayout.space10) {
                        Slider(
                            value: Binding(
                                get: { player.progressValue },
                                set: { player.seek(progress: $0) }
                            ),
                            in: 0...1
                        )
                        .tint(AppColor.accent)

                        HStack {
                            Text(player.timeString(for: player.currentTime))
                            Spacer()
                            Text(player.timeString(for: player.duration))
                        }
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)

                        HStack(spacing: AppLayout.space10) {
                            AppFitButton(
                                player.isPlaying ? "暂停" : "播放",
                                icon: player.isPlaying ? "pause.fill" : "play.fill"
                            ) {
                                player.togglePlayback()
                            }

                            AppFitButton("重播", icon: "gobackward", variant: .secondary) {
                                player.restart()
                            }
                        }
                    }
                } else {
                    Text(player.errorMessage ?? "音频暂不可用")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
}
