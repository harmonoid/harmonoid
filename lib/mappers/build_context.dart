import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/state/theme_notifier.dart';

/// Mappers for [BuildContext].
extension ColorMappers on BuildContext {
  /// Converts to [SystemUiOverlayStyle].
  SystemUiOverlayStyle toSystemUiOverlayStyle([int? materialStandard, ThemeMode? themeMode]) {
    return ThemeNotifier.getSystemUiOverlayStyle(
      materialStandard ?? ThemeNotifier.instance.materialStandard,
      themeMode ?? ThemeNotifier.instance.themeMode,
    );
  }
}
