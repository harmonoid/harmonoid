import 'dart:math';

import 'package:harmonoid/localization/localization.dart';

/// Extensions for [String].
extension StringExtensions on String {
  /// Ellipsis the string to [length].
  String ellipsis(int length) {
    if (this.length <= length) {
      return this;
    }
    return '${substring(0, max(0, length - 3))}...';
  }

  /// Returns null if the string is blank.
  String? nullIfBlank() {
    return trim().isEmpty ? null : this;
  }

  /// Returns the uppercase version of the string.
  String uppercase() {
    if (Localization.instance.current.code == 'en_US') {
      return toUpperCase();
    }
    return this;
  }
}
