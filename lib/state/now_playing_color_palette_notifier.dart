import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/desktop_now_playing_notifier.dart';
import 'package:harmonoid/state/mobile_now_playing_notifier.dart';
import 'package:synchronized/synchronized.dart';

/// {@template now_playing_color_palette_notifier}
///
/// NowPlayingColorPaletteNotifier
/// ------------------------------
/// Implementation to notify widget tree about the color palette extracted from the currently playing track.
///
/// {@endtemplate}
class NowPlayingColorPaletteNotifier extends ChangeNotifier {
  /// Singleton instance.
  static final NowPlayingColorPaletteNotifier instance = NowPlayingColorPaletteNotifier._();

  /// {@macro now_playing_color_palette_notifier}
  NowPlayingColorPaletteNotifier._() {}

  /// Current playable.
  Playable? current;

  /// Current palette.
  List<Color>? _palette;
  List<Color>? get palette => _palette;
  set palette(List<Color>? value) {
    _palette = value;
    DesktopNowPlayingNotifier.instance.palette.value = value;
    MobileNowPlayingNotifier.instance.palette.value = value;
  }

  /// Sets current [playable].
  Future<void> update(
    Playable playable, {
    bool force = false,
  }) {
    return _lock.synchronized(() async {
      if (current != playable || force) {
        current = playable;
        try {
          final cover = getCover(playable, cacheWidth: 20);
          final result = await PaletteGenerator.fromImageProvider(cover);
          palette = result.colors?.toList();
          notifyListeners();
        } catch (exception, stacktrace) {
          palette = null;
          notifyListeners();
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    });
  }

  /// Clears the currently extracted [palette] & notifies the listeners.
  void clear() {
    palette = null;
    notifyListeners();
  }

  /// Lock.
  final Lock _lock = Lock();
}
