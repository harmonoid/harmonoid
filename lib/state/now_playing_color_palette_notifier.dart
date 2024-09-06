import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';

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
  NowPlayingColorPaletteNotifier._();

  /// Current palette.
  final ValueNotifier<List<Color>?> palette = ValueNotifier<List<Color>?>(null);

  /// Sets current [playable].
  Future<void> update(
    Playable playable, {
    bool force = false,
  }) {
    return _lock.synchronized(() async {
      if (Configuration.instance.desktopNowPlayingBarColorPalette) {
        if (_current != playable || force) {
          _current = playable;
          try {
            final image = cover(uri: playable.uri, cacheWidth: 20);
            final result = await PaletteGenerator.fromImageProvider(image);
            palette.value = result.colors?.toList();
            notifyListeners();
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
            palette.value = null;
            notifyListeners();
          }
        }
      }
    });
  }

  /// Clears the currently extracted [palette] & notifies the listeners.
  void clear() {
    palette.value = null;
    notifyListeners();
  }

  /// Current playable.
  Playable? _current;

  /// Lock.
  final Lock _lock = Lock();
}
