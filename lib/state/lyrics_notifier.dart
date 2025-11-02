import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/api/lyrics_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/lyrics.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/lyrics.dart';
import 'package:harmonoid/models/playable.dart';
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
  static const _kNotificationChannelId = 'com.alexmercerind.harmonoid.lyrics';
  static const _kNotificationChannelName = 'Lyrics';
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

        if (current != _current && currentDuration != _currentDuration && currentPosition > Duration.zero) {
          index = -1;
          lyrics.clear();
          _timestampsAndIndexes.clear();
          notifyListeners();

          // --------------------------------------------------
          _notificationVisible = true;
          dismissNotification();
          // --------------------------------------------------

          _current = current;
          _currentDuration = currentDuration;
          await retrieve();

          for (int i = 0; i < lyrics.length; i++) {
            _timestampsAndIndexes[lyrics[i].timestamp] = i;
          }
        }

        int? nextTime = _timestampsAndIndexes.firstKeyAfter(state.position.inMilliseconds);
        int? nextIndex = _timestampsAndIndexes[nextTime];

        if (nextTime != null && nextIndex != null) {
          if (nextIndex > 0) nextIndex--;

          // --------------------------------------------------
          if ((nextIndex - index).abs() > 1 || state.completed) {
            dismissNotification();
          }
          // --------------------------------------------------

          if (nextIndex != index) {
            index = nextIndex;
            notifyListeners();
            // --------------------------------------------------
            displayNotification(index);
            // --------------------------------------------------
          }
        }
      }),
    );
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
  int index = -1;

  /// Lyrics.
  final Lyrics lyrics = <Lyric>[];

  /// Directory used to store lyrics.
  final Directory directory;

  /// Retrieves lyrics for currently playing [Playable].
  Future<void> retrieve() async {
    final playable = _current;
    if (playable == null) return;

    // 1. LRC.

    debugPrint('LyricsNotifier: retrieve: LRC: ${playable.uri}');
    try {
      final file = uriToLRCFile(playable.uri);
      if (await file.exists_()) {
        final contents = await file.readAsString_();
        if (contents != null && Lrc.isValid(contents)) {
          final result = Lrc.parse(contents).lyrics;
          lyrics.addAll(result.map((e) => Lyric(timestamp: e.timestamp.inMilliseconds, text: e.lyrics)).toList());
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
      final track = await MediaLibrary.instance.db.selectTrackByUri(playable.uri);
      if (track != null && Lrc.isValid(track.lyrics)) {
        final result = Lrc.parse(track.lyrics).lyrics;
        lyrics.addAll(result.map((e) => Lyric(timestamp: e.timestamp.inMilliseconds, text: e.lyrics)).toList());
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
          if (contents != null && Lrc.isValid(contents)) {
            final result = Lrc.parse(contents).lyrics;
            lyrics.addAll(result.map((e) => Lyric(timestamp: e.timestamp.inMilliseconds, text: e.lyrics)).toList());
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
        playable.lyricsGetQuery,
        _currentDuration?.inMilliseconds,
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

  /// Whether .LRC is present in cache for specified [playable].
  bool contains(Playable playable) => uriToLRCFile(playable.uri).existsSync_();

  /// Adds .LRC to cache for specified [playable].
  Future<bool> add(Playable playable, File file) async {
    try {
      final contents = await file.readAsString_();
      if (contents != null && Lrc.isValid(contents)) {
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

  /// Returns target .LRC [File].
  File uriToLRCFile(String uri) => File(join(directory.path, '${sha256.convert(utf8.encode(uri)).toString()}.LRC'));

  // --------------------------------------------------

  /// Initializes the notification.
  Future<void> initializeNotification() async {
    if (!Platform.isAndroid) return;
    if (_initializeNotificationInvoked) return;
    _initializeNotificationInvoked = true;
    const initializationSettings = InitializationSettings(android: AndroidInitializationSettings('ic_stat_format_color_text'));
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Displays the notification.
  void displayNotification(int index) {
    if (!_notificationVisible) return;
    const diff = 2;
    final from = max(0, index - diff);
    final to = min(lyrics.length - 1, index + diff);
    ensureNotification(() {
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
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Dismisses the notification.
  void dismissNotification() {
    ensureNotification(() {
      FlutterLocalNotificationsPlugin().cancel(_kNotificationId);
    });
  }

  /// Invokes the [callback] if the notification can be handled.
  Future<void> ensureNotification(void Function() callback) async {
    if (!Platform.isAndroid) return;
    if (!(AndroidStorageController.instance.version < 33 || await Permission.notification.isGranted)) return;
    if (!Configuration.instance.notificationLyrics) return;
    if (!_initializeNotificationInvoked) return;
    if (!_notificationVisible) return;
    callback.call();
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    if (notificationResponse.actionId == _kNotificationHideActionId) {
      instance._notificationVisible = false;
      instance.dismissNotification();
    }
  }

  Playable? _current;
  Duration? _currentDuration;
  bool _notificationVisible = true;
  bool _initializeNotificationInvoked = false;
  final SplayTreeMap<int, int> _timestampsAndIndexes = SplayTreeMap<int, int>();
  final Lock _lock = Lock();
}
