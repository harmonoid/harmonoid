import 'package:harmonoid/localization/localization.dart';
import 'package:path/path.dart';

import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/media_player_state.dart';

/// Extensions for [MediaPlayerState].
extension MediaPlayerStateExtensions on MediaPlayerState {
  bool get isEmpty => playables.isEmpty;

  bool get isNotEmpty => playables.isNotEmpty;

  bool get isFirst => isEmpty || (loop == Loop.all ? false : index == 0);

  bool get isLast => isEmpty || (loop == Loop.all ? false : index == playables.length - 1);

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
        channelCountValue = switch (audioParams.channelCount!) {
          1 => Localization.instance.MONO,
          2 => Localization.instance.STEREO,
          _ => Localization.instance.N_CHANNELS.replaceAll('"N"', audioParams.channelCount.toString()),
        };
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
