// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';

/// {@template async_file_image}
///
/// AsyncFileImage
/// --------------
/// Implementation to load [Future<File?>] images.
///
/// {@endtemplate}
@immutable
class AsyncFileImage extends ImageProvider<AsyncFileImageKey> {
  /// {@macro async_file_image}
  const AsyncFileImage(
    this.key,
    this.getFile,
    this.getFallbackFile,
  );

  final String key;

  final Future<File?> Function() getFile;

  final Future<File> Function() getFallbackFile;

  final double scale = 1.0;

  @override
  Future<AsyncFileImageKey> obtainKey(ImageConfiguration configuration) {
    final file = lookupFile(key);
    if (file != null) {
      return SynchronousFuture<AsyncFileImageKey>(_toCacheKey(file));
    }
    return _obtainFile().then<AsyncFileImageKey>(_toCacheKey);
  }

  @override
  ImageStreamCompleter loadBuffer(AsyncFileImageKey key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
    );
  }

  @override
  @protected
  ImageStreamCompleter loadImage(AsyncFileImageKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
    );
  }

  Future<File> _obtainFile() async {
    fileLocks.putIfAbsent(key, () => Lock());

    return fileLocks[key]!.synchronized(() async {
      // There's a chance that the file got resolved in another call, return that instead of attempting to resolve again.
      final file = lookupFile(key);
      if (file != null) {
        return file;
      }

      final result = await _resolve(getFile());
      final instance = result ?? await getFallbackFile();

      final lengthInBytes = await instance.length_();
      if (lengthInBytes == 0) {
        // The file may become available later.
        throw StateError('$key is empty and cannot be loaded as an image.');
      }

      files[key] = instance;
      fallbacks[key] = result == null;
      return instance;
    });
  }

  AsyncFileImageKey _toCacheKey(File file) {
    return AsyncFileImageKey(
      key: key,
      file: file,
      scale: scale,
      generation: generations[key] ?? 0,
    );
  }

  Future<ui.Codec> _loadAsync(AsyncFileImageKey key, {required _SimpleDecoderCallback decode}) async {
    return decode(await ui.ImmutableBuffer.fromFilePath(key.file.path));
  }

  Future<T?> _resolve<T>(FutureOr<T?> future) async {
    try {
      return await future;
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return null;
    }
  }

  static final HashMap<String, File> files = HashMap<String, File>();

  static final HashMap<String, Lock> fileLocks = HashMap<String, Lock>();

  static final HashMap<String, bool> fallbacks = HashMap<String, bool>();

  static final HashMap<String, int> generations = HashMap<String, int>();

  static final HashMap<String, int> attemptToResolveIfFallbackCounts = HashMap<String, int>();

  static final HashMap<String, DateTime> attemptToResolveIfFallbackTimestamps = HashMap<String, DateTime>();

  static File? lookupFile(String key) => files[key];

  static bool isFallback(String key) => fallbacks[key] ?? false;

  static void clear() {
    files.clear();
    fileLocks.clear();
    fallbacks.clear();
    generations.clear();
    // DO NOT RESET THE COUNT; PREVENT ENDLESS ATTEMPTS.
    // attemptToResolveIfFallbackCounts.clear();
    attemptToResolveIfFallbackTimestamps.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  static void reset(String key) {
    files.remove(key);
    fileLocks.remove(key);
    fallbacks.remove(key);
    generations[key] = (generations[key] ?? 0) + 1;
    // DO NOT RESET THE COUNT; PREVENT ENDLESS ATTEMPTS.
    // attemptToResolveIfFallbackCounts.remove(key);
    attemptToResolveIfFallbackTimestamps.remove(key);
  }

  static void attemptToResolveIfFallback(String key, Future<File?> Function() file, {VoidCallback? onResolve}) async {
    // Try to resolve the actual cover file in background, if the current one is default.
    // There is a possibility that actual cover file was loaded sometime in the future.
    if (isFallback(key)) {
      // Return if an attempt was recently made or if the limit is reached.
      attemptToResolveIfFallbackCounts[key] ??= 0;
      attemptToResolveIfFallbackTimestamps[key] ??= DateTime.now();
      if (attemptToResolveIfFallbackCounts[key]! > 3 || DateTime.now().difference(attemptToResolveIfFallbackTimestamps[key]!) < const Duration(seconds: 1)) {
        return;
      }
      attemptToResolveIfFallbackCounts[key] = attemptToResolveIfFallbackCounts[key]! + 1;
      attemptToResolveIfFallbackTimestamps[key] = DateTime.now();

      try {
        if (await file() != null) {
          // A file could be resolved, evict the incorrect cache.
          files.remove(key);
          fallbacks.remove(key);
          generations[key] = (generations[key] ?? 0) + 1;
          onResolve?.call();
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
  }
}

typedef _SimpleDecoderCallback = Future<ui.Codec> Function(ui.ImmutableBuffer buffer);

@immutable
class AsyncFileImageKey {
  const AsyncFileImageKey({
    required this.key,
    required this.file,
    required this.scale,
    required this.generation,
  });

  final String key;

  final File file;

  final double scale;

  final int generation;

  @override
  bool operator ==(Object other) {
    return other is AsyncFileImageKey && other.key == key && other.file.path == file.path && other.scale == scale && other.generation == generation;
  }

  @override
  int get hashCode => Object.hash(key, file.path, scale, generation);
}
