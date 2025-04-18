import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playback_state.dart';

/// Mappers for [MediaPlayerState].
extension MediaPlayerStateMappers on MediaPlayerState {
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
}
