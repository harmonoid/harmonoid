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
class AsyncFileImage extends ImageProvider<AsyncFileImage> {
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
  Future<AsyncFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AsyncFileImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(AsyncFileImage key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: this.key,
    );
  }

  @override
  @protected
  ImageStreamCompleter loadImage(AsyncFileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: this.key,
    );
  }

  Future<ui.Codec> _loadAsync(AsyncFileImage key, {required _SimpleDecoderCallback decode}) async {
    assert(key == this);

    fileLocks.putIfAbsent(key.key, () => Lock());

    final instance = await fileLocks[key.key]!.synchronized(() async {
      // There's a chance that the file got resolved in another call, return that instead of attempting to resolve again.
      final fileImage = getFileImage(key.key);
      if (fileImage != null) fileImage.file;

      final result = await _resolve(getFile());

      if (result != null) {
        fallbacks[key.key] ??= false;
        fileImages[key.key] ??= FileImage(result, scale: scale);
        return result;
      } else {
        final file = await getFallbackFile();
        fallbacks[key.key] ??= true;
        fileImages[key.key] ??= FileImage(file, scale: scale);
        return file;
      }
    });

    final lengthInBytes = await instance.length_();
    if (lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$this.key is empty and cannot be loaded as an image.');
    }
    return decode(await ui.ImmutableBuffer.fromFilePath(instance.path));
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

  static final HashMap<String, bool> fallbacks = HashMap<String, bool>();

  static final HashMap<String, FileImage> fileImages = HashMap<String, FileImage>();

  static final HashMap<String, Lock> fileLocks = HashMap<String, Lock>();

  static final HashMap<String, int> attemptToResolveIfFallbackCounts = HashMap<String, int>();

  static final HashMap<String, DateTime> attemptToResolveIfFallbackTimestamps = HashMap<String, DateTime>();

  static FileImage? getFileImage(String key) => fileImages[key];

  static bool isFallback(String key) => fallbacks[key] ?? false;

  static void clear() {
    fallbacks.clear();
    fileImages.clear();
    fileLocks.clear();
    // DO NOT RESET THE COUNT; PREVENT ENDLESS ATTEMPTS.
    // attemptToResolveIfFallbackCounts.clear();
    attemptToResolveIfFallbackTimestamps.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  static void reset(String key) {
    fallbacks.remove(key);
    fileImages.remove(key);
    fileLocks.remove(key);
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

      if (await file() != null) {
        // A file could be resolved, evict the incorrect cache.
        fileImages.remove(key);
        fallbacks.remove(key);
        onResolve?.call();
      }
    }
  }
}

typedef _SimpleDecoderCallback = Future<ui.Codec> Function(ui.ImmutableBuffer buffer);
