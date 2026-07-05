import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/utils/material_transition_page.dart';

MaterialTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  ValueKey? key,
}) {
  return MaterialTransitionPage<T>(
    key: key ?? state.pageKey,
    child: child,
  );
}

CustomTransitionPage<T> buildPageWithSharedAxisTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  ValueKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key ?? state.pageKey,
    child: child,
    transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    reverseTransitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.vertical,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    ),
  );
}
