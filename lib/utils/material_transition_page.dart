import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/widgets.dart';

/// {@template material_transition_page}
///
/// MaterialTransitionPage
/// ----------------------
/// Implementation to allow usage of [MaterialRoute] in package:go_router.
///
/// {@endtemplate}
class MaterialTransitionPage<T> extends Page<T> {
  /// {@macro material_transition_page}
  const MaterialTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => MaterialRoute(builder: (context) => child, settings: this);
}
