import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';


class AppState {
  static dynamic musicCollectionCurrentTab;
  static void Function(dynamic musicCollectionCurrentTab) musicCollectionRefresh;
  static void Function() musicCollectionSearchRefresh;
  static ThemeMode Function() switchTheme;
  static Future<void> Function(List<Track> tracks, int index) setNowPlaying;
}
