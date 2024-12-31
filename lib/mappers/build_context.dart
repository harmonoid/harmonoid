import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mappers for [BuildContext].
extension ColorMappers on BuildContext {
  /// Converts to [SystemUiOverlayStyle].
  SystemUiOverlayStyle toSystemUiOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Color? systemNavigationBarDividerColor,
    Brightness? systemNavigationBarIconBrightness,
  }) {
    const statusBarColorDefault = Colors.transparent;
    final statusBarBrightnessDefault = Theme.of(this).brightness;
    final statusBarIconBrightnessDefault = Theme.of(this).brightness == Brightness.light ? Brightness.dark : Brightness.light;
    const systemNavigationBarColorDefault = Colors.black;
    const systemNavigationBarDividerColorDefault = Colors.black;
    final systemNavigationBarIconBrightnessDefault = Theme.of(this).brightness;

    final statusBarColorValue = statusBarColor ?? statusBarColorDefault;
    final statusBarBrightnessValue = statusBarBrightness ?? statusBarBrightnessDefault;
    final statusBarIconBrightnessValue = statusBarIconBrightness ?? statusBarIconBrightnessDefault;
    final systemNavigationBarColorValue = systemNavigationBarColor ?? systemNavigationBarColorDefault;
    final systemNavigationBarDividerColorValue = systemNavigationBarDividerColor ?? systemNavigationBarDividerColorDefault;
    final systemNavigationBarIconBrightnessValue = systemNavigationBarIconBrightness ?? systemNavigationBarIconBrightnessDefault;

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColorValue,
      statusBarBrightness: statusBarBrightnessValue,
      statusBarIconBrightness: statusBarIconBrightnessValue,
      systemNavigationBarColor: systemNavigationBarColorValue,
      systemNavigationBarDividerColor: systemNavigationBarDividerColorValue,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightnessValue,
    );
  }
}
