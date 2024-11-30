import 'dart:io';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

/// {@template windows_taskbar_mixin}
///
/// WindowsTaskbarMixin
/// -------------------
/// package:windows_taskbar mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin WindowsTaskbarMixin implements BaseMediaPlayer {
  static bool get supported => Platform.isWindows;

  Future<void> ensureInitializedWindowsTaskbar() async {
    if (!supported) return;
    // NO/OP
    addListener(_listenerWindowsTaskbar);
  }

  Future<void> disposeWindowsTaskbar() async {
    if (!supported) return;
    // NO/OP
  }

  void resetFlagsWindowsTaskbar() {
    // NO/OP
  }

  void _listenerWindowsTaskbar() {
    _lockWindowsTaskbar.synchronized(() async {
      if (_flagPlayingWindowsTaskbar != state.playing) {
        _flagPlayingWindowsTaskbar = state.playing;
        WindowsTaskbar.setThumbnailToolbar(
          [
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/previous.ico'),
              Localization.instance.PREVIOUS,
              previous,
              mode: state.isFirst ? ThumbnailToolbarButtonMode.disabled : 0,
            ),
            if (state.playing)
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/pause.ico'),
                Localization.instance.PAUSE,
                pause,
              )
            else
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/play.ico'),
                Localization.instance.PLAY,
                play,
              ),
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/next.ico'),
              Localization.instance.NEXT,
              next,
              mode: state.isLast ? ThumbnailToolbarButtonMode.disabled : 0,
            ),
          ],
        );
      }
      if (Configuration.instance.windowsTaskbarProgress) {
        const total = 1 << 16;
        final completed = (state.position.inSeconds / state.duration.inSeconds * total).round();
        WindowsTaskbar.setProgress(completed, total);
      }
    });
  }

  final Lock _lockWindowsTaskbar = Lock();

  bool? _flagPlayingWindowsTaskbar;
}
