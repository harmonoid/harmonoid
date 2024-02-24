import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';

/// Mappers for [MediaPlayerState].
extension MediaPlayerStateExtension on MediaPlayerState {
  /// Convert to [PlaybackState].
  PlaybackState toPlaybackState() => PlaybackState(
        index: index,
        playables: playables,
        rate: rate,
        pitch: pitch,
        volume: volume,
        shuffle: shuffle,
        loop: loop,
      );

  /// Currently playing [Playable].
  Playable get current => playables[index];

  /// Whether currently playing [Playable] is the first.
  bool get first => index == 0;

  /// Whether currently playing [Playable] is the last.
  bool get last => index == playables.length - 1;
}
