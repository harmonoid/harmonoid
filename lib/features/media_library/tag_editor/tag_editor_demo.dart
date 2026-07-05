import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

bool _mounted = false;

Future<void> showTagEditorDemo(BuildContext context) async {
  if (_mounted) return;
  _mounted = true;

  final response = await http.get(Uri.https(apiBaseUrl, '/storage/v1/object/public/misc/sample.mp3'));
  final file = File(join(Configuration.instance.directory.path, 'TagEditorDemo/Sample.MP3'));

  await file.delete_();
  await file.write_(response.bodyBytes);

  if (response.statusCode < 200 || response.statusCode >= 300 || await file.length_() == 0) return;

  await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: file.path.toString(), kTagEditorArgDemo: 'true'}).toString());

  _mounted = false;
}
