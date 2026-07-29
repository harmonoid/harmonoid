import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_library/media_library.dart';
import 'package:path/path.dart';
import 'package:pool/pool.dart';
import 'package:safe_local_storage/file_system.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/features/media_library/artists/api/artist_image_get.dart';
import 'package:harmonoid/features/media_library/utils/constants.dart';
import 'package:harmonoid/mappers/media_library_item.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_key.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_value.dart';
import 'package:harmonoid/state/remote_config/remote_config_provider.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/debouncer.dart';

class ArtistImageNotifier extends ChangeNotifier {
  static const String kDefaultAssetKey = 'assets/images/default_artist.jpg';
  static const String kDefaultFileName = 'Artist.JPG';
  static const int kDefaultRemoteVersion = 1;

  ArtistImageNotifier() {
    _initialization = _initialize();
  }

  Key get key => ValueKey(_notifyListenersTimestamp);

  Directory get directory => _directory;

  Future<File?> getFile(Artist artist) async {
    if (!Configuration.instance.mediaLibraryArtistImages || artist.artist == kDefaultArtist) {
      return null;
    }

    await _initialization;

    final query = _artistToQuery(artist);
    final customFile = _queryToCustomFile(query);
    final remoteFile = _queryToRemoteFile(query);
    final deletedFile = _queryToDeletedFile(query);

    if (await deletedFile.exists_()) {
      return null;
    }

    if (await customFile.exists_()) {
      return customFile;
    }

    if (await remoteFile.exists_()) {
      return await remoteFile.length_() > 0 ? remoteFile : null;
    }

    unawaited(_download(artist));
    return null;
  }

  Future<void> setFile(Artist artist, File value) async {
    await _initialization;

    final query = _artistToQuery(artist);
    await _queryToLock(query).synchronized(() async {
      final customFile = _queryToCustomFile(query);
      final deletedFile = _queryToDeletedFile(query);
      await customFile.delete_();
      await deletedFile.delete_();
      await value.copy_(customFile.path);
      _reset(artist);
    });
  }

  Future<void> removeFile(Artist artist) async {
    await _initialization;

    final query = _artistToQuery(artist);
    await _queryToLock(query).synchronized(() async {
      final customFile = _queryToCustomFile(query);
      final remoteFile = _queryToRemoteFile(query);
      final deletedFile = _queryToDeletedFile(query);
      await customFile.delete_();
      await remoteFile.delete_();
      await deletedFile.create_();
      _reset(artist);
    });
  }

  Future<void> refreshFile(Artist artist) async {
    await _initialization;

    await _download(artist, refresh: true);
  }

  Future<File> getDefaultFile() async {
    await _initialization;

    final cover = File(join(_defaultDirectory.path, kDefaultFileName));
    if (!await cover.exists_()) {
      final data = await rootBundle.load(kDefaultAssetKey);
      await cover.write_(data.buffer.asUint8List());
    }
    return cover;
  }

  @override
  void notifyListeners() {
    void fn() {
      if (DateTime.now().difference(_notifyListenersTimestamp) > const Duration(seconds: 5)) {
        _notifyListenersTimestamp = DateTime.now();
        super.notifyListeners();
      }
    }

    fn();
    _debouncer.run(fn);
  }

  @override
  void dispose() {
    _pool.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _customDirectory.create_();
    await _remoteDirectory.create_();
    await _deletedDirectory.create_();
    await _defaultDirectory.create_();
    await _partDirectory.delete_();
    await _partDirectory.create_();
    await _migrateIfRequired();
    await _initializeRemoteVersion();
    unawaited(_refreshRemoteVersion());
  }

  Future<void> _initializeRemoteVersion() async {
    final cached = await RemoteConfigProvider().getCached(RemoteConfigKey.artistImageCacheVersion);
    if (cached case ArtistImageCacheVersion()) {
      _remoteVersion = cached.value;
    }
    if (!await _remoteVersionDirectory.exists_()) {
      await _remoteDirectory.delete_();
      await _remoteVersionDirectory.create_();
    }
  }

  Future<void> _refreshRemoteVersion() async {
    try {
      final value = await RemoteConfigProvider().get(RemoteConfigKey.artistImageCacheVersion);
      if (value case ArtistImageCacheVersion(:int value) when value > _remoteVersion) {
        _remoteVersion = value;
        await _remoteDirectory.delete_();
        await _remoteVersionDirectory.create_();
        AsyncFileImage.clear();
        notifyListeners();
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _migrateIfRequired() async {
    final children = await _directory.children_();
    for (final file in children.whereType<File>()) {
      final name = basename(file.path);
      if (file.extension == 'DEL') {
        await _move(file, File(join(_deletedDirectory.path, name)));
      } else if (file.extension == 'JPG') {
        if (name == kDefaultFileName || await file.length_() == 0) {
          await file.delete_();
        } else {
          await _move(file, File(join(_customDirectory.path, name)));
        }
      }
    }
  }

  Future<void> _move(File source, File destination) async {
    if (await destination.exists_()) {
      await destination.delete_();
    }

    await source.copy_(destination.path);

    if (await destination.exists_()) {
      await source.delete_();
    }
  }

  Future<void> _download(Artist artist, {bool refresh = false}) async {
    final query = _artistToQuery(artist);
    try {
      await _queryToLock(query).synchronized(() async {
        await _pool.withResource(() async {
          final customFile = _queryToCustomFile(query);
          final remoteFile = _queryToRemoteFile(query);
          final deletedFile = _queryToDeletedFile(query);
          final partFile = _queryToPartFile(query);

          if (refresh) {
            await customFile.delete_();
            await remoteFile.delete_();
            await deletedFile.delete_();
          } else {
            if (await deletedFile.exists_()) return;

            if (await customFile.exists_()) return;

            if (await remoteFile.exists_()) return;
          }

          if (await partFile.exists_()) {
            await partFile.delete_();
          }

          try {
            if (await ArtistImageGet().call(query, partFile)) {
              if (await partFile.exists_()) {
                await partFile.rename(remoteFile.path);
                _reset(artist);
              }
            } else {
              // Create an empty file to prevent repeated attempts.
              await remoteFile.create_();
            }
          } finally {
            if (await partFile.exists_()) {
              await partFile.delete_();
            }
          }
        });
      });
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  void _reset(Artist artist) {
    AsyncFileImage.reset(artist.toImageKey());
    notifyListeners();
  }

  String _artistToQuery(Artist artist) => artist.artist.toLowerCase();

  File _queryToCustomFile(String query) => File(join(_customDirectory.path, _queryToFileName(query, 'JPG')));

  File _queryToRemoteFile(String query) => File(join(_remoteVersionDirectory.path, _queryToFileName(query, 'JPG')));

  File _queryToDeletedFile(String query) => File(join(_deletedDirectory.path, _queryToFileName(query, 'DEL')));

  File _queryToPartFile(String query) => File(join(_partDirectory.path, _queryToFileName(query, 'PART')));

  Lock _queryToLock(String query) => _locks.putIfAbsent(query, Lock.new);

  String _queryToFileName(String query, String extension) => '${sha256.convert(utf8.encode(query))}.$extension';

  Directory get _customDirectory => Directory(join(_directory.path, 'Custom'));

  Directory get _remoteDirectory => Directory(join(_directory.path, 'Remote'));

  Directory get _remoteVersionDirectory => Directory(join(_remoteDirectory.path, 'V$_remoteVersion'));

  Directory get _deletedDirectory => Directory(join(_directory.path, 'Deleted'));

  Directory get _defaultDirectory => Directory(join(_directory.path, 'Default'));

  Directory get _partDirectory => Directory(join(_directory.path, 'Part'));

  late final Future<void> _initialization;
  int _remoteVersion = kDefaultRemoteVersion;
  DateTime _notifyListenersTimestamp = DateTime.now();
  final Debouncer _debouncer = Debouncer(timeout: const Duration(seconds: 5));
  final Map<String, Lock> _locks = {};
  final Pool _pool = Pool(10, timeout: const Duration(seconds: 30));
  final Directory _directory = Directory(join(Configuration.instance.directory.path, 'ArtistImages'));
}
