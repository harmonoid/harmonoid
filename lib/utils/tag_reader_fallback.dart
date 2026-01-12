import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:safe_local_storage/file_system.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:tag_writer/tag_writer.dart';

Future<Tags?> tagReaderParseFallbackImpl(String uri, File? cover, Duration timeout, Tags? result) async {
  if (cover == null || result == null || basename(result.uri) == result.title || await cover.exists_()) return null;

  TagWriter? writer;
  try {
    writer = TagWriter(uri);
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  try {
    final data = await writer?.getCover();
    if (data != null) {
      await cover.write_(data.data);
    }
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
  try {
    await writer?.dispose();
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }

  return null;
}
