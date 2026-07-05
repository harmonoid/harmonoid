import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/mappers/image_provider.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:synchronized/synchronized.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

/// {@template system_media_transport_controls_mixin}
///
/// SystemMediaTransportControlsMixin
/// ---------------------------------
/// package:system_media_transport_controls mixin for [MediaPlayer].
///
/// {@endtemplate}
final class SystemMediaTransportControlsMixin implements MediaPlayerMixin {
  static bool get supported => Platform.isWindows;

  SystemMediaTransportControlsMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    try {
      SystemMediaTransportControls.ensureInitialized();
      final instance = SystemMediaTransportControls.instance
        ..create((event) {
          switch (event) {
            case SMTCEvent.play:
              _player.play();
            case SMTCEvent.pause:
              _player.pause();
            case SMTCEvent.next:
              _player.next();
            case SMTCEvent.previous:
              _player.previous();
            default:
              break;
          }
        });

      _instance = instance;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Future<void> dispose() async {
    _instance?.dispose();
  }

  @override
  Future<void> resetFlags() async {
    _flagPlayable = null;
    _flagPlaying = null;
    _flagPosition = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    return _lock.synchronized(() async {
      final current = _player.current;
      if (_flagPlaying != state.playing) {
        _flagPlaying = state.playing;
        _instance?.setStatus(state.playing ? SMTCStatus.playing : SMTCStatus.paused);
      }

      if (_flagPosition != state.position) {
        _flagPosition = state.position;
        _instance?.setTimelineData(endTime: state.duration.inMilliseconds, position: state.position.inMilliseconds);
      }

      if (_flagPlayable != current) {
        _flagPlayable = current;

        final image = cover(uri: current.uri);
        final artwork = await image.toResource();
        _instance
          ?..setMusicData(
            albumTitle: current.description.firstOrNull,
            albumArtist: current.subtitle.firstOrNull,
            artist: current.subtitle.join(', '),
            title: current.title,
          )
          ..setArtwork(artwork);
      }
    });
  }

  final MediaPlayer _player;

  SystemMediaTransportControls? _instance;
  final Lock _lock = Lock();

  Playable? _flagPlayable;
  bool? _flagPlaying;
  Duration? _flagPosition;
}
