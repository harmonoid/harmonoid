import 'package:harmonoid/models/media_player_state.dart';

/// {@template media_player_mixin}
///
/// MediaPlayerMixin
/// ----------------
/// Extension unit registered with the media player.
///
/// {@endtemplate}
abstract interface class MediaPlayerMixin {
  Future<void> ensureInitialized();

  Future<void> dispose();

  Future<void> notifyState(MediaPlayerState state);

  Future<void> resetFlags();
}
