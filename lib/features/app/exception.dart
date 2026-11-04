// DO NOT IMPORT ANYTHING FROM package:harmonoid IN THIS FILE.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:safe_local_storage/file_system.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/utils/rendering.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionApp({super.key, required this.exception, required this.stacktrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.light),
      darkTheme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.dark),
      home: ExceptionScreen(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}

class ExceptionScreen extends StatefulWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionScreen({super.key, required this.exception, required this.stacktrace});

  @override
  State<ExceptionScreen> createState() => _ExceptionScreenState();
}

class _ExceptionScreenState extends State<ExceptionScreen> {
  bool _isClearing = false;

  Future<void> _onClearCachePressed(BuildContext context) async {
    if (_isClearing) return;

    // Show confirmation message.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(kClearCacheConfirmTitle),
        content: const Text(kClearCacheConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(kClearCacheConfirmPositiveAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(kClearCacheConfirmNegativeAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final cacheDirectory = await Configuration.getCacheDirectory();

    // Show missing directory message.
    if (!await cacheDirectory.exists_()) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(kClearCacheMissingDirTitle),
          content: const Text(kClearCacheMissingDirContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(kClearCacheMissingDirAction),
            ),
          ],
        ),
      );
      return;
    }

    // Show backup message.
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(kClearCacheBackupTitle),
        content: const Text(kClearCacheBackupContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(kClearCacheBackupAction),
          ),
        ],
      ),
    );

    setState(() => _isClearing = true);

    // Show backup progress.
    final progress = ValueNotifier<double>(0);
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text(kClearCacheProgressTitle),
          content: ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (ctx, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: value),
                const SizedBox(height: 16.0),
                Text('${(value * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Create backup archive.
      final Uint8List bytes;
      try {
        bytes = await createBackupZip(cacheDirectory, onProgress: (value) => progress.value = value);
      } finally {
        progress.dispose();
        Navigator.of(context).pop();
      }

      // Save backup archive.
      final savedFile = await saveFile(
        fileName: 'harmonoid-backup-${DateTime.now().millisecondsSinceEpoch}.zip',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      // Show missing file message.
      if (savedFile == null) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(kClearCacheMissingFileTitle),
            content: const Text(kClearCacheMissingFileContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(kClearCacheMissingFileAction),
              ),
            ],
          ),
        );
        return;
      }

      // Delete cache directory.

      if (Configuration.initialized) {
        try {
          await Configuration.instance.dispose();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      if (FileSystemMediaLibrary.initialized) {
        try {
          await FileSystemMediaLibrary.instance.dispose();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
      await cacheDirectory.delete_();

      // Show done message.
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(kClearCacheDoneTitle),
          content: Text('$kClearCacheDoneContent\n${savedFile.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(kClearCacheDoneAction),
            ),
          ],
        ),
      );
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      // Show error message.
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(kClearCacheErrorTitle),
          content: Text('$kClearCacheErrorContent\n${exception.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(kClearCacheErrorAction),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isClearing = false);
    }
  }

  EdgeInsets _getPadding(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    return switch (variant) {
      LayoutVariant.desktop => const EdgeInsets.symmetric(horizontal: 64.0),
      LayoutVariant.mobile => const EdgeInsets.symmetric(horizontal: 16.0),
      LayoutVariant.tablet => throw UnimplementedError(),
      null => throw UnimplementedError(),
    };
  }

  Widget _getSpacer(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    return switch (variant) {
      LayoutVariant.desktop => const SizedBox(height: 32.0),
      LayoutVariant.mobile => const SizedBox(height: 16.0),
      LayoutVariant.tablet => throw UnimplementedError(),
      null => throw UnimplementedError(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      implyBackButton: false,
      caption: kExceptionCaption,
      title: kExceptionTitle,
      slivers: [
        SliverList.list(
          children: [
            // Ref: lib/features/settings/settings_section.dart
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: _getPadding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getSpacer(context),
                    Text(
                      kExceptionHeading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.exception.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _getSpacer(context),
                    Text(
                      kExceptionStackTraceHeading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.stacktrace.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _getSpacer(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isClearing ? null : () => _onClearCachePressed(context),
        icon: _isClearing ? const SizedBox.square(dimension: 24.0, child: CircularProgressIndicator(strokeWidth: 2.0)) : const Icon(Icons.delete),
        label: const Text(kClearCacheButtonLabel),
        shape: const StadiumBorder(),
      ),
    );
  }
}

Future<Uint8List> createBackupZip(
  Directory cache, {
  void Function(double)? onProgress,
}) async {
  Directory temporaryDirectory;
  try {
    temporaryDirectory = await getTemporaryDirectory();
  } catch (_) {
    temporaryDirectory = Directory.systemTemp;
  }
  final file = File(path.join(temporaryDirectory.path, 'harmonoid-backup-${DateTime.now().millisecondsSinceEpoch}.zip'));
  try {
    await zipIsolate(inPath: cache.path, outPath: file.path, onProgress: onProgress);

    final bytes = await file.readAsBytes_();

    if (bytes == null) {
      throw StateError('Backup ZIP could not be read');
    }

    return bytes;
  } finally {
    await file.delete_();
  }
}

Future<void> zipIsolate({
  required String inPath,
  required String outPath,
  void Function(double)? onProgress,
  Duration timeout = const Duration(minutes: 10),
}) async {
  final updates = ReceivePort();
  final errors = ReceivePort();
  final isolate = await Isolate.spawn(
    zipEntry,
    (updates.sendPort, inPath, outPath),
    onError: errors.sendPort,
  );
  Object? isolateError;
  final errorSubscription = errors.listen((message) {
    isolateError ??= message;
    try {
      updates.close();
    } catch (_) {}
  });
  try {
    await for (final message in updates.timeout(timeout)) {
      if (message is double) {
        onProgress?.call(message);
      } else if (message is String) {
        throw StateError(message);
      } else {
        break;
      }
    }
    if (isolateError != null) {
      throw StateError('Backup failed: $isolateError');
    }
  } on TimeoutException catch (_) {
    throw StateError('Backup timed out after ${timeout.inMinutes} minutes');
  } finally {
    await errorSubscription.cancel();
    isolate.kill();
    updates.close();
    errors.close();
  }
}

void zipEntry((SendPort, String, String) message) async {
  final (port, inPath, outPath) = message;
  try {
    await ZipFileEncoder().zipDirectory(
      Directory(inPath),
      filename: outPath,
      followLinks: false,
      onProgress: (value) => port.send(value),
    );
    port.send(true);
  } catch (error) {
    port.send(error.toString());
  }
}

const String kExceptionCaption = 'Harmonoid Music';
const String kExceptionTitle = 'Error';
const String kExceptionHeading = 'Exception';
const String kExceptionStackTraceHeading = 'Stack trace';
const String kClearCacheButtonLabel = 'Clear cache?';
const String kClearCacheConfirmTitle = 'Clear cache?';
const String kClearCacheConfirmContent = 'Are you sure you want to clear the cache? You will lose all your playlists, lyrics, artist images & settings etc. This cannot be undone.';
const String kClearCacheConfirmPositiveAction = 'Clear';
const String kClearCacheConfirmNegativeAction = 'Cancel';
const String kClearCacheMissingDirTitle = 'Cache not found';
const String kClearCacheMissingDirContent = 'Cache directory does not exist.';
const String kClearCacheMissingDirAction = 'OK';
const String kClearCacheBackupTitle = 'Backup required';
const String kClearCacheBackupContent = 'A backup of your existing cache is required before the cache can be cleared. Please choose a file to save the backup archive to.';
const String kClearCacheBackupAction = 'OK';
const String kClearCacheProgressTitle = 'Backing up...';
const String kClearCacheMissingFileTitle = 'No file selected';
const String kClearCacheMissingFileContent = 'No file was selected. The backup archive is necessary to clear the cache. Thus, nothing was cleared.';
const String kClearCacheMissingFileAction = 'OK';
const String kClearCacheDoneTitle = 'Done';
const String kClearCacheDoneContent = 'Please restart the app. Backup saved at:';
const String kClearCacheDoneAction = 'OK';
const String kClearCacheErrorTitle = 'Something went wrong';
const String kClearCacheErrorContent = 'The cache could not be cleared.';
const String kClearCacheErrorAction = 'OK';
