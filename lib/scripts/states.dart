import 'package:flutter/material.dart';


class States {
  static dynamic musicCollectionCurrentTab;
  static void Function(dynamic musicCollectionCurrentTab) musicCollectionRefresh;
  static void Function() musicCollectionSearchRefresh;
  static ThemeMode Function() switchTheme;
  static Future<void> Function(Map<String, dynamic> track) setNowPlaying;
}
