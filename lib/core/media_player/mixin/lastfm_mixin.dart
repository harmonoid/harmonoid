import 'package:flutter/foundation.dart';
import 'package:lastfm/lastfm.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/models/playable.dart';

/// {@template Lastfm_mixin}
///
/// LastFmMixin
/// -----------
/// Last.fm mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin LastFmMixin implements BaseMediaPlayer {
  static const String kApiKey = String.fromEnvironment('LASTFM_API_KEY');
  static const String kSharedSecret = String.fromEnvironment('LASTFM_SHARED_SECRET');

  static bool get supported => true;

  Future<void> ensureInitializedLastFm() async {
    if (!supported) return;

    try {
      final session = Configuration.instance.lastfmSession;
      final connected = session.key.isNotEmpty;
      if (connected) {
        _instanceLastFm.setSession(session);
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    addListener(_listenerLastFm);
  }

  LastFm get lastFm => _instanceLastFm;

  Future<void> disposeLastFm() async {
    if (!supported) return;
    _instanceLastFm.clearSession();
  }

  void resetFlagsLastFm() {
    _flagPlayableLastFm = null;
  }

  void _listenerLastFm() {
    // https://www.last.fm/api/scrobbling#when-is-a-scrobble-a-scrobble

    _lockLastFm.synchronized(() async {
      final connected = _instanceLastFm.session?.key.isNotEmpty ?? false;
      if (!connected) return;

      if ((_flagIndexLastFm != state.index || _flagPlayableLastFm != current) && _flagDurationLastFm != state.duration && state.position > const Duration(seconds: 5)) {
        _flagIndexLastFm = state.index;
        _flagPlayableLastFm = current;
        _flagDurationLastFm = state.duration;

        _lastTimestampLastFm = DateTime.now().subtract(state.position);
        _lastDurationLastFm = state.duration;
      }

      if (state.playing && _lastUpdateNowPlayingLastFm != _flagPlayableLastFm) {
        _lastUpdateNowPlayingLastFm = _flagPlayableLastFm;

        final updateNowPlayingRequest = _lastUpdateNowPlayingLastFm?.toUpdateNowPlayingRequest(_lastDurationLastFm);
        if (updateNowPlayingRequest != null) {
          try {
            await _instanceLastFm.updateNowPlaying(updateNowPlayingRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }

      if ((state.completed || state.position > state.duration ~/ 2 || state.position > const Duration(minutes: 4)) && _lastScrobbledLastFm != _flagPlayableLastFm) {
        _lastScrobbledLastFm = _flagPlayableLastFm;

        final scrobbleRequest = _flagPlayableLastFm?.toScrobbleRequest(_lastTimestampLastFm, _lastDurationLastFm);
        if (scrobbleRequest != null) {
          try {
            await _instanceLastFm.scrobble(scrobbleRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }
    });
  }

  final LastFm _instanceLastFm = LastFm(kApiKey, kSharedSecret, true);
  final Lock _lockLastFm = Lock();

  int? _flagIndexLastFm;
  Playable? _flagPlayableLastFm;
  Duration? _flagDurationLastFm;

  DateTime? _lastTimestampLastFm;
  Duration? _lastDurationLastFm;
  Playable? _lastUpdateNowPlayingLastFm;
  Playable? _lastScrobbledLastFm;
}
