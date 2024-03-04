import 'dart:async';

/// {@template debouncer}
///
/// Debouncer
/// ---------
/// Debounces a function call based on the provided [timeout].
///
/// {@endtemplate}
class Debouncer {
  /// The timeout duration.
  final Duration timeout;

  /// {@macro debouncer}
  Debouncer({this.timeout = const Duration(milliseconds: 200)});

  /// Runs the provided [action] after applying the debouncing logic.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(timeout, action);
  }

  /// Disposes the instance.
  void dispose() {
    _timer?.cancel();
  }

  /// The internal [Timer] instance.
  Timer? _timer;
}
