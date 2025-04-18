import 'package:flutter/rendering.dart';

/// Mappers for [Color].
extension ColorMappers on Color {
  /// Converts the color to a hex string.
  String toHex() => '#'
          '${(r * 255.0).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(g * 255.0).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(b * 255.0).toInt().toRadixString(16).padLeft(2, '0')}'
      .toUpperCase();
}
