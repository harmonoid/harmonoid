import 'dart:io';
import 'package:path/path.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';

/// Supported video file extensions for now playing visuals.
const Set<String> kSupportedVideoExtensions = {
  'mp4',
  'webm',
  'mkv',
  'avi',
  'mov',
  'wmv',
  'flv',
};

/// Supported image file extensions for now playing visuals.
const Set<String> kSupportedImageExtensions = {
  'webp',
  'gif',
  'png',
  'jpg',
  'jpeg',
  'bmp',
};

/// {@template now_playing_visuals_notifier}
///
/// NowPlayingVisualsNotifier
/// -------------------------
/// Implementation to add, remove or retrieve now playing visuals.
///
/// {@endtemplate}
class NowPlayingVisualsNotifier {
  /// Count of bundled now playing visuals.
  static const kBundledVisualsCount = 2;

  /// Singleton instance.
  static final NowPlayingVisualsNotifier instance = NowPlayingVisualsNotifier._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro now_playing_visuals_notifier}
  NowPlayingVisualsNotifier._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    instance.directory = Directory(join(Configuration.instance.directory.path, 'NowPlayingVisuals'));
    if (!await instance.directory.exists_()) {
      await instance.directory.create_();
    }
    await instance.refresh();
  }

  /// Directory.
  late final Directory directory;

  /// Bundled now playing visuals.
  final List<String> bundled = List.generate(kBundledVisualsCount, (index) => 'assets/visuals/$index.webp');

  /// External now playing visuals.
  final List<String> external = <String>[];

  /// Refreshes external now playing visuals.
  Future<void> refresh() async {
    external.clear();
    if (await directory.exists_()) {
      final entries = await directory.list_();
      final files = entries
          .whereType<File>()
          .map((e) => e.path)
          .where((path) => path.isVideoVisual || path.isImageVisual)
          .toList();
      files.sort((a, b) => a.compareTo(b));
      external.addAll(files);
    }
  }
}

/// Extensions for visual paths.
extension VisualPathExtension on String {
  /// Whether the path represents a supported video file.
  bool get isVideoVisual {
    final extension = split('.').lastOrNull?.toLowerCase();
    return kSupportedVideoExtensions.contains(extension);
  }

  /// Whether the path represents a supported image file.
  bool get isImageVisual {
    final extension = split('.').lastOrNull?.toLowerCase();
    return kSupportedImageExtensions.contains(extension);
  }
}
