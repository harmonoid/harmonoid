import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lrc/lrc.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/api/lyrics_api.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';

/// {@template lyrics_notifier}
///
/// LyricsNotifier
/// --------------
/// Implementation to retrieve lyrics for currently playing [Playable].
///
/// {@endtemplate}
class LyricsNotifier extends ChangeNotifier {
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

        if (current != _current) {
          index = 0;
          lyrics.clear();
          _secondsAndWords.clear();
          _secondsAndIndexes.clear();
          notifyListeners();

          // --------------------------------------------------
          _notificationVisible = true;
          await dismissNotification();
          // --------------------------------------------------

          _current = current;
          await retrieve();

          for (int i = 0; i < lyrics.length; i++) {
            final lyric = lyrics[i];
            final seconds = lyric.time ~/ 1000;
            final words = lyric.words;
            _secondsAndWords[seconds] = words;
            _secondsAndIndexes[seconds] = i;
          }
        }

        // --------------------------------------------------
        final next = _secondsAndIndexes[state.position.inSeconds] ?? 0;
        if (next != index + 1 || state.completed) {
          await dismissNotification();
        }
        // --------------------------------------------------

        final words = _secondsAndWords[state.position.inSeconds];
        if (words != null && _seconds != state.position.inSeconds) {
          _seconds = state.position.inSeconds;
          index = _secondsAndIndexes[_seconds] ?? 0;
          notifyListeners();
          // --------------------------------------------------
          await displayNotification(words);
          // --------------------------------------------------
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
  int index = 0;

  /// Lyrics.
  final List<Lyric> lyrics = <Lyric>[];

  /// Directory used to store lyrics.
  final Directory directory;

  /// Retrieves lyrics for currently playing [Playable].
  Future<void> retrieve() async {
    final playable = _current;
    if (playable == null) return;

    // 1. Tags.

    debugPrint('LyricsNotifier: retrieve: Tags: ${playable.uri}');
    try {
      final track = await MediaLibrary.instance.db.selectTrackByUri(playable.uri);
      if (track != null && Lrc.isValid(track.lyrics)) {
        final result = Lrc.parse(track.lyrics).lyrics;
        lyrics.addAll(result.map((e) => Lyric(time: e.timestamp.inMilliseconds, words: e.lyrics)).toList());
        notifyListeners();
        return;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      lyrics.clear();
      notifyListeners();
    }

    // 2. LRC.

    debugPrint('LyricsNotifier: retrieve: LRC: ${playable.uri}');
    try {
      final lrc = uriToLRCFile(playable.uri);
      if (await lrc.exists_()) {
        final contents = await lrc.read_();
        if (contents != null && Lrc.isValid(contents)) {
          final result = Lrc.parse(contents).lyrics;
          lyrics.addAll(result.map((e) => Lyric(time: e.timestamp.inMilliseconds, words: e.lyrics)).toList());
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
          final contents = await file.read_();
          if (contents != null && Lrc.isValid(contents)) {
            final result = Lrc.parse(contents).lyrics;
            lyrics.addAll(result.map((e) => Lyric(time: e.timestamp.inMilliseconds, words: e.lyrics)).toList());
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
      final result = await LyricsApi.instance.lyrics(playable.lyricsApiName);
      if (result != null) {
        lyrics.addAll(result);
        notifyListeners();
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
      final contents = await file.read_();
      if (contents != null && Lrc.isValid(contents)) {
        final lrc = uriToLRCFile(playable.uri);
        await file.copy_(lrc.path);
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
    final lrc = uriToLRCFile(playable.uri);
    if (await lrc.exists_()) {
      await lrc.delete_();
    }
  }

  /// Returns target .LRC [File].
  File uriToLRCFile(String uri) => File(join(directory.path, '${sha256.convert(utf8.encode(uri)).toString()}.LRC'));

  // --------------------------------------------------

  /// Initializes the notification.
  Future<void> initializeNotification() async {
    if (!Platform.isAndroid) return;
    if (!(AndroidStorageController.instance.version < 33 || await Permission.notification.isGranted)) return;
    if (_initializeNotificationInvoked) return;
    _initializeNotificationInvoked = true;
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_stat_format_color_text',
      [
        NotificationChannel(
          channelKey: _kNotificationChannelKey,
          channelGroupKey: _kNotificationChannelKey,
          channelName: _kNotificationChannelName,
          channelDescription: _kNotificationChannelDescription,
          playSound: false,
          enableVibration: false,
          enableLights: false,
          locked: false,
          criticalAlerts: false,
          onlyAlertOnce: true,
          importance: NotificationImportance.Low,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
      ],
      debug: kDebugMode,
    );
    AwesomeNotifications().setListeners(onActionReceivedMethod: _onNotificationActionReceived);
  }

  /// Displayes the notification.
  Future<void> displayNotification(String body) async {
    return ensureNotification(() async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _kNotificationID,
          channelKey: _kNotificationChannelKey,
          groupKey: _kNotificationChannelKey,
          title: _current?.title ?? '',
          summary: _current?.title ?? '',
          body: body,
          showWhen: false,
          wakeUpScreen: false,
          autoDismissible: true,
          actionType: ActionType.DisabledAction,
          category: NotificationCategory.Status,
          notificationLayout: NotificationLayout.Messaging,
        ),
        actionButtons: [
          NotificationActionButton(
            key: _kNotificationHideButtonKey,
            label: Localization.instance.HIDE,
          ),
        ],
      );
    });
  }

  /// Dismisses the notification.
  FutureOr<void> dismissNotification() {
    return ensureNotification(() async {
      await AwesomeNotifications().dismiss(_kNotificationID);
    });
  }

  /// Invokes the [callback] if the notification can be handled.
  Future<void> ensureNotification(Future<void> Function() callback) async {
    if (!Platform.isAndroid) return;
    if (!(AndroidStorageController.instance.version < 33 || await Permission.notification.isGranted)) return;
    if (!Configuration.instance.notificationLyrics) return;
    if (!_initializeNotificationInvoked) return;
    if (!_notificationVisible) return;
    await callback.call();
  }

  /// Whether lyrics are visible for currently playing [Playable].
  bool _notificationVisible = true;

  /// Whether notification is initialized.
  bool _initializeNotificationInvoked = false;

  // --------------------------------------------------

  Playable? _current;
  int _seconds = 0;
  final HashMap<int, String> _secondsAndWords = HashMap<int, String>();
  final HashMap<int, int> _secondsAndIndexes = HashMap<int, int>();
  final Lock _lock = Lock();

  @pragma('vm:entry-point')
  static Future<void> _onNotificationActionReceived(ReceivedAction action) async {
    if (action.buttonKeyPressed == _kNotificationHideButtonKey) {
      instance._notificationVisible = false;
      AwesomeNotifications().dismiss(_kNotificationID);
    }
  }

  /// Notification: ID.
  static const _kNotificationID = 7;

  /// Notification: Channel Key.
  static const _kNotificationChannelKey = 'com.alexmercerind.harmonoid.lyrics';

  /// Notification: Channel Name.
  static const _kNotificationChannelName = 'Harmonoid Lyrics';

  /// Notification: Channel Description.
  static const _kNotificationChannelDescription = 'Harmonoid Lyrics';

  /// Notification: Hide Button Key.
  static const _kNotificationHideButtonKey = 'HIDE_BUTTON';
}
