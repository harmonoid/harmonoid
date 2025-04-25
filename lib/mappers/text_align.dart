import 'package:flutter/material.dart';

import 'package:harmonoid/localization/localization.dart';

/// Mappers for [TextAlign].
extension TextAlignMappers on TextAlign {
  /// Gets the corresponding icon for the text alignment.
  IconData toIcon() {
    return switch (this) {
      TextAlign.start || TextAlign.left => Icons.align_horizontal_left,
      TextAlign.center || TextAlign.justify => Icons.align_horizontal_center,
      TextAlign.end || TextAlign.right => Icons.align_horizontal_right,
    };
  }

  /// Gets the localized label for the text alignment.
  String toLabel() {
    return switch (this) {
      TextAlign.start || TextAlign.left => Localization.instance.START,
      TextAlign.center || TextAlign.justify => Localization.instance.CENTER,
      TextAlign.end || TextAlign.right => Localization.instance.END,
    };
  }
}
