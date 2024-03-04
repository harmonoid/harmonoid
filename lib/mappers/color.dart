import 'package:flutter/rendering.dart';

/// Mappers for [Color].
extension ColorMappers on Color {
  /// Converts the color to a hex string.
  String toHex() => '#'
          '${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}'
      .toUpperCase();
}
