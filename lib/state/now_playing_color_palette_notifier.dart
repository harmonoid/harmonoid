import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
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

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro now_playing_color_palette_notifier}
  NowPlayingColorPaletteNotifier._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => instance.listener());
    MediaPlayer.instance.addListener(instance.listener);
  }

  /// Current color palette.
  List<Color>? palette;

  /// Listener to extract the color palette from current [Playable] in [MediaPlayer].
  void listener() {
    if (MediaPlayer.instance.state.isNotEmpty) {
      update(MediaPlayer.instance.current);
    }
  }

  /// Updates the [palette] based on the specified [playable].
  Future<void> update(Playable playable) async {
    if (_current == playable) return;
    _current = playable;
    _updateInvoked = true;
    return _updateLock.synchronized(() async {
      _updateInvoked = false;
      try {
        final image = cover(uri: playable.uri, cacheWidth: 20);
        final result = await PaletteGenerator.fromImageProvider(image);
        // Return prematurely if the method has been invoked again.
        if (_updateInvoked) return;
        palette = result.colors?.toList();
        notifyListeners();
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        palette = null;
        notifyListeners();
      }
    });
  }

  /// Clears the currently extracted [palette] & notifies the listeners.
  void clear() {
    palette = null;
    _current = null;
    notifyListeners();
  }

  /// Resets the [_current].
  void resetCurrent() {
    _current = null;
    notifyListeners();
  }

  /// Disposes the [instance]. Releases allocated resources back to the system.
  @override
  void dispose() {
    super.dispose();
    MediaPlayer.instance.removeListener(listener);
  }

  /// Current [Playable].
  Playable? _current;

  /// Whether [update] has been invoked.
  bool _updateInvoked = false;

  /// Mutual exclusion in [update] invocations.
  final Lock _updateLock = Lock();
}
