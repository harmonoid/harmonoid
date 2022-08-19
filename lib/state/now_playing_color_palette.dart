/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';

/// NowPlayingColorPalette
/// ----------------------
///
/// This class globally keeps & provides the [Color]s extracted from a [Track] which is currenly playing.
/// Managing [Color]s this way has two benefits:
/// * No need to run `package:palette_generator` redundantly everywhere we need to access the palette.
///   `package:palette_generator` runs on main thread & causes substantial frame drop every time a palette is extracted.
/// * This avoids race condition that caused palette of previous [Track] to be still visible even after new [Track]
///   started playing.
///   Since, palette generation is `async` operation previous song's palette could be calculated faster than the next one, somehow resulting in the overlap.
///
class NowPlayingColorPalette extends ChangeNotifier {
  /// [NowPlayingColorPalette] object instance.
  static late NowPlayingColorPalette instance = NowPlayingColorPalette();

  /// [Color]s extracted from currently playing [Track].
  List<Color>? palette;

  NowPlayingColorPalette() {
    // Run as asynchronous suspension.
    () async {
      // `await for` to avoid race conditions.
      await for (final track in _controller.stream) {
        if (_current != track) {
          _current = track;
          try {
            final image = getAlbumArt(track, small: true);
            final result = await PaletteGenerator.fromImageProvider(image);
            palette = result.colors?.toList();
            if (Configuration.instance.dynamicNowPlayingBarColoring) {
              MobileNowPlayingController.instance.palette.value = palette;
            }
            notifyListeners();
          } catch (exception, stacktrace) {
            palette = null;
            MobileNowPlayingController.instance.palette.value = null;
            notifyListeners();
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
      }
    }();
  }

  void update(Track track) async {
    _controller.add(track);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  /// [StreamController] to avoid possible race condition when index
  /// switching in playlist takes place.
  /// * Using `await for` to handle this scenario.
  final StreamController<Track> _controller = StreamController<Track>();
  Track? _current;
}
