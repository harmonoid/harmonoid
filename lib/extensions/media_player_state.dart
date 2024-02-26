import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';

/// Extensions for [MediaPlayerState].
extension MediaPlayerStateExtensions on MediaPlayerState {
  /// Whether current list of [Playable]s is empty.
  bool get isEmpty => playables.isEmpty;

  /// Whether currently playing [Playable] is the first.
  bool get isFirst => index == 0;

  /// Whether currently playing [Playable] is the last.
  bool get isLast => index == playables.length - 1;

  /// Currently playing [Playable].
  Playable get current => playables[index];

  /// Audio format label.
  String getAudioFormatLabel({
    bool format = true,
    bool bitrate = true,
    bool sampleRate = true,
    bool channelCount = true,
  }) {
    if (index < 0 || index > playables.length - 1) return '';
    return [
      if (format && audioParams.format != null) audioParams.format!.toUpperCase(),
      if (bitrate && audioBitrate > 0.0) '${audioBitrate ~/ 1000} kb/s',
      if (sampleRate && audioParams.sampleRate != null) '${(audioParams.sampleRate! / 1000).toStringAsFixed(1)} kHz',
      if (channelCount && audioParams.channelCount != null) {1: 'Mono', 2: 'Stereo'}[audioParams.channelCount!] ?? '${audioParams.channelCount} channels',
    ].join(' • ');
  }
}
