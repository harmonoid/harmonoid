import 'dart:io';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/core/media_player/mixin/media_player_mixin.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

/// {@template windows_taskbar_mixin}
///
/// WindowsTaskbarMixin
/// -------------------
/// package:windows_taskbar mixin for [MediaPlayer].
///
/// {@endtemplate}
final class WindowsTaskbarMixin implements MediaPlayerMixin {
  static bool get supported => Platform.isWindows;

  WindowsTaskbarMixin(this._player);

  @override
  Future<void> ensureInitialized() async {
    // NO/OP
  }

  @override
  Future<void> dispose() async {
    // NO/OP
  }

  @override
  Future<void> resetFlags() async {
    _flagPlaying = null;
  }

  @override
  Future<void> notifyState(MediaPlayerState state) {
    return _lock.synchronized(() async {
      if (_flagPlaying != state.playing) {
        _flagPlaying = state.playing;
        WindowsTaskbar.setThumbnailToolbar(
          [
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/previous.ico'),
              Localization.instance.PREVIOUS,
              _player.previous,
              mode: state.isFirst ? ThumbnailToolbarButtonMode.disabled : 0,
            ),
            if (state.playing)
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/pause.ico'),
                Localization.instance.PAUSE,
                _player.pause,
              )
            else
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/play.ico'),
                Localization.instance.PLAY,
                _player.play,
              ),
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/next.ico'),
              Localization.instance.NEXT,
              _player.next,
              mode: state.isLast ? ThumbnailToolbarButtonMode.disabled : 0,
            ),
          ],
        );
      }
      if (Configuration.instance.windowsTaskbarProgress) {
        const total = 1 << 8;
        final completed = state.position.inSeconds == 0 ? 0 : (state.position.inSeconds / state.duration.inSeconds * total).round();
        WindowsTaskbar.setProgress(completed, total);
      }
    });
  }

  final MediaPlayer _player;

  final Lock _lock = Lock();

  bool? _flagPlaying;
}
