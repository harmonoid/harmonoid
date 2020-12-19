import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';


class AppState {
  static ThemeMode Function() switchTheme;
  static Future<void> Function(List<Track> tracks, int index) setNowPlaying;
}
