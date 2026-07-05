import 'package:flutter/foundation.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/audio_service_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/audio_session_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/discord_rpc_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/history_playlist_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/lastfm_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/mpris_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/system_media_transport_controls_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/windows_taskbar_mixin.dart';
import 'package:harmonoid/core/media_player/models/media_player_state.dart';

/// {@template media_player_mixin_registry}
///
/// MediaPlayerMixinRegistry
/// ------------------------
/// Registry for the supported media player mixins.
///
/// {@endtemplate}
final class MediaPlayerMixinRegistry {
  MediaPlayerMixinRegistry(MediaPlayer player) {
    _mixins.addAll(
      [
        if (AudioServiceMixin.supported) AudioServiceMixin(player),
        if (AudioSessionMixin.supported) AudioSessionMixin(player),
        if (DiscordRpcMixin.supported) DiscordRpcMixin(player),
        if (HistoryPlaylistMixin.supported) HistoryPlaylistMixin(player),
        if (LastFmMixin.supported) LastFmMixin(player),
        if (MprisMixin.supported) MprisMixin(player),
        if (SystemMediaTransportControlsMixin.supported) SystemMediaTransportControlsMixin(player),
        if (WindowsTaskbarMixin.supported) WindowsTaskbarMixin(player),
      ],
    );
  }

  Future<void> ensureInitialized() {
    return Future.wait(_mixins.map((mixin) => _runCatching(mixin.ensureInitialized)));
  }

  Future<void> dispose() {
    return Future.wait(_mixins.map((mixin) => _runCatching(mixin.dispose)));
  }

  Future<void> notifyState(MediaPlayerState state) {
    return Future.wait(_mixins.map((mixin) => _runCatching(() => mixin.notifyState(state))));
  }

  Future<void> resetFlags() {
    return Future.wait(_mixins.map((mixin) => _runCatching(mixin.resetFlags)));
  }

  T? get<T extends MediaPlayerMixin>() {
    for (final mixin in _mixins) {
      if (mixin is T) return mixin;
    }
    return null;
  }

  Future<void> _runCatching(Future<void> Function() action) async {
    try {
      await action();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  final List<MediaPlayerMixin> _mixins = [];
}
