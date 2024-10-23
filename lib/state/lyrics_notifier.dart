import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/api/lyrics_get.dart';
import 'package:harmonoid/mappers/lyrics.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/localization/localization.dart';
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
        final currentDuration = MediaPlayer.instance.state.duration;

        if (current != _current && currentDuration > Duration.zero) {
          index = 0;
          lyrics.clear();
          _timestampsAndIndexes.clear();
          notifyListeners();

          // --------------------------------------------------
          _notificationVisible = true;
          await dismissNotification();
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
          if (nextIndex != index + 1 || state.completed) {
            await dismissNotification();
          }
          // --------------------------------------------------

          if (nextIndex != index) {
            index = nextIndex;
            notifyListeners();
            // --------------------------------------------------
            await displayNotification(lyrics[index].text);
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
  int index = 0;

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
      final result = await LyricsGet.instance.call(
        playable.lyricsGetQuery,
        duration: _currentDuration?.inMilliseconds,
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
  Duration? _currentDuration;
  final SplayTreeMap<int, int> _timestampsAndIndexes = SplayTreeMap<int, int>();
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
