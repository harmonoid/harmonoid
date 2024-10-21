import 'dart:math';

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
}
