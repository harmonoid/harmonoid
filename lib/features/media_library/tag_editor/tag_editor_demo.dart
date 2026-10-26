import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:identity/identity.dart';
import 'package:path/path.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

bool _mounted = false;

Future<void> showTagEditorDemo(BuildContext context) async {
  if (_mounted) return;
  _mounted = true;

  try {
    final data = await Supabase.instance.client.storage.from('misc').download('sample.mp3');
    if (data.isEmpty) return;

    final file = File(join(Configuration.instance.directory.path, 'TagEditorDemo/Sample.MP3'));

    await file.delete_();
    await file.write_(data);

    if (await file.length_() == 0) return;

    await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: file.path.toString(), kTagEditorArgDemo: 'true'}).toString());
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  } finally {
    _mounted = false;
  }
}
