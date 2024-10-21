// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

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

  final FutureOr<File?> _file;

  final FutureOr<File> Function() _default;

  final double scale = 1.0;

  FutureOr<File?> get file => _file;

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
    final File instance;

    File? result = await _resolve(_file);
    if (result != null) {
      instance = result;
    } else {
      instance = await _default();
    }

    // --------------------------------------------------
    fileImages[_key] ??= FileImage(instance, scale: scale);
    defaults[_key] ??= result == null;
    // --------------------------------------------------

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

  /// [FileImage] cache.
  static final HashMap<String, FileImage> fileImages = HashMap<String, FileImage>();

  /// Whether the default image is loaded or not.
  static final HashMap<String, bool> defaults = HashMap<String, bool>();

  /// Timestamps for [attemptToResolveIfDefault], to reduce the number of invocations.
  static final HashMap<String, DateTime> attemptToResolveIfDefaultTimestamps = HashMap<String, DateTime>();

  static FileImage? getFileImage(String key) => fileImages[key];

  static void attemptToResolveIfDefault(Future<File?> file, String key, {VoidCallback? onResolve}) async {
    // Try to resolve the actual cover file in background, if the current one is default.
    // There is a possibility that actual cover file was loaded sometime in the future.
    if (defaults[key] ?? false) {
      // Return if an attempt was recently made.
      attemptToResolveIfDefaultTimestamps[key] ??= DateTime.now();
      if (DateTime.now().difference(attemptToResolveIfDefaultTimestamps[key]!) < const Duration(milliseconds: 500)) {
        return;
      }
      attemptToResolveIfDefaultTimestamps[key] = DateTime.now();

      debugPrint('AsyncFileImage: attemptToResolveIfDefault($file, $key)');

      if (await file != null) {
        // A file could be resolved, evict the incorrect cache.
        fileImages.remove(key);
        defaults.remove(key);
        onResolve?.call();
      }
    }
  }
}

typedef _SimpleDecoderCallback = Future<ui.Codec> Function(ui.ImmutableBuffer buffer);
