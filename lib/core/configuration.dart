import 'dart:io';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/constants/language.dart';

// TODO: Migrate this shitty JSON based storage to better alternative like Hive etc.
late Configuration configuration;

abstract class ConfigurationKeys {
  List<Directory>? collectionDirectories;
  Directory? cacheDirectory;
  LanguageRegion? languageRegion;
  Accent? accent;
  CollectionSort? collectionSortType;
  List<String>? collectionSearchRecent;
  List<String>? discoverSearchRecent;
  List<String>? discoverRecent;
}

// ignore: non_constant_identifier_names
Map<String, dynamic> DEFAULT_CONFIGURATION = {
  'collectionDirectories': <String>[
    {
      'windows': () => path.join(Platform.environment['USERPROFILE']!, 'Music'),
      'linux': () => path.join(Platform.environment['HOME']!, 'Music'),
      'android': () => '/storage/emulated/0/Music',
    }[Platform.operatingSystem]!(),
  ],
  'languageRegion': 0,
  'accent': 0,
  'collectionSortType': 0,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': ['XfEMj-z3TtA'],
};

class Configuration extends ConfigurationKeys {
  late File configurationFile;

  Future<String> get configurationDirectory async {
    switch (Platform.operatingSystem) {
      case 'windows':
        return Platform.environment['USERPROFILE']!;
      case 'linux':
        return Platform.environment['HOME']!;
      case 'android':
        return (await path.getExternalStorageDirectory())!.path;
      default:
        return '';
    }
  }

  static Future<void> initialize() async {
    configuration = Configuration();
    configuration.configurationFile = File(
      path.join(
        await configuration.configurationDirectory,
        '.harmonoid',
        'configuration.JSON',
      ),
    );
    if (!await configuration.configurationFile.exists()) {
      await configuration.configurationFile.create(recursive: true);
      await configuration.configurationFile.writeAsString(
        convert.JsonEncoder.withIndent('    ').convert(DEFAULT_CONFIGURATION),
      );
    }
    await configuration.read();
    configuration.cacheDirectory = Directory(
      path.join(
        await configuration.configurationDirectory,
        '.harmonoid',
      ),
    );
  }

  Future<void> save({
    List<Directory>? collectionDirectories,
    LanguageRegion? languageRegion,
    Accent? accent,
    bool? showOutOfBoxExperience,
    CollectionSort? collectionSortType,
    List<String>? collectionSearchRecent,
    List<String>? discoverSearchRecent,
    List<String>? discoverRecent,
  }) async {
    if (collectionDirectories != null) {
      this.collectionDirectories = collectionDirectories;
    }
    if (languageRegion != null) {
      this.languageRegion = languageRegion;
    }
    if (accent != null) {
      this.accent = accent;
    }
    if (collectionSortType != null) {
      this.collectionSortType = collectionSortType;
    }
    if (collectionSearchRecent != null) {
      this.collectionSearchRecent = collectionSearchRecent;
    }
    if (discoverSearchRecent != null) {
      this.discoverSearchRecent = discoverSearchRecent;
    }
    if (discoverRecent != null) {
      this.discoverRecent = discoverRecent;
    }
    await configuration.configurationFile
        .writeAsString(convert.JsonEncoder.withIndent('    ').convert({
      'collectionDirectories': this
          .collectionDirectories!
          .map((directory) => directory.path)
          .toList()
          .cast<String>(),
      'languageRegion': this.languageRegion!.index,
      'accent': accents.indexOf(this.accent),
      'collectionSortType': this.collectionSortType!.index,
      'collectionSearchRecent': this.collectionSearchRecent,
      'discoverSearchRecent': this.discoverSearchRecent,
      'discoverRecent': this.discoverRecent,
    }));
  }

  Future<dynamic> read() async {
    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await this.configurationFile.readAsString());
    DEFAULT_CONFIGURATION.keys.forEach((String key) {
      if (!currentConfiguration.containsKey(key)) {
        currentConfiguration[key] = DEFAULT_CONFIGURATION[key];
      }
    });
    this.collectionDirectories = currentConfiguration['collectionDirectories']
        .map((directory) => Directory(directory))
        .toList()
        .cast<Directory>();
    this.languageRegion = LanguageRegion.values[currentConfiguration['languageRegion']];
    this.accent = accents[currentConfiguration['accent']];
    this.collectionSortType = CollectionSort.values[currentConfiguration['collectionSortType']];
    this.collectionSearchRecent = currentConfiguration['collectionSearchRecent'].cast<String>();
    this.discoverSearchRecent = currentConfiguration['discoverSearchRecent'].cast<String>();
    this.discoverRecent = currentConfiguration['discoverRecent'].cast<String>();
  }
}

//DEFAULT VALUES
bool defaultEnable125Scaling = false;
bool defaultNotificationLyrics = true;
bool defaultAcrylicEnabled = false;
bool defaultAutomaticAccent = false;

int defaultThemeMode = 2;