library persistentglobals;

import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/services.dart' show rootBundle;
import 'package:harmonoid/scripts/globalsupdater.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;

class GlobalsPersistent {

  static Future<void> checkAndCreateConfiguration() async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    File persistentGlobalsFile = File(path.join(applicationDirectory.path, 'persistentGlobals.json'));
    if (!(await persistentGlobalsFile.exists())) {
      updateGlobals('en_us');
      if (!(await musicDirectory.exists())) {
        await musicDirectory.create(recursive: true);
      }
      await persistentGlobalsFile.create(recursive: true);
      persistentGlobalsFile.writeAsString(await rootBundle.loadString('assets/config.json'));
    }
  }

  static Future<void> changeConfiguration(String key, dynamic value) async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    File persistentGlobalsFile = File(path.join(applicationDirectory.path, 'persistentGlobals.json'));

    await checkAndCreateConfiguration();

    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await persistentGlobalsFile.readAsString());

    currentConfiguration[key] = value;
    persistentGlobalsFile.writeAsString(convert.jsonEncode(currentConfiguration));
  }

  static Future<dynamic> getConfiguration(String key) async {
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    File persistentGlobalsFile = File(path.join(applicationDirectory.path, 'persistentGlobals.json'));

    await checkAndCreateConfiguration();

    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await persistentGlobalsFile.readAsString());
    return currentConfiguration[key];
  }
}