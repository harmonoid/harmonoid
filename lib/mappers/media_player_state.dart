import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/playback_state.dart';

/// Mappers for [MediaPlayerState].
extension MediaPlayerStateMappers on MediaPlayerState {
  /// Converts to [PlaybackState].
  PlaybackState toPlaybackState() => PlaybackState(
    index: index,
    playables: playables,
    rate: rate,
    pitch: pitch,
    volume: volume,
    shuffle: shuffle,
    loop: loop,
    replayGain: replayGain,
    replayGainPreamp: replayGainPreamp,
    crossfadeDuration: crossfadeDuration,
  );
}
