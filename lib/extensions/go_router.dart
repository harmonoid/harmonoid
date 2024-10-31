import 'package:go_router/go_router.dart';

/// Extensions for [GoRouter].
extension GoRouterExtension on GoRouter {
  /// Location.
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    final String location = matchList.uri.toString();
    return location;
  }
}
