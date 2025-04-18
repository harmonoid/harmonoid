import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extensions for [BuildContext].
extension BuildContextExtension on BuildContext {
  /// Location.
  String get location => GoRouterState.of(this).fullPath!;
}
