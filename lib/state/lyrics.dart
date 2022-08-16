/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_library/media_library.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

/// Lyrics
/// ------
///
/// Minimal [ChangeNotifier] to fetch & update the lyrics based on the currently playing track.
///
/// The notification lyrics are implemented specifically for mobile platforms in this class itself.
///
class Lyrics extends ChangeNotifier {
  /// [Lyrics] object instance.
  /// Must call [Lyrics.initialize]. Only necessary on Android & iOS.
  static late Lyrics instance = Lyrics();

  /// Lyrics of the currently playing media.
  List<Lyric> current = <Lyric>[];

  static Future<void> initialize() async {
    if (isMobile) {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_stat_format_color_text',
        [
          NotificationChannel(
            channelGroupKey: _kNotificationChannelKey,
            channelKey: _kNotificationChannelKey,
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
        debug: true,
      );
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onNotificationActionReceived,
      );
      Playback.instance.addListener(() async {
        if (instance.current.isNotEmpty &&
            Configuration.instance.notificationLyrics &&
            !instance._currentLyricsHidden) {
          // Dismiss the whole notification, if the user seeked behind to avoid cluttering.
          if (instance._currentLyricsTimeStamp >
              Playback.instance.position.inSeconds) {
            await AwesomeNotifications().dismiss(_kNotificationID);
          }
          // The rounded-off [Map] contains current position timestamp, and it hasn't been shown before.
          if (instance._currentLyricsAveragedMap
                  .containsKey(Playback.instance.position.inSeconds) &&
              instance._currentLyricsTimeStamp !=
                  Playback.instance.position.inSeconds) {
            try {
              final start = instance._currentLyricsTimeStamps
                      .indexOf(instance._currentLyricsTimeStamp),
                  end = instance._currentLyricsTimeStamps
                      .indexOf(Playback.instance.position.inSeconds);
              instance._currentLyricsTimeStamp =
                  Playback.instance.position.inSeconds;
              for (int i = start + 1; i <= end; i++) {
                final track = Playback.instance.tracks[Playback.instance.index];
                final hasNoAlbumTag =
                    ['', kUnknownAlbum].contains(track.albumName);
                final hasNoTrackArtistsTag = track.hasNoAvailableArtists;
                final hasNoAlbumArtistsTag = [
                  '',
                  kUnknownArtist,
                ].contains(track.albumArtistName);
                final title = [
                  track.trackName,
                  if (!hasNoTrackArtistsTag)
                    track.trackArtistNames.take(1).join('')
                  else if (!hasNoAlbumArtistsTag)
                    track.albumArtistName
                  else if (!hasNoAlbumTag)
                    track.albumName,
                ].join(' • ');
                await AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: _kNotificationID,
                    channelKey: _kNotificationChannelKey,
                    groupKey: _kNotificationChannelKey,
                    actionType: ActionType.DisabledAction,
                    notificationLayout: NotificationLayout.Messaging,
                    category: NotificationCategory.Status,
                    title: title,
                    body: instance._currentLyricsAveragedMap[
                        instance._currentLyricsTimeStamps[i]],
                    summary: title,
                    showWhen: false,
                    autoDismissible: true,
                    wakeUpScreen: false,
                  ),
                  actionButtons: [
                    NotificationActionButton(
                      key: _kNotificationHideButtonKey,
                      label: Language.instance.HIDE,
                    ),
                  ],
                );
              }
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
          }
          if (Playback.instance.isCompleted) {
            await AwesomeNotifications().dismiss(_kNotificationID);
          }
        }
      });
    }
  }

  Lyrics() {
    // Run as asynchronous suspension.
    () async {
      // `await for` to avoid race conditions.
      await for (final query in _controller.stream) {
        if (_query == query) continue;
        current = <Lyric>[];
        _currentLyricsAveragedMap = {};
        _currentLyricsTimeStamps = [];
        _currentLyricsHidden = false;
        notifyListeners();
        _query = query;
        final uri = Uri.https(
          'harmonoid-lyrics.vercel.app',
          '/api/lyrics',
          {
            'name': _query,
          },
        );
        try {
          if (isMobile && Configuration.instance.notificationLyrics) {
            await killAllNotifications();
          }
          final response = await http.get(uri);
          current.add(Lyric(time: -1, words: ''));
          if (response.statusCode == 200) {
            current.addAll(
              (convert.jsonDecode(response.body) as List<dynamic>)
                  .map((lyric) => Lyric.fromJson(lyric))
                  .toList()
                  .cast<Lyric>(),
            );
            for (final lyric in current) {
              _currentLyricsAveragedMap[lyric.time ~/ 1000] = lyric.words;
            }
            _currentLyricsTimeStamps = _currentLyricsAveragedMap.keys.toList();
          }
        } catch (exception, stacktrace) {
          await killAllNotifications();
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        notifyListeners();
      }
    }();
  }

  void update(String query) async {
    _controller.add(query);
  }

  FutureOr<void> killAllNotifications() {
    if (isMobile) {
      return AwesomeNotifications().dismiss(_kNotificationID);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  static const _kNotificationID = 7;
  static const _kNotificationChannelKey = 'com.alexmercerind.harmonoid.lyrics';
  static const _kNotificationChannelName = 'Harmonoid Lyrics';
  static const _kNotificationChannelDescription = 'Channel for showing lyrics.';
  static const _kNotificationHideButtonKey = 'hide_button';

  /// Must be a global or `static` method.
  static Future<void> _onNotificationActionReceived(
      ReceivedAction action) async {
    if (action.buttonKeyPressed == _kNotificationHideButtonKey) {
      AwesomeNotifications().dismiss(_kNotificationID);
      instance._currentLyricsHidden = true;
    }
  }

  /// [StreamController] to avoid possible race condition when index
  /// switching in playlist takes place.
  /// * Using `await for` to handle this scenario.
  final StreamController<String> _controller = StreamController<String>();

  /// Current query string for lyrics.
  String? _query;

  /// Current lyrics hashmap with averaged seconds timestamps.
  Map<int, String> _currentLyricsAveragedMap = {};

  List<int> _currentLyricsTimeStamps = <int>[];

  /// Whether notification lyrics are hidden for the current song.
  bool _currentLyricsHidden = false;

  /// Currently visible notification lyrics' time stamp.
  int _currentLyricsTimeStamp = 0;
}
