import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';

/// Extensions for [GoRouter].
extension GoRouterExtensions on GoRouter {
  /// Location.
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    final String location = matchList.uri.toString();
    return location;
  }

  /// Snapshot.
  RouteSnapshot get snapshot {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return RouteSnapshot(path: matchList.uri.path, queryParameters: matchList.uri.queryParameters, extra: matchList.extra);
  }
}

class RouteSnapshot {
  final String path;
  final Map<String, String> queryParameters;
  final Object? extra;

  RouteSnapshot({
    required this.path,
    required this.queryParameters,
    this.extra,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteSnapshot && path == other.path && const MapEquality().equals(queryParameters, other.queryParameters) && extra == other.extra;
  }

  @override
  int get hashCode => path.hashCode ^ const MapEquality().hash(queryParameters) ^ extra.hashCode;

  @override
  String toString() {
    return 'RouteSnapshot(path: $path, queryParameters: $queryParameters, extra: $extra)';
  }
}
