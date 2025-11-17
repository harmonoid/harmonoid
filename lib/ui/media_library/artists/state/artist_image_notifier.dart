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

import 'package:harmonoid/api/artist_image_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/mappers/media_library_item.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/debouncer.dart';

class ArtistImageNotifier extends ChangeNotifier {
  ArtistImageNotifier();

  Key get key => ValueKey(_notifyListenersTimestamp);

  Directory get directory => _directory;

  Future<File?> getFile(Artist artist) async {
    if (!Configuration.instance.mediaLibraryArtistImages || artist.artist == kDefaultArtist) {
      return null;
    }

    final file = await _fileIfExists(_artistToQuery(artist));
    if (file == null) {
      unawaited(_download(artist));
    }

    return file;
  }

  Future<void> setFile(Artist artist, File value) async {
    final query = _artistToQuery(artist);
    final file = _queryToFile(query);
    final blacklistFile = _queryToBlacklistFile(query);
    await file.delete_();
    await blacklistFile.delete_();
    await value.copy_(file.path);
    AsyncFileImage.reset(artist.toImageKey());
    notifyListeners();
  }

  Future<void> removeFile(Artist artist) async {
    final query = _artistToQuery(artist);
    final file = _queryToFile(query);
    final blacklistFile = _queryToBlacklistFile(query);
    await file.delete_();
    await blacklistFile.create_();
    AsyncFileImage.reset(artist.toImageKey());
    notifyListeners();
  }

  Future<File> getDefaultFile() async {
    final cover = File(join(_directory.path, kArtistImageDefaultFileName));
    if (!await cover.exists_()) {
      final data = await rootBundle.load(kArtistImageDefaultAssetKey);
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

  Future<void> _download(Artist artist) async {
    try {
      await _pool.withResource(() async {
        await _createDirectoryIfRequired();

        final query = _artistToQuery(artist);
        final file = _queryToFile(query);
        if (!await file.exists_() && await ArtistImageGet().call(query, file)) {
          AsyncFileImage.reset('${artist.runtimeType}-${artist.hashCode}');
          notifyListeners();
        } else {
          // Create an empty file to prevent repeated attempts.
          await file.create_();
        }
      });
    } catch (exception, stacktrace) {
      if (kDebugMode) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
  }

  Future<void> _createDirectoryIfRequired() async {
    if (_createDirectoryInvoked) return;
    _createDirectoryInvoked = true;
    if (await _directory.exists_()) return;
    await _directory.create_();
  }

  Future<File?> _fileIfExists(String query) async {
    final file = _queryToFile(query);
    final blacklistFile = _queryToBlacklistFile(query);
    final fileExists = await file.exists_() && await file.length_() > 0;
    final blacklistFileExists = await blacklistFile.exists_();
    if (fileExists && !blacklistFileExists) {
      return file;
    }
    return null;
  }

  String _artistToQuery(Artist artist) => artist.artist.toLowerCase();

  File _queryToFile(String query) => File(join(_directory.path, '${sha256.convert(utf8.encode(query)).toString()}.JPG'));

  File _queryToBlacklistFile(String query) => File(join(_directory.path, '${sha256.convert(utf8.encode(query)).toString()}.DEL'));

  bool _createDirectoryInvoked = false;
  DateTime _notifyListenersTimestamp = DateTime.now();
  final Debouncer _debouncer = Debouncer(timeout: const Duration(seconds: 5));
  final Pool _pool = Pool(10, timeout: const Duration(seconds: 10));
  final Directory _directory = Directory(join(Configuration.instance.directory.path, 'ArtistImages'));
}
