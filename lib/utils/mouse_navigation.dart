import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/utils/constants.dart';

class MouseNavigationListener extends StatefulWidget {
  final Widget child;
  const MouseNavigationListener({super.key, required this.child});

  @override
  State<MouseNavigationListener> createState() => _MouseNavigationListenerState();
}

class _MouseNavigationListenerState extends State<MouseNavigationListener> {
  bool _historyNavigation = false;
  int _historyIndex = -1;
  final List<RouteSnapshot> _historyStack = [];

  @override
  void initState() {
    super.initState();
    router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    super.dispose();
    router.routerDelegate.removeListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (_historyNavigation) {
      _historyNavigation = false;
      return;
    }

    final snapshot = router.snapshot;

    if (snapshot.path.isEmpty) return;

    if (_historyStack.isNotEmpty && _historyIndex >= 0 && _historyStack[_historyIndex] == snapshot) return;

    // Detect backward navigation by checking the history stack.
    if (_historyIndex > 0) {
      for (int i = _historyIndex - 1; i >= 0; i--) {
        if (_historyStack[i] == snapshot) {
          _historyIndex = i;
          return;
        }
      }
    }

    // We navigated back earlier, so we're not at the top of the stack.
    // A new forward navigation invalidates all routes ahead of the current index.
    if (_historyIndex < _historyStack.length - 1) {
      _historyStack.removeRange(_historyIndex + 1, _historyStack.length);
    }

    _historyStack.add(snapshot);
    _historyIndex = _historyStack.length - 1;
  }

  void _historyNavigateBack() {
    // HACK:
    if (fileExplorerNavigateBack != null && router.location.split('/').last == kFoldersPath) {
      final handled = fileExplorerNavigateBack!();
      if (handled) return;
    }

    if (router.canPop()) {
      router.pop();
      // Changes in the index are handled via the listener.
      // This is done to make the handling "universal", as it is possible to go back without using this method i.e. context.pop/Navigator.pop.
    }
  }

  void _historyNavigateForward() {
    // HACK:
    if (fileExplorerNavigateForward != null && router.location.split('/').last == kFoldersPath) {
      final handled = fileExplorerNavigateForward!();
      if (handled) return;
    }

    if (_historyIndex < _historyStack.length - 1) {
      _historyIndex++;
      _historyNavigation = true;
      final snapshot = _historyStack[_historyIndex];
      router.push(
        Uri(path: snapshot.path, queryParameters: snapshot.queryParameters).toString(),
        extra: snapshot.extra,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        _MouseBackRecognizer: GestureRecognizerFactoryWithHandlers<_MouseBackRecognizer>(
          () => _MouseBackRecognizer(),
          (instance) => instance.onTapDown = (details) => _historyNavigateBack(),
        ),
        _MouseForwardRecognizer: GestureRecognizerFactoryWithHandlers<_MouseForwardRecognizer>(
          () => _MouseForwardRecognizer(),
          (instance) => instance.onTapDown = (details) => _historyNavigateForward(),
        ),
      },
      child: widget.child,
    );
  }
}

class _MouseBackRecognizer extends BaseTapGestureRecognizer {
  GestureTapDownCallback? onTapDown;

  _MouseBackRecognizer();

  @override
  void handleTapCancel({
    required PointerDownEvent down,
    PointerCancelEvent? cancel,
    required String reason,
  }) {}

  @override
  void handleTapDown({required PointerDownEvent down}) {
    final details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );

    if (down.buttons == kBackMouseButton && onTapDown != null) {
      invokeCallback<void>('onTapDown', () => onTapDown!(details));
    }
  }

  @override
  void handleTapUp({
    required PointerDownEvent down,
    required PointerUpEvent up,
  }) {}
}

class _MouseForwardRecognizer extends BaseTapGestureRecognizer {
  GestureTapDownCallback? onTapDown;

  _MouseForwardRecognizer();

  @override
  void handleTapCancel({
    required PointerDownEvent down,
    PointerCancelEvent? cancel,
    required String reason,
  }) {}

  @override
  void handleTapDown({required PointerDownEvent down}) {
    final details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );

    if (down.buttons == kForwardMouseButton && onTapDown != null) {
      invokeCallback<void>('onTapDown', () => onTapDown!(details));
    }
  }

  @override
  void handleTapUp({
    required PointerDownEvent down,
    required PointerUpEvent up,
  }) {}
}
