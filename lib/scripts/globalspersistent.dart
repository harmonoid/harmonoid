library persistentglobals;

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;

class GlobalsPersistent {

  static Future<void> changeConfiguration(String key, dynamic value) async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));

    File persistentGlobalsFile = File(path.join(applicationDirectory.path, 'persistentGlobals.json'));

    if (!(await persistentGlobalsFile.exists())) {
      await persistentGlobalsFile.create();
      persistentGlobalsFile.writeAsString(await rootBundle.loadString('assets/config.json'));
    }

    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await persistentGlobalsFile.readAsString());

    currentConfiguration[key] = value;
    persistentGlobalsFile.writeAsString(convert.jsonEncode(currentConfiguration));
  }

  static Future<dynamic> getConfiguration(String key) async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));

    File persistentGlobalsFile = File(path.join(applicationDirectory.path, 'persistentGlobals.json'));

    if (!(await persistentGlobalsFile.exists())) {
      await persistentGlobalsFile.create();
      persistentGlobalsFile.writeAsString(await rootBundle.loadString('assets/config.json'));
    }

    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await persistentGlobalsFile.readAsString());
    return currentConfiguration[key];
  }
}