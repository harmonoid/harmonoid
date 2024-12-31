import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mappers for [BuildContext].
extension ColorMappers on BuildContext {
  /// Converts to [SystemUiOverlayStyle].
  SystemUiOverlayStyle toSystemUiOverlayStyle() {
    final materialStandard = Theme.of(this).extension<MaterialStandard>()?.value;
    final themeMode = switch (Theme.of(this).brightness) {
      Brightness.light => ThemeMode.light,
      Brightness.dark => ThemeMode.dark,
    };
    final isGestureNavigationEnabled = MediaQuery.of(this).systemGestureInsets.bottom < 48.0 && MediaQuery.of(this).systemGestureInsets.bottom != 0.0;

    const statusBarColor = Colors.transparent;
    final statusBarBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      _ => throw UnimplementedError(),
    };
    final statusBarIconBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.dark,
      ThemeMode.dark => Brightness.light,
      _ => throw UnimplementedError(),
    };
    final systemNavigationBarColor = switch ((materialStandard, themeMode, isGestureNavigationEnabled)) {
      (2, _, _) => Colors.black,
      (3, _, true) => Colors.transparent,
      (3, ThemeMode.light, false) => Colors.white.withOpacity(0.02),
      (3, ThemeMode.dark, false) => Colors.black.withOpacity(0.02),
      _ => throw UnimplementedError(),
    };
    final systemNavigationBarDividerColor = switch ((materialStandard, themeMode, isGestureNavigationEnabled)) {
      (2, _, _) => Colors.black,
      (3, _, true) => Colors.transparent,
      (3, ThemeMode.light, false) => Colors.white.withOpacity(0.02),
      (3, ThemeMode.dark, false) => Colors.black.withOpacity(0.02),
      _ => throw UnimplementedError(),
    };
    final systemNavigationBarIconBrightness = switch ((materialStandard, themeMode)) {
      (2, _) => Brightness.light,
      (3, ThemeMode.light) => Brightness.dark,
      (3, ThemeMode.dark) => Brightness.light,
      _ => throw UnimplementedError(),
    };

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarIconBrightness,
      systemNavigationBarColor: systemNavigationBarColor,
      systemNavigationBarDividerColor: systemNavigationBarDividerColor,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
    );
  }
}
