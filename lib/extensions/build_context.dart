import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extensions for [BuildContext].
extension BuildContextExtensions on BuildContext {
  /// Location.
  String get location => GoRouterState.of(this).fullPath!;
}
