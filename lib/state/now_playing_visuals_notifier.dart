import 'dart:io';
import 'package:path/path.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';

/// {@template now_playing_visuals_notifier}
///
/// NowPlayingVisualsNotifier
/// -------------------------
/// Implementation to add, remove or retrieve now playing visuals.
///
/// {@endtemplate}
class NowPlayingVisualsNotifier {
  /// Singleton instance.
  static final NowPlayingVisualsNotifier instance = NowPlayingVisualsNotifier._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro now_playing_visuals_notifier}
  NowPlayingVisualsNotifier._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    instance.directory = Directory(join(Configuration.instance.directory.path, 'NowPlayingVisuals'));
    if (await instance.directory.exists_()) {
      final directory = await instance.directory.list_();
      instance.external.addAll(directory.map((e) => e.path));
    } else {
      await instance.directory.create_();
    }
  }

  /// Directory.
  late final Directory directory;

  /// Bundled now playing visuals.
  final List<String> bundled = List.generate(kBundledVisualsCount, (index) => 'assets/visuals/$index.webp');

  /// External now playing visuals.
  final List<String> external = <String>[];

  /// Count of bundled now playing visuals.
  static const kBundledVisualsCount = 2;
}
