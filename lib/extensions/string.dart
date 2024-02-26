import 'package:flutter/widgets.dart';

/// Extensions for [String].
extension StringExtensions on String {
  /// Return modified string which results better with [TextOverflow.ellipsis] effect.
  String get overflow => Characters(this).replaceAll(Characters(''), Characters('\u{200B}')).toString();
}
