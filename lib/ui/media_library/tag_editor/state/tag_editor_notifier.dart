import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:path/path.dart';
import 'package:safe_local_storage/file_system.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:tag_writer/tag_writer.dart';
import 'package:uuid/uuid.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/ui/media_library/tag_editor/search/models/track_search_result.dart';
import 'package:harmonoid/utils/rendering.dart';

class TagEditorNotifier extends ChangeNotifier {
  static const kSupportedImageFormats = {'JPG', 'JPEG', 'PNG'};

  TagEditorNotifier({required this.resource, this.onError}) {
    _initialize();
  }

  String resource;
  void Function(String)? onError;
  bool loading = false;
  bool coverLoading = false;
  bool saveInvoked = false;
  Map<String, TextEditingController> properties = {};
  CoverData? cover;

  @override
  void dispose() {
    super.dispose();
    _reader.dispose();
    _writer.dispose();
    for (final v in properties.values) {
      v.dispose();
    }
  }

  void addProperty(String key) {
    if (properties.containsKey(key)) return;
    properties[key] = TextEditingController();
    notifyListeners();
  }

  void removeProperty(String key) {
    properties.remove(key)?.dispose();
    notifyListeners();
  }

  Future<void> setCover([CoverData? coverData]) async {
    coverLoading = true;
    notifyListeners();

    try {
      if (coverData != null) {
        _writer.setCover(coverData);
      } else {
        final file = await pickFile(extensions: kSupportedImageFormats);
        final data = await file?.readAsBytes_();
        final mimeType = switch (file?.extension) {
          'JPG' || 'JPEG' => 'image/jpeg',
          'PNG' => 'image/png',
          _ => null,
        };

        if (file == null) {
          coverLoading = false;
          notifyListeners();
          return;
        }

        if (data == null || mimeType == null) throw const FormatException();

        _writer.setCover(CoverData(data: data, mimeType: mimeType));
      }

      _refreshCover();

      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      coverLoading = false;
      notifyListeners();

      if (exception is FormatException) {
        onError?.call(Localization.instance.TAG_EDITOR_ERROR_UNKNOWN_IMAGE_FILE);
      } else {
        onError?.call(Localization.instance.TAG_EDITOR_ERROR_SET_COVER);
      }

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> removeCover() async {
    coverLoading = true;
    notifyListeners();

    try {
      _writer.removeCover();

      _refreshCover();

      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      coverLoading = false;
      notifyListeners();

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> setFromTrackSearchResult(TrackSearchResult result) async {
    loading = true;
    notifyListeners();

    try {
      final json = result.toJson();

      final coverUrl = json.remove('COVER');

      if (coverUrl != null && coverUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(coverUrl));
        final coverData = CoverData(data: response.bodyBytes, mimeType: 'image/jpeg');
        await setCover(coverData);
      }

      for (final MapEntry(:key, :value) in json.entries) {
        if (value.isEmpty) continue;
        addProperty(key);
        properties[key]?.text = value;
      }

      loading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      loading = false;
      notifyListeners();

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> save() async {
    saveInvoked = true;
    loading = true;
    notifyListeners();

    try {
      final oldProperties = _oldProperties;
      final newProperties = properties.map((key, value) => MapEntry(key, value.text.trim()));

      for (final key in oldProperties.keys) {
        if (!newProperties.containsKey(key)) {
          _writer.removeProperty(key);
          debugPrint('TagEditorNotifier: save: Remove property: $key');
        }
      }
      for (final MapEntry(:key, :value) in newProperties.entries) {
        if (oldProperties[key] == value) continue;
        if (value.isEmpty) {
          _writer.removeProperty(key);
          debugPrint('TagEditorNotifier: save: Remove property: $key');
        } else {
          _writer.setProperty(key, [value]);
          debugPrint('TagEditorNotifier: save: Set property: $key: $value');
        }
      }

      _writer.save();

      _refreshProperties();
      _refreshCover();

      // Update old tags & properties.
      _oldTags = await _getTags();
      _oldProperties = properties.map((key, value) => MapEntry(key, value.text.trim()));

      await _postProcessResource();

      loading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      loading = false;
      notifyListeners();

      onError?.call(Localization.instance.TAG_EDITOR_ERROR_SAVE);

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  void _refreshProperties() {
    for (final value in properties.values) {
      value.dispose();
    }
    properties = _writer.getProperties().map((key, value) => MapEntry(key, TextEditingController(text: value.firstOrNull ?? '')));
  }

  void _refreshCover() {
    cover = _writer.getCover();
  }

  Future<void> _initialize() async {
    loading = true;
    coverLoading = true;
    notifyListeners();
    try {
      await _preProcessResource();
      await _initializeTagReader();
      await _initializeTagWriter();

      loading = false;
      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      onError?.call(Localization.instance.TAG_EDITOR_ERROR_UNKNOWN_AUDIO_FILE);

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _preProcessResource() async {
    // On Android, we must copy the file locally where we can write it.

    if (Platform.isAndroid) {
      await _directory.delete_();
      await _directory.create_();

      final from = resource;
      final to = join(_directory.path, const Uuid().v4());

      await File(from).copy_(to);

      resource = to;
    }
  }

  Future<void> _postProcessResource() async {
    // Refresh the media library.

    final track = await _fileSystemMediaLibrary.db.selectTrackByUri(resource);
    if (track != null) {
      await _fileSystemMediaLibrary.remove([track], delete: false);
      await _fileSystemMediaLibrary.add(File(resource));
      await _fileSystemMediaLibrary.populate();
    }

    // Update hash in the media library playlist entries.

    final oldTags = _oldTags;
    final oldHash = HashEncoder.trackToHash(oldTags.toTrack());

    final newTags = await _getTags();
    final newHash = HashEncoder.trackToHash(newTags.toTrack());

    await _fileSystemMediaLibrary.playlists.replaceHash(oldHash, newHash);

    // On Android, we must copy the file back to the original location.

    // TODO: Missing implementation.
  }

  Future<void> _initializeTagReader() async {
    _reader = TagReader(configuration: const TagReaderConfiguration(verbose: true));

    _oldTags = await _getTags();
  }

  Future<void> _initializeTagWriter() async {
    debugPrint('TagEditorNotifier: _initializeTagWriter: File format: ${_oldTags.fileFormat}');
    debugPrint('TagEditorNotifier: _initializeTagWriter: Audio codec: ${_oldTags.audioCodec}');

    _writer = TagWriter(resource, fileFormat: _oldTags.fileFormat, audioCodec: _oldTags.audioCodec);

    _oldProperties = _writer.getProperties().map((key, value) => MapEntry(key, value.firstOrNull ?? ''));

    _refreshProperties();
    _refreshCover();
  }

  Future<Tags> _getTags() async {
    final tags = await _reader.parse(resource);
    return tags;
  }

  late final TagReader _reader;
  late final TagWriter _writer;
  late Tags _oldTags;
  late Map<String, String> _oldProperties;
  final FileSystemMediaLibrary _fileSystemMediaLibrary = FileSystemMediaLibrary.instance;
  final Directory _directory = Directory(join(Configuration.instance.directory.path, 'TagEditor'));
}
