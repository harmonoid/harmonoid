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
/// Implementation to load [FutureOr<File>] images.
///
/// {@endtemplate}
@immutable
class AsyncFileImage extends ImageProvider<AsyncFileImage> {
  /// {@macro async_file_image}
  const AsyncFileImage(
    this._key,
    this._file,
    this._default,
  );

  final String _key;

  final Future<File?> Function() _file;

  final Future<File> Function() _default;

  final double scale = 1.0;

  Future<File?> get file => _file();

  @override
  Future<AsyncFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AsyncFileImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(AsyncFileImage key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: _key,
    );
  }

  @override
  @protected
  ImageStreamCompleter loadImage(AsyncFileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: _key,
    );
  }

  Future<ui.Codec> _loadAsync(
    AsyncFileImage key, {
    required _SimpleDecoderCallback decode,
  }) async {
    assert(key == this);

    fileResolveLocks.putIfAbsent(_key, () => Lock());

    final instance = await fileResolveLocks[_key]!.synchronized(() async {
      // There's a chance that the file got resolved in another call, return that instead of attempting to resolve again.
      final fileImage = getFileImage(_key);
      if (fileImage != null) {
        return fileImage.file;
      }

      final result = await _resolve(_file());

      if (result != null) {
        // --------------------------------------------------
        fileImages[_key] ??= FileImage(result, scale: scale);
        defaults[_key] ??= false;
        // --------------------------------------------------

        return result;
      } else {
        final file = await _default();

        // --------------------------------------------------
        fileImages[_key] ??= FileImage(file, scale: scale);
        defaults[_key] ??= true;
        // --------------------------------------------------

        return file;
      }
    });

    final lengthInBytes = await instance.length_();
    if (lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$_key is empty and cannot be loaded as an image.');
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

  static final HashMap<String, bool> defaults = HashMap<String, bool>();

  static final HashMap<String, FileImage> fileImages = HashMap<String, FileImage>();

  static final HashMap<String, Lock> fileResolveLocks = HashMap<String, Lock>();

  static final HashMap<String, int> attemptToResolveIfDefaultCounts = HashMap<String, int>();

  static final HashMap<String, DateTime> attemptToResolveIfDefaultTimestamps = HashMap<String, DateTime>();

  static FileImage? getFileImage(String key) => fileImages[key];

  static bool isDefault(String key) => defaults[key] ?? false;

  static void reset(String key) {
    defaults.remove(key);
    fileImages.remove(key);
    fileResolveLocks.remove(key);
    // DO NOT RESET THE COUNT; PREVENT ENDLESS ATTEMPTS.
    // attemptToResolveIfDefaultCounts.remove(key);
    attemptToResolveIfDefaultTimestamps.remove(key);
  }

  static void attemptToResolveIfDefault(String key, Future<File?> Function() file, {VoidCallback? onResolve}) async {
    // Try to resolve the actual cover file in background, if the current one is default.
    // There is a possibility that actual cover file was loaded sometime in the future.
    if (isDefault(key)) {
      // Return if an attempt was recently made or if the limit is reached.
      attemptToResolveIfDefaultCounts[key] ??= 0;
      attemptToResolveIfDefaultTimestamps[key] ??= DateTime.now();
      if (attemptToResolveIfDefaultCounts[key]! > 3 || DateTime.now().difference(attemptToResolveIfDefaultTimestamps[key]!) < const Duration(seconds: 1)) {
        return;
      }
      attemptToResolveIfDefaultCounts[key] = attemptToResolveIfDefaultCounts[key]! + 1;
      attemptToResolveIfDefaultTimestamps[key] = DateTime.now();

      if (await file() != null) {
        // A file could be resolved, evict the incorrect cache.
        fileImages.remove(key);
        defaults.remove(key);
        onResolve?.call();
      }
    }
  }
}

typedef _SimpleDecoderCallback = Future<ui.Codec> Function(ui.ImmutableBuffer buffer);
