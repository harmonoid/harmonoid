import 'dart:convert';
import 'dart:io';

import 'package:connections/connections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/extensions/string.dart';
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
  static const String _kSubmitListensUrl = 'https://api.listenbrainz.org/1/submit-listens';
  static const String _kQueueFileName = 'listenbrainz_queue.json';

  // ListenBrainz API allows max 1,000 listens per import request and 1 request/second.
  static const int _kMaxListensPerRequest = 1000;
  static const Duration _kMinRequestInterval = Duration(seconds: 1);
  static const Duration _kFlushRetryCooldown = Duration(seconds: 30);

  static bool get supported => true;

  ListenBrainzMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      await _loadQueue();
      final session = Configuration.instance.listenbrainzSession;
      final connected = session.token.isNotEmpty;
      if (connected) {
        _instance.setSession(session);
        await _lock.synchronized(_flushQueue);
      }
      _lifecycleListener ??= AppLifecycleListener(
        onResume: () {
          if (_queue.isNotEmpty && _canRetryFlush()) {
            _lock.synchronized(_flushQueue);
          }
        },
      );
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  ListenBrainz get listenBrainz => _instance;

  @override
  Future<void> dispose() async {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
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

      // Periodically retry flushing queued offline listens.
      if (_queue.isNotEmpty && _canRetryFlush()) {
        await _flushQueue();
      }

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
            await _throttle();
            await _instance.submitListens(playingNowRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }

      if ((state.position > state.duration ~/ 2 || state.position > const Duration(minutes: 4)) && _lastSubmitted != _flagPlayable) {
        _lastSubmitted = _flagPlayable;

        final playable = _flagPlayable;
        final queuedListen = playable != null ? _QueuedListen.fromPlayable(playable, _lastTimestamp, state.duration) : null;

        // If older listens are still queued, append and flush together to preserve order.
        if (queuedListen != null && _queue.isNotEmpty) {
          await _enqueue(queuedListen);
          await _flushQueue();
          return;
        }

        final submitListensRequest = playable?.toListenbrainzSubmitListensRequest(_lastTimestamp, state.duration);
        if (submitListensRequest != null) {
          try {
            await _throttle();
            await _instance.submitListens(submitListensRequest);
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
            if (queuedListen != null) {
              await _enqueue(queuedListen);
            }
          }
        }
      }
    });
  }

  /// Ensures at least 1 second between consecutive ListenBrainz API requests.
  Future<void> _throttle() async {
    final last = _lastRequestAt;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _kMinRequestInterval) {
        await Future.delayed(_kMinRequestInterval - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }

  bool _canRetryFlush() {
    final last = _lastFlushAttemptAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= _kFlushRetryCooldown;
  }

  File get _queueFile => File(path.join(Configuration.instance.directory.path, _kQueueFileName));

  Future<void> _loadQueue() async {
    try {
      final file = _queueFile;
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _queue
          ..clear()
          ..addAll(decoded.whereType<Map<String, dynamic>>().map(_QueuedListen.fromJson));
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _saveQueue() async {
    try {
      final file = _queueFile;
      if (_queue.isEmpty) {
        if (await file.exists()) {
          await file.delete();
        }
        return;
      }
      await file.writeAsString(jsonEncode(_queue.map((e) => e.toJson()).toList()), flush: true);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _enqueue(_QueuedListen listen) async {
    _queue.add(listen);
    await _saveQueue();
  }

  /// Flushes queued listens in batches of up to 1,000 using `listen_type: import`.
  Future<void> _flushQueue() async {
    if (_queue.isEmpty) return;
    final token = _instance.session?.token;
    if (token == null || token.isEmpty) return;

    _lastFlushAttemptAt = DateTime.now();

    while (_queue.isNotEmpty) {
      final count = _queue.length > _kMaxListensPerRequest ? _kMaxListensPerRequest : _queue.length;
      final batch = _queue.take(count).toList();

      try {
        await _throttle();
        final response = await http.post(
          Uri.parse(_kSubmitListensUrl),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json; charset=utf-8',
            'User-Agent': kUserAgent,
          },
          body: jsonEncode({
            'listen_type': 'import',
            'payload': batch.map((e) => e.toListenbrainzJson()).toList(),
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _queue.removeRange(0, count);
          await _saveQueue();
        } else {
          debugPrint('ListenBrainz flush failed (${response.statusCode}): ${response.body}');
          break;
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        break;
      }
    }
  }

  final MediaPlayer _player;

  final ListenBrainz _instance = ListenBrainz(kDebugMode, kUserAgent);
  final Lock _lock = Lock();
  final List<_QueuedListen> _queue = [];

  AppLifecycleListener? _lifecycleListener;
  DateTime? _lastRequestAt;
  DateTime? _lastFlushAttemptAt;

  Playable? _flagPlayable;
  Duration? _flagDuration;

  DateTime? _lastTimestamp;
  Playable? _lastPlayingNow;
  Playable? _lastSubmitted;
}

class _QueuedListen {
  final String artist;
  final String track;
  final String? album;
  final int durationMs;
  final int listenedAt;

  const _QueuedListen({
    required this.artist,
    required this.track,
    required this.album,
    required this.durationMs,
    required this.listenedAt,
  });

  static _QueuedListen? fromPlayable(Playable playable, DateTime? timestamp, Duration? duration) {
    final artist = playable.subtitle.firstOrNull?.nullIfBlank();
    final album = playable.description.firstOrNull?.nullIfBlank();
    if (artist == null || timestamp == null || duration == null) return null;

    return _QueuedListen(
      artist: artist,
      track: playable.title,
      album: album,
      durationMs: duration.inMilliseconds,
      listenedAt: timestamp.millisecondsSinceEpoch ~/ 1000,
    );
  }

  factory _QueuedListen.fromJson(Map<String, dynamic> json) {
    return _QueuedListen(
      artist: json['artist'] as String,
      track: json['track'] as String,
      album: json['album'] as String?,
      durationMs: json['durationMs'] as int,
      listenedAt: json['listenedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'artist': artist,
        'track': track,
        if (album != null) 'album': album,
        'durationMs': durationMs,
        'listenedAt': listenedAt,
      };

  Map<String, dynamic> toListenbrainzJson() => {
        'listened_at': listenedAt,
        'track_metadata': {
          'artist_name': artist,
          'track_name': track,
          if (album != null) 'release_name': album,
          'additional_info': {
            'duration_ms': durationMs,
          },
        },
      };
}
