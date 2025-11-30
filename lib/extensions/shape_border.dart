import 'package:flutter/material.dart';

/// Extensions for [ShapeBorder].
extension ShapeBorderExtensions on ShapeBorder {
  /// Subtracts a border radius from the shape border.
  BorderRadiusGeometry subtractBorderRadius(BorderRadius borderRadius) {
    final instance = this;
    return switch (instance) {
      RoundedRectangleBorder() => instance.borderRadius.subtract(borderRadius),
      _ => BorderRadius.zero,
    };
  }
}
