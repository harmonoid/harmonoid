import 'package:flutter/foundation.dart';
import 'package:lastfm/lastfm.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';

/// {@template Lastfm_mixin}
///
/// LastFmMixin
/// -----------
/// Last.fm mixin for [MediaPlayer].
///
/// {@endtemplate}
final class LastFmMixin implements MediaPlayerMixin {
  static const String kApiKey = String.fromEnvironment('LASTFM_API_KEY');
  static const String kSharedSecret = String.fromEnvironment('LASTFM_SHARED_SECRET');

  static bool get supported => true;

  LastFmMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      final session = Configuration.instance.lastfmSession;
      final connected = session.key.isNotEmpty;
      if (connected) {
        _instance.setSession(session);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  LastFm get lastFm => _instance;

  @override
  Future<void> dispose() async {
    _instance.clearSession();
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagDuration = null;
    _lastTimestamp = null;
    _lastUpdateNowPlaying = null;
    _lastScrobbled = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    // https://www.last.fm/api/scrobbling#when-is-a-scrobble-a-scrobble

    return _lock.synchronized(() async {
      final connected = _instance.session?.key.isNotEmpty ?? false;
      if (!connected) return;

      // Not eligible for Last.fm scrobbling.
      if (state.duration < const Duration(seconds: 30)) return;

      final current = _player.current;

      // Last 5s window: Reset playable.
      final isLast5SWindow = state.duration - state.position < const Duration(seconds: 5);
      if (isLast5SWindow) {
        // Reset the previous flags.
        // This allows scrobbling the same playable again (w/ Loop.one).
        _flagPlayable = null;
        _flagDuration = null;
        _lastTimestamp = DateTime.now();
        _lastUpdateNowPlaying = null;
        _lastScrobbled = null;
        // Allow scrobbling again when we escape this window.
        return;
      }

      // First 5s window: Reset playable.
      final isPlayableNotSet = _flagPlayable == null;
      final isPlayableChangedInFirst5SWindow =
          _flagPlayable != current && _flagDuration != state.duration && state.duration > Duration.zero && state.position > Duration.zero && state.position < const Duration(seconds: 5);
      if (isPlayableNotSet || isPlayableChangedInFirst5SWindow) {
        _flagPlayable = current;
        _flagDuration = state.duration;

        _lastTimestamp = DateTime.now().subtract(state.position);
      }

      if (state.playing && _lastUpdateNowPlaying != _flagPlayable) {
        _lastUpdateNowPlaying = _flagPlayable;

        final updateNowPlayingRequest = _lastUpdateNowPlaying?.toUpdateNowPlayingRequest(state.duration);
        if (updateNowPlayingRequest != null) {
          try {
            await _instance.updateNowPlaying(updateNowPlayingRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }

      if ((state.position > state.duration ~/ 2 || state.position > const Duration(minutes: 4)) && _lastScrobbled != _flagPlayable) {
        _lastScrobbled = _flagPlayable;

        final scrobbleRequest = _flagPlayable?.toScrobbleRequest(_lastTimestamp, state.duration);
        if (scrobbleRequest != null) {
          try {
            await _instance.scrobble(scrobbleRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }
    });
  }

  final MediaPlayer _player;

  final LastFm _instance = LastFm(kApiKey, kSharedSecret, kDebugMode);
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  Duration? _flagDuration;

  DateTime? _lastTimestamp;
  Playable? _lastUpdateNowPlaying;
  Playable? _lastScrobbled;
}
