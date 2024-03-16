import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playback_state.dart';

/// Mappers for [PlaybackState].
extension PlaybackStateMappers on PlaybackState {
  /// Convert to [MediaPlayerState].
  MediaPlayerState toMediaPlayerState() => MediaPlayerState.defaults().copyWith(
        index: index,
        playables: playables,
        rate: rate,
        pitch: pitch,
        volume: volume,
        shuffle: shuffle,
        loop: loop,
      );
}
