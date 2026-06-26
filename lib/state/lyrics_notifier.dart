import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lrc/lrc.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/api/lyrics_get.dart';
import 'package:harmonoid/api/lyrics_translation_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/lyrics.dart';
import 'package:harmonoid/models/language.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/lyrics.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/remote_config_key.dart';
import 'package:harmonoid/models/remote_config_value.dart';
import 'package:harmonoid/state/remote_config_provider.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template lyrics_notifier}
///
/// LyricsNotifier
/// --------------
/// Implementation to retrieve & display lyrics for currently playing [Playable].
///
/// {@endtemplate}
class LyricsNotifier extends ChangeNotifier {
  static const _kNotificationId = 0;
  static const _kNotificationChannelName = 'Lyrics';
  static const _kNotificationChannelId = 'com.alexmercerind.harmonoid.lyrics';
  static const _kNotificationCategoryId = 'com.alexmercerind.harmonoid.lyrics.category';
  static const _kNotificationHideActionId = 'com.alexmercerind.harmonoid.lyrics.hide';

  /// Singleton instance.
  static late final LyricsNotifier instance;

  /// Whether the [LyricsNotifier] is initialized.
  static bool initialized = false;

  /// {@macro lyrics_notifier}
  LyricsNotifier._(this.directory) {
    MediaPlayer.instance.addListener(
      () => _lock.synchronized(() async {
        if (MediaPlayer.instance.state.playables.isEmpty) return;

        final state = MediaPlayer.instance.state;
        final current = MediaPlayer.instance.current;
        final currentDuration = state.duration;
        final currentPosition = state.position;

        if (current != _current && currentDuration != _currentDuration && currentDuration > Duration.zero && currentPosition > Duration.zero) {
          index = 0;
          lyrics.clear();
          translations.clear();
          _timestampsAndIndexes.clear();
          notifyListeners();

          // --------------------------------------------------
          await cancelNotification();
          await Configuration.instance.set(mobileNotificationLyricsHidden: false);
          // --------------------------------------------------

          _current = current;
          _currentDuration = currentDuration;
          await fetchLyrics();
          await fetchTranslations();

          for (int i = 0; i < lyrics.length; i++) {
            _timestampsAndIndexes[lyrics[i].timestamp] = i;
          }
        }

        int? currentTime = _timestampsAndIndexes.lastKeyBefore(state.position.inMilliseconds + 1);
        int? currentIndex = _timestampsAndIndexes[currentTime];

        if (currentIndex != null) {
          // --------------------------------------------------
          if ((currentIndex - index).abs() > 1 || state.completed) {
            await cancelNotification();
          }
          // --------------------------------------------------

          if (currentIndex != index) {
            index = currentIndex;
            notifyListeners();
            // --------------------------------------------------
            await displayNotification(index);
            // --------------------------------------------------
          }
        }
      }),
    );
    unawaited(fetchTranslationLanguages());
  }

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    final directory = Directory(join(Configuration.instance.directory.path, 'Lyrics'));
    if (!await directory.exists_()) {
      await directory.create_();
    }
    instance = LyricsNotifier._(directory);
    await instance.initializeNotification();
  }

  /// Index.
  int index = 0;

  /// Lyrics.
  final Lyrics lyrics = <Lyric>[];

  /// Translations.
  final Lyrics translations = <Lyric>[];

  /// Translation language.
  Language translationLanguage = Configuration.instance.lyricsTranslationLanguage;

  /// Translation languages.
  final List<Language> translationLanguages = <Language>[];

  /// Directory used to store lyrics.
  final Directory directory;

  /// Fetches lyrics for currently playing [Playable].
  Future<void> fetchLyrics() async {
    final playable = _current;
    final duration = _currentDuration;
    if (playable == null || duration == null) return;

    // 1. LRC.

    debugPrint('LyricsNotifier: retrieve: LRC: ${playable.uri}');
    try {
      final file = uriToLRCFile(playable.uri);
      if (await file.exists_()) {
        final contents = await file.readAsString_();
        if (contents != null && LrcParser.isValid(contents)) {
          final lrc = LrcParser.parse(contents);
          final result = lrc.lyrics;
          lyrics.addAll(result.map((e) => Lyric(timestamp: (lrc.offset ?? 0) + e.timestamp.inMilliseconds, text: e.lyrics.trim())).toList());
          notifyListeners();
          return;
        }
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }

    // 2. Tags.

    debugPrint('LyricsNotifier: retrieve: Tags: ${playable.uri}');
    try {
      final track = FileSystemMediaLibrary.instance.lookupTrack(TrackLookupKey(uri: playable.uri));
      if (track != null && LrcParser.isValid(track.lyrics)) {
        final lrc = LrcParser.parse(track.lyrics);
        final result = lrc.lyrics;
        lyrics.addAll(result.map((e) => Lyric(timestamp: (lrc.offset ?? 0) + e.timestamp.inMilliseconds, text: e.lyrics.trim())).toList());
        notifyListeners();
        return;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }

    // 3. Directory.

    debugPrint('LyricsNotifier: retrieve: Directory: ${playable.uri}');
    try {
      if (Configuration.instance.lrcFromDirectory) {
        final dir = dirname(playable.uri);
        final name = basenameWithoutExtension(playable.uri);
        final files = [
          File(join(dir, '$name.lrc')),
          File(join(dir, '$name.LRC')),
        ];
        for (final file in files) {
          final contents = await file.readAsString_();
          if (contents != null && LrcParser.isValid(contents)) {
            final lrc = LrcParser.parse(contents);
            final result = lrc.lyrics;
            lyrics.addAll(result.map((e) => Lyric(timestamp: (lrc.offset ?? 0) + e.timestamp.inMilliseconds, text: e.lyrics.trim())).toList());
            notifyListeners();
            return;
          }
        }
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }

    // 4. API.

    debugPrint('LyricsNotifier: retrieve: API: ${playable.uri}');
    try {
      final lyricsGet = LyricsGet();
      final result = await lyricsGet.call(
        playable.title,
        playable.subtitle.firstOrNull ?? '',
        duration.inMilliseconds,
      );
      if (result != null) {
        lyrics.addAll(result);
        notifyListeners();

        if (!contains(playable)) {
          final file = uriToLRCFile(playable.uri);
          await file.write_(result.toLrc());
        }

        return;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }
  }

  /// Fetches lyrics for currently playing [Playable].
  Future<void> fetchTranslations() async {
    final language = translationLanguage;
    final current = _current;
    final duration = _currentDuration;
    if (lyrics.isEmpty || language.code.isEmpty || current == null || duration == null) return;
    try {
      final lyricsTranslationGet = LyricsTranslationGet();
      final result = await lyricsTranslationGet.call(
        lyrics,
        language.code,
        current.title,
        current.subtitle.firstOrNull ?? '',
        duration.inMilliseconds,
      );
      if (result != null && result.length == lyrics.length) {
        translations.addAll(result);
        notifyListeners();
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }
  }

  /// Fetches the translation languages.
  Future<void> fetchTranslationLanguages() async {
    final remoteConfigProvider = RemoteConfigProvider();
    final result = await remoteConfigProvider.get(RemoteConfigKey.lyricsTranslationLanguages);
    if (result is LyricsTranslationLanguages) {
      translationLanguages
        ..clear()
        ..addAll(result.value);
      notifyListeners();
    }
  }

  /// Sets the translation language.
  Future<void> setTranslationLanguage(Language language) async {
    translationLanguage = language;

    translations.clear();
    notifyListeners();

    await fetchTranslations();
    await Configuration.instance.set(lyricsTranslationLanguage: language);
  }

  /// Whether .LRC is present in cache for specified [playable].
  bool contains(Playable playable) => uriToLRCFile(playable.uri).existsSync_();

  /// Adds .LRC to cache for specified [playable].
  Future<bool> add(Playable playable, File file) async {
    try {
      final contents = await file.readAsString_();
      if (contents != null && LrcParser.isValid(contents)) {
        final destination = uriToLRCFile(playable.uri);
        await file.copy_(destination.path);
        return true;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return false;
  }

  /// Removes .LRC from cache for specified [playable].
  Future<void> remove(Playable playable) async {
    final file = uriToLRCFile(playable.uri);
    if (await file.exists_()) {
      await file.delete_();
    }
  }

  /// Sets the index.
  void setIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  /// Returns target .LRC [File].
  File uriToLRCFile(String uri) => File(join(directory.path, '${sha256.convert(utf8.encode(uri)).toString()}.LRC'));

  // --------------------------------------------------

  /// Initializes the notification.
  Future<void> initializeNotification() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (_initializeNotificationInvoked) return;
    _initializeNotificationInvoked = true;
    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('ic_stat_format_color_text'),
      iOS: DarwinInitializationSettings(
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
        defaultPresentSound: false,
        defaultPresentBadge: false,
        notificationCategories: [
          DarwinNotificationCategory(
            _kNotificationCategoryId,
            actions: [
              DarwinNotificationAction.plain(
                _kNotificationHideActionId,
                Localization.instance.HIDE,
              ),
            ],
          ),
        ],
      ),
    );
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Displays the notification.
  Future<void> displayNotification(int index) async {
    const diff = 2;
    final from = max(0, index - diff);
    final to = min(lyrics.length - 1, index + diff);
    return ensureNotification(() {
      FlutterLocalNotificationsPlugin().show(
        _kNotificationId,
        _current?.title,
        lyrics[index].text,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _kNotificationChannelId,
            _kNotificationChannelName,
            silent: true,
            showWhen: false,
            playSound: false,
            enableLights: false,
            priority: Priority.high,
            importance: Importance.max,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.message,
            styleInformation: BigTextStyleInformation(
              [
                for (int i = from; i <= to; i++)
                  if (i == index) '<br><b>${lyrics[i].text}</b><br>' else lyrics[i].text,
              ].join('<br>'),
              contentTitle: '<h1>${_current?.title}</h1>',
              htmlFormatTitle: true,
              htmlFormatContent: true,
              htmlFormatBigText: true,
              htmlFormatSummaryText: true,
              htmlFormatContentTitle: true,
            ),
            actions: [
              AndroidNotificationAction(
                _kNotificationHideActionId,
                Localization.instance.HIDE,
                cancelNotification: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBanner: false,
            presentList: true,
            presentSound: false,
            presentBadge: false,
            threadIdentifier: _kNotificationChannelId,
            categoryIdentifier: _kNotificationCategoryId,
            interruptionLevel: InterruptionLevel.passive,
          ),
        ),
      );
    });
  }

  /// Cancels the notification.
  Future<void> cancelNotification() async {
    return ensureNotification(() {
      FlutterLocalNotificationsPlugin().cancel(_kNotificationId);
    });
  }

  /// Invokes the [callback] if the notification can be handled.
  Future<void> ensureNotification(void Function() callback) async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (Platform.isAndroid && !(AndroidStorageController.instance.version < 33 || await Permission.notification.isGranted)) return;
    if (Platform.isIOS && !(await Permission.notification.isGranted)) return;
    if (!_initializeNotificationInvoked) return;
    if (!Configuration.instance.notificationLyrics) return;
    if (await isNotificationHidden()) return;
    callback.call();
  }

  Future<bool> isNotificationHidden() {
    return Configuration.instance.read<bool, bool>(kKeyMobileNotificationLyricsHidden, {kKeyMobileNotificationLyricsHidden: false});
  }

  Playable? _current;
  Duration? _currentDuration;
  bool _initializeNotificationInvoked = false;
  final SplayTreeMap<int, int> _timestampsAndIndexes = SplayTreeMap<int, int>();
  final Lock _lock = Lock();
}

@pragma('vm:entry-point')
void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == LyricsNotifier._kNotificationHideActionId) {
    if (Platform.isAndroid) await AndroidStorageController.ensureInitialized();
    await Configuration.ensureInitialized();
    await Configuration.instance.set(mobileNotificationLyricsHidden: true);
  }
}
