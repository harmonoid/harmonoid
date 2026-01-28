import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:safe_local_storage/file_system.dart';
import 'package:tag_writer/tag_writer.dart';
import 'package:uuid/uuid.dart';

import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/media_library_item.dart';
import 'package:harmonoid/ui/media_library/tag_editor/search/models/track_search_result.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

class TagEditorNotifier extends ChangeNotifier {
  static const Set<String> kSupportedImageFormats = {'JPG', 'JPEG', 'PNG'};

  TagEditorNotifier({required this.resource, this.onError}) {
    _initialize();
  }

  final String resource;
  final void Function(String)? onError;
  bool saveInvoked = false;
  bool propertiesLoading = false;
  bool coverLoading = false;
  bool propertiesChanged = false;
  bool coverChanged = false;
  Map<String, TextEditingController> properties = {};
  CoverData? cover;

  Map<String, String> get propertiesMap => properties.whereNotEmpty((entry) => entry.value.text);
  CoverData? get oldCover => _oldCover;

  @override
  void dispose() {
    super.dispose();
    _disposeTagWriter();
    for (final v in properties.values) {
      _disposeTextEditingController(v);
    }
  }

  void addProperty(String key, [String? value]) {
    if (!properties.containsKey(key)) {
      properties[key] = _createTextEditingController();
    }
    if (value != null) {
      properties[key]?.text = value;
    }
    notifyListeners();
  }

  void removeProperty(String key) {
    _disposeTextEditingController(properties.remove(key));
    notifyListeners();
  }

  Future<void> setCover([CoverData? coverData]) async {
    coverLoading = true;
    notifyListeners();

    try {
      if (coverData != null) {
        await _writer.setCover(coverData);
        coverChanged = true;
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

        await _writer.setCover(CoverData(data: data, mimeType: mimeType));
        coverChanged = true;
      }

      await _refreshCover();

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
      await _writer.removeCover();
      coverChanged = true;

      await _refreshCover();

      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      coverLoading = false;
      notifyListeners();

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> revertCover() async {
    if (cover != null || _oldCover == null) return;
    await setCover(_oldCover);
  }

  Future<void> exportCover() async {
    if (cover == null) return;
    await FilePicker.platform.saveFile(
      fileName: '${const Uuid().v4()}.${cover!.mimeType.split('/').last}',
      type: FileType.custom,
      allowedExtensions: [cover!.mimeType.split('/').last],
      bytes: cover!.data,
    );
  }

  Future<void> setFromTrackSearchResult(TrackSearchResult result) async {
    propertiesLoading = true;
    coverLoading = true;
    propertiesChanged = true;
    coverChanged = true;
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
        addProperty(key, value);
      }

      propertiesLoading = false;
      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      propertiesLoading = false;
      coverLoading = false;
      notifyListeners();

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> save() async {
    if (!propertiesChanged && !coverChanged) return;

    saveInvoked = true;
    propertiesLoading = true;
    notifyListeners();

    try {
      final oldPropertiesMap = _oldPropertiesMap;
      final newPropertiesMap = propertiesMap;

      for (final key in oldPropertiesMap.keys) {
        if (!newPropertiesMap.containsKey(key)) {
          await _writer.removeProperty(key);
          debugPrint('TagEditorNotifier: save: Remove property: $key');
        }
      }
      for (final MapEntry(:key, :value) in newPropertiesMap.entries) {
        if (oldPropertiesMap[key] == value) continue;
        if (value.isEmpty) {
          await _writer.removeProperty(key);
          debugPrint('TagEditorNotifier: save: Remove property: $key');
        } else {
          await _writer.setProperty(key, [value]);
          debugPrint('TagEditorNotifier: save: Set property: $key: $value');
        }
      }

      await _writer.save();

      await _disposeTagWriter();
      await _postProcessResource();
      await _initializeTagWriter();
      propertiesChanged = false;
      coverChanged = false;

      propertiesLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      propertiesLoading = false;
      notifyListeners();

      onError?.call(Localization.instance.TAG_EDITOR_ERROR_SAVE);

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  TextEditingController _createTextEditingController([String? value]) {
    return TextEditingController(text: value)..addListener(_listenerTextEditingController);
  }

  void _disposeTextEditingController(TextEditingController? controller) {
    controller
      ?..removeListener(_listenerTextEditingController)
      ..dispose();
    _listenerTextEditingController();
  }

  void _listenerTextEditingController() {
    final oldPropertiesMap = _oldPropertiesMap;
    final newPropertiesMap = propertiesMap;
    if (const MapEquality().equals(oldPropertiesMap, newPropertiesMap)) {
      if (propertiesChanged) {
        propertiesChanged = false;
        notifyListeners();
      }
    } else {
      if (!propertiesChanged) {
        propertiesChanged = true;
        notifyListeners();
      }
    }
  }

  Future<void> _refreshProperties() async {
    for (final value in properties.values) {
      _disposeTextEditingController(value);
    }
    properties = (await _writer.getProperties()).whereNotEmpty((entry) => entry.value.firstOrNull ?? '').map((key, value) => MapEntry(key, _createTextEditingController(value)));
  }

  Future<void> _refreshCover() async {
    cover = await _writer.getCover();
  }

  Future<void> _initialize() async {
    propertiesLoading = true;
    coverLoading = true;
    notifyListeners();
    try {
      await _preProcessResource();
      await _initializeTagWriter();

      propertiesLoading = false;
      coverLoading = false;
      notifyListeners();
    } catch (exception, stacktrace) {
      onError?.call(Localization.instance.TAG_EDITOR_ERROR_UNKNOWN_AUDIO_FILE);

      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _preProcessResource() async {}

  Future<void> _postProcessResource() async {
    // Refresh the media library.

    final originalTrack = _fileSystemMediaLibrary.lookupTrack(TrackLookupKey(uri: resource));

    if (originalTrack != null) {
      AsyncFileImage.reset(originalTrack.toImageKey());
      await MediaLibrary.trackUriToCoverFile(_fileSystemMediaLibrary.covers, resource).delete_();

      await _fileSystemMediaLibrary.remove([originalTrack], delete: false);
      await _fileSystemMediaLibrary.add(File(resource));
      await _fileSystemMediaLibrary.populate();
    }

    // Refresh the playlists.

    final newTrack = _fileSystemMediaLibrary.lookupTrack(TrackLookupKey(uri: resource));

    if (originalTrack != null && newTrack != null) {
      await _fileSystemMediaLibrary.playlists.replaceHash(
        HashEncoder.trackToHash(originalTrack),
        HashEncoder.trackToHash(newTrack),
      );
    }
  }

  Future<void> _initializeTagWriter() async {
    _writer = TagWriter(resource);

    _oldPropertiesMap = (await _writer.getProperties()).whereNotEmpty((entry) => entry.value.firstOrNull ?? '');
    _oldCover = await _writer.getCover();

    await _refreshProperties();
    await _refreshCover();
  }

  Future<void> _disposeTagWriter() async {
    await _writer.dispose();
  }

  late TagWriter _writer;
  late Map<String, String> _oldPropertiesMap;
  late CoverData? _oldCover;
  final FileSystemMediaLibrary _fileSystemMediaLibrary = FileSystemMediaLibrary.instance;
}

extension MapStringStringExtensions<K, V> on Map<K, V> {
  Map<K, String> whereNotEmpty(String Function(MapEntry<K, V>) getValue) {
    return Map.fromEntries(entries.where((entry) => getValue(entry).trim().isNotEmpty).map((entry) => MapEntry(entry.key, getValue(entry).trim())));
  }
}
