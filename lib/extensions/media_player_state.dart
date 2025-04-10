import 'package:path/path.dart';

import 'package:harmonoid/models/media_player_state.dart';

/// Extensions for [MediaPlayerState].
extension MediaPlayerStateExtensions on MediaPlayerState {
  bool get isEmpty => playables.isEmpty;

  bool get isNotEmpty => playables.isNotEmpty;

  bool get isFirst => isEmpty || index == 0;

  bool get isLast => isEmpty || index == playables.length - 1;

  String getAudioFormatLabel({
    bool format = true,
    bool bitrate = true,
    bool sampleRate = true,
    bool channelCount = true,
  }) {
    if (index < 0 || index > playables.length - 1) return '';

    String formatValue = '';
    String bitrateValue = '';
    String sampleRateValue = '';
    String channelCountValue = '';
    try {
      final format = extension(playables[index].uri).substring(1).toUpperCase();
      if (format.length <= 5) {
        formatValue = format;
      }
    } catch (_) {}
    try {
      if (audioBitrate > 0.0) {
        bitrateValue = '${audioBitrate ~/ 1000} kb/s';
      }
    } catch (_) {}
    try {
      if (audioParams.sampleRate != null) {
        sampleRateValue = '${(audioParams.sampleRate! / 1000).toStringAsFixed(1)} kHz';
      }
    } catch (_) {}
    try {
      if (audioParams.channelCount != null) {
        channelCountValue = {1: 'Mono', 2: 'Stereo'}[audioParams.channelCount!] ?? '${audioParams.channelCount} channels';
      }
    } catch (_) {}

    return [
      if (format && formatValue.isNotEmpty) formatValue,
      if (bitrate && bitrateValue.isNotEmpty) bitrateValue,
      if (sampleRate && sampleRateValue.isNotEmpty) sampleRateValue,
      if (channelCount && channelCountValue.isNotEmpty) channelCountValue,
    ].join(' • ');
  }
}
