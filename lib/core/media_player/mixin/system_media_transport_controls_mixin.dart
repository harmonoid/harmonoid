import 'dart:io';

import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/mappers/image_provider.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:synchronized/synchronized.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

/// {@template system_media_transport_controls_mixin}
///
/// SystemMediaTransportControlsMixin
/// ---------------------------------
/// package:system_media_transport_controls mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin SystemMediaTransportControlsMixin implements BaseMediaPlayer {
  static bool get supported => Platform.isWindows;

  Future<void> ensureInitializedSystemMediaTransportControls() async {
    if (!supported) return;

    SystemMediaTransportControls.ensureInitialized();
    final instance = SystemMediaTransportControls.instance
      ..create((event) {
        switch (event) {
          case SMTCEvent.play:
            play();
          case SMTCEvent.pause:
            pause();
          case SMTCEvent.next:
            next();
          case SMTCEvent.previous:
            previous();
          default:
            break;
        }
      });

    _instanceSystemMediaTransportControls = instance;

    addListener(_listenerSystemMediaTransportControls);
  }

  Future<void> disposeSystemMediaTransportControls() async {
    if (!supported) return;
    _instanceSystemMediaTransportControls?.dispose();
  }

  void resetFlagsSystemMediaTransportControls() {
    _flagPlayableSystemMediaTransportControls = null;
  }

  void _listenerSystemMediaTransportControls() {
    _lockSystemMediaTransportControls.synchronized(() async {
      if (_flagPlayingSystemMediaTransportControls != state.playing) {
        _flagPlayingSystemMediaTransportControls = state.playing;
        _instanceSystemMediaTransportControls?.setStatus(state.playing ? SMTCStatus.playing : SMTCStatus.paused);
      }

      if (_flagPositionSystemMediaTransportControls != state.position) {
        _flagPositionSystemMediaTransportControls = state.position;
        _instanceSystemMediaTransportControls?.setTimelineData(endTime: state.duration.inMilliseconds, position: state.position.inMilliseconds);
      }

      if (_flagPlayableSystemMediaTransportControls != current) {
        _flagPlayableSystemMediaTransportControls = current;

        final image = cover(uri: current.uri);
        final artwork = await image.toResource();
        _instanceSystemMediaTransportControls
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

  SystemMediaTransportControls? _instanceSystemMediaTransportControls;
  final Lock _lockSystemMediaTransportControls = Lock();

  Playable? _flagPlayableSystemMediaTransportControls;
  bool? _flagPlayingSystemMediaTransportControls;
  Duration? _flagPositionSystemMediaTransportControls;
}
