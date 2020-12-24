import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;


Configuration appConfiguration;


class Configurations {
  static const String version                    = 'version';
  static const String languageRegion             = 'languageRegion';
  static const String theme                      = 'theme';
  static const String accent                     = 'accent';
  static const String homeUri                    = 'homeUri';
  static const String collectionStartTab         = 'version';
  static const String collectionDirectoryType    = 'version';
}

class Configuration {
  File configurationFile;
  Map<dynamic, dynamic> configurationMap;

  Configuration(Directory cacheDirectory) {
    if (!cacheDirectory.existsSync()) cacheDirectory.createSync(recursive: true);
    this.configurationFile = File(path.join(cacheDirectory.path, 'appConfiguration.json'));
  }

  static Future<void> init({Directory cacheDirectory}) async {
    appConfiguration = new Configuration(cacheDirectory);
    if (!await appConfiguration.configurationFile.exists()) {
      await appConfiguration.configurationFile.writeAsString(await rootBundle.loadString('assets/initialAppConfiguration.json'));
    }
  }

  Future<dynamic> getConfiguration(String configuration, {bool refresh = true}) async {
    if (refresh || this.configurationMap == null) {
      this.configurationMap = jsonDecode(await this.configurationFile.readAsString());
    }
    return this.configurationMap[configuration];
  }

  Future<void> setConfiguration(String configuration, dynamic value, {bool save = true}) async {
    this.configurationMap[configuration] = value;
    if (save) {
      await this.configurationFile.writeAsString(JsonEncoder.withIndent('    ').convert(this.configurationMap));
    }
  }
}