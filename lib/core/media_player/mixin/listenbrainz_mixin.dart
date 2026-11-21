import 'package:connections/connections.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';
import 'package:harmonoid/core/media_player/models/playable.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template listenbrainz_mixin}
///
/// ListenBrainzMixin
/// -----------------
/// ListenBrainz mixin for [MediaPlayer].
///
/// {@endtemplate}
final class ListenBrainzMixin implements MediaPlayerMixin {
  static const String kUserAgent = 'Harmonoid/$kVersion (https://harmonoid.com)';

  static bool get supported => true;

  ListenBrainzMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      final session = Configuration.instance.listenbrainzSession;
      final connected = session.token.isNotEmpty;
      if (connected) {
        _instance.setSession(session);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  ListenBrainz get listenBrainz => _instance;

  @override
  Future<void> dispose() async {
    _instance.clearSession();
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagDuration = null;
    _lastTimestamp = null;
    _lastPlayingNow = null;
    _lastSubmitted = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    // https://listenbrainz.readthedocs.io/en/latest/users/api/core.html

    return _lock.synchronized(() async {
      final connected = _instance.session?.token.isNotEmpty ?? false;
      if (!connected) return;

      // Not eligible for ListenBrainz submission.
      if (state.duration < const Duration(seconds: 30)) return;

      final current = _player.current;

      // Last 5s window: Reset playable.
      final isLast5SWindow = state.duration - state.position < const Duration(seconds: 5);
      if (isLast5SWindow) {
        // Reset the previous flags.
        // This allows submitting the same playable again (w/ Loop.one).
        _flagPlayable = null;
        _flagDuration = null;
        _lastTimestamp = DateTime.now();
        _lastPlayingNow = null;
        _lastSubmitted = null;
        // Allow submitting again when we escape this window.
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

      if (state.playing && _lastPlayingNow != _flagPlayable) {
        _lastPlayingNow = _flagPlayable;

        final playingNowRequest = _lastPlayingNow?.toListenbrainzPlayingNowRequest(state.duration);
        if (playingNowRequest != null) {
          try {
            await _instance.submitListens(playingNowRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }

      if ((state.position > state.duration ~/ 2 || state.position > const Duration(minutes: 4)) && _lastSubmitted != _flagPlayable) {
        _lastSubmitted = _flagPlayable;

        final submitListensRequest = _flagPlayable?.toListenbrainzSubmitListensRequest(_lastTimestamp, state.duration);
        if (submitListensRequest != null) {
          try {
            await _instance.submitListens(submitListensRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }
    });
  }

  final MediaPlayer _player;

  final ListenBrainz _instance = ListenBrainz(kDebugMode, kUserAgent);
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  Duration? _flagDuration;

  DateTime? _lastTimestamp;
  Playable? _lastPlayingNow;
  Playable? _lastSubmitted;
}
