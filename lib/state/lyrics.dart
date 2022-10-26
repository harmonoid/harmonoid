/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:io';
import 'dart:async';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_library/media_library.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/models/lyric.dart';
import 'package:harmonoid/constants/language.dart';

// TODO(alexmercerind): Move this to another [Isolate] for better performance.
// Currently [ChangeNotifier] & event synchronization may interrupt this simple workflow.

/// Lyrics
/// ------
///
/// Minimal [ChangeNotifier] to handle selection & caching of LRC files.
/// Also fetches & handles the lyrics from internal API.
///
/// The notification lyrics are implemented specifically for mobile platforms in this class itself.
///
class Lyrics extends ChangeNotifier {
  /// [Lyrics] object instance.
  /// Must call [Lyrics.initialize]. Only necessary on Android & iOS.
  static late Lyrics instance = Lyrics();

  /// Lyrics of the currently playing media.
  List<Lyric> current = <Lyric>[];

  late final Directory directory;

  static Future<void> initialize() async {
    if (!_initialized) {
      _initialized = true;
      instance.directory = Directory(
        join(
          Configuration.instance.cacheDirectory.path,
          'Lyrics',
        ),
      );
      if (!await instance.directory.exists_()) {
        await instance.directory.create_();
      }
    }
    if (Platform.isAndroid &&
        !_isAndroidNotificationInitialized &&
        (StorageRetriever.instance.version < 33 ||
            await Permission.notification.isGranted)) {
      _isAndroidNotificationInitialized = true;
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
          // If a seek is performed, then clean the existing notifications to avoid missing text in-between.
          if (instance._currentLyricsTimeStamps[
                      instance._currentLyricsTimeStamp] !=
                  null &&
              instance._currentLyricsTimeStamps[
                      Playback.instance.position.inSeconds] !=
                  null) {
            final current = instance._currentLyricsTimeStamps[
                Playback.instance.position.inSeconds]!;
            final previous = instance
                ._currentLyricsTimeStamps[instance._currentLyricsTimeStamp]!;
            if (![0, 1].contains(current - previous)) {
              debugPrint('![0, 1].contains(current - previous)');
              instance.dismissNotification();
            }
          }
          // The rounded-off [Map] contains current position timestamp, and it hasn't been shown before.
          if (instance.currentLyricsAveragedMap
                  .containsKey(Playback.instance.position.inSeconds) &&
              instance._currentLyricsTimeStamp !=
                  Playback.instance.position.inSeconds) {
            instance._currentLyricsTimeStamp =
                Playback.instance.position.inSeconds;
            try {
              final track = Playback.instance.tracks[Playback.instance.index];
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: _kNotificationID,
                  channelKey: _kNotificationChannelKey,
                  groupKey: _kNotificationChannelKey,
                  actionType: ActionType.DisabledAction,
                  notificationLayout: NotificationLayout.Messaging,
                  category: NotificationCategory.Status,
                  title: track.trackName,
                  body: instance.currentLyricsAveragedMap[
                      instance._currentLyricsTimeStamp],
                  summary: track.trackName,
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
      await for (final track in _controller.stream) {
        if (_track == track) continue;
        current = <Lyric>[];
        currentLyricsAveragedMap = {};
        _currentLyricsTimeStamps = {};
        _currentLyricsHidden = false;
        notifyListeners();
        _track = track;
        try {
          if (isMobile && Configuration.instance.notificationLyrics) {
            await dismissNotification();
          }
          final file = File(join(directory.path, track.moniker));
          debugPrint('[Lyrics]: (custom) $file');
          bool trackDirectoryLRCFound = false;
          if (await file.exists_()) {
            final contents = await file.read_();
            if (contents != null) {
              if (Lrc.isValid(contents)) {
                current.addAll(
                  Lrc.parse(contents).lyrics.map(
                        (e) => Lyric(
                          time: e.timestamp.inMilliseconds,
                          words: e.lyrics,
                        ),
                      ),
                );
                for (final lyric in current) {
                  currentLyricsAveragedMap[lyric.time ~/ 1000] = lyric.words;
                }
                _currentLyricsTimeStamps.addEntries(
                  currentLyricsAveragedMap.keys.toList().asMap().entries.map(
                        (e) => MapEntry(
                          e.value,
                          e.key,
                        ),
                      ),
                );
              } else {
                debugPrint('[Lyrics]: (custom) Corrupt $file.');
              }
            }
          } else {
            // Lookup for `.LRC` file inside the [Track]'s [Directory].
            // Wrapping in a try/catch clause for avoiding any possible file-system related errors.
            debugPrint(
                '[Lyrics]: Configuration.instance.useLRCFromTrackDirectory: ${Configuration.instance.useLRCFromTrackDirectory}');
            try {
              if (track.uri.isScheme('FILE') &&
                  Configuration.instance.useLRCFromTrackDirectory) {
                final source = File(track.uri.toFilePath());
                final elements = basename(source.path).split('.');
                elements.removeLast();
                final name = elements.join('.');
                final files = [
                  File(
                    join(
                      source.parent.path,
                      name + '.lrc',
                    ),
                  ),
                  // case-insensitive file paths on Windows.
                  if (!Platform.isWindows)
                    File(
                      join(
                        source.parent.path,
                        name + '.LRC',
                      ),
                    ),
                ];
                for (final file in files) {
                  debugPrint('[Lyrics]: (in-directory) $file');
                  if (await file.exists_()) {
                    final contents = await file.read_();
                    if (contents != null) {
                      if (Lrc.isValid(contents)) {
                        debugPrint('[Lyrics]: (in-directory) VALID: $file');
                        current.addAll(
                          Lrc.parse(contents).lyrics.map(
                                (e) => Lyric(
                                  time: e.timestamp.inMilliseconds,
                                  words: e.lyrics,
                                ),
                              ),
                        );
                        for (final lyric in current) {
                          currentLyricsAveragedMap[lyric.time ~/ 1000] =
                              lyric.words;
                        }
                        _currentLyricsTimeStamps.addEntries(
                          currentLyricsAveragedMap.keys
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (e) => MapEntry(
                                  e.value,
                                  e.key,
                                ),
                              ),
                        );
                        trackDirectoryLRCFound = true;
                      }
                    }
                    break;
                  }
                }
              }
            } catch (exception, stacktrace) {
              debugPrint(exception.toString());
              debugPrint(stacktrace.toString());
            }
            if (!trackDirectoryLRCFound) {
              debugPrint('[Lyrics]: (API) ${track.lyricsQuery}');
              // Lookup for the lyrics using lambda API.
              final uri = Uri.https(
                'harmonoid-lyrics.vercel.app',
                '/api/lyrics',
                {
                  'name': track.lyricsQuery,
                },
              );
              final response = await http.get(uri);
              if (response.statusCode == 200) {
                current.addAll(
                  (convert.jsonDecode(response.body) as List<dynamic>)
                      .map((lyric) => Lyric.fromJson(lyric))
                      .toList()
                      .cast<Lyric>(),
                );
                for (final lyric in current) {
                  currentLyricsAveragedMap[lyric.time ~/ 1000] = lyric.words;
                }
                _currentLyricsTimeStamps.addEntries(
                  currentLyricsAveragedMap.keys.toList().asMap().entries.map(
                        (e) => MapEntry(
                          e.value,
                          e.key,
                        ),
                      ),
                );
                await cacheLRCFile();
              }
            }
          }
        } catch (exception, stacktrace) {
          await dismissNotification();
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        notifyListeners();
      }
    }();
  }

  /// Whether a [Track] has a `.LRC` file available for it.
  ///
  /// Used directly in the [Widget] tree, thus kept `sync`.
  bool hasLRCFile(Track track) =>
      File(join(directory.path, track.moniker)).existsSync_();

  /// Adds a new LRC [File] & caches it for future usage.
  /// Returns `true` if the [File] was added successfully i.e. [lrc] syntax is valid & [File] is found, otherwise returns `false`.
  ///
  Future<bool> addLRCFile(Track track, File lrc) async {
    try {
      final contents = await lrc.read_();
      if (contents == null) {
        return false;
      }
      if (Lrc.isValid(contents)) {
        try {
          final file = File(
            join(
              directory.path,
              track.moniker,
            ),
          );
          await lrc.copy_(file.path);
          return true;
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
          return false;
        }
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      return false;
    }
    return false;
  }

  /// Caches a LRC [File] for a [Track].
  Future<bool> cacheLRCFile() async {
    if (_track != null && current.isNotEmpty) {
      try {
        final lrc = Lrc(
          type: LrcTypes.simple,
          artist: !(_track?.hasNoAvailableArtists ?? true)
              ? _track?.trackArtistNames.join(';')
              : null,
          album:
              !(_track?.hasNoAvailableAlbum ?? true) ? _track?.albumName : null,
          title: _track?.trackName,
          author: !(_track?.hasNoAvailableArtists ?? true)
              ? _track?.trackArtistNames.join(';')
              : null,
          version: '1.0.0',
          lyrics: current
              .map(
                (e) => LrcLine(
                  timestamp: Duration(milliseconds: e.time),
                  lyrics: e.words,
                  type: LrcTypes.simple,
                ),
              )
              .toList()
              .cast<LrcLine>(),
        );
        assert(_track != null);
        final file = File(
          join(
            directory.path,
            _track?.moniker,
          ),
        );
        // If an already set LRC [File] is found, then avoid overwriting it.
        if (!await file.exists_()) {
          final data = lrc.format();
          // Remove the ending `\n` character. Results in correct LRC file.
          await file.write_(data.substring(0, data.length - 1));
        }
        return true;
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        return false;
      }
    }
    return false;
  }

  /// Removes the cached `.LRC` file from the filesystem cache of the app.
  ///
  Future<void> removeLRCFile(Track track) async {
    final file = File(
      join(
        directory.path,
        track.moniker,
      ),
    );
    if (await file.exists_()) {
      await file.delete_();
    }
  }

  /// Notifies about the currently playing [Track] & updates lyrics at various places inside Harmonoid.
  /// This method is called whenever the [Track] changes from [Playback] class.
  void update(Track track) async {
    _controller.add(track);
  }

  /// Dismisses the lyrics notification.
  /// Android specific.
  FutureOr<void> dismissNotification() async {
    if (Platform.isAndroid &&
        _isAndroidNotificationInitialized &&
        (StorageRetriever.instance.version < 33 ||
            await Permission.notification.isGranted)) {
      await AwesomeNotifications().dismiss(_kNotificationID);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  static const _kNotificationID = 7;
  static const _kNotificationChannelKey = 'com.alexmercerind.harmonoid.lyrics';
  static const _kNotificationChannelName = 'Harmonoid';
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

  /// Current lyrics hashmap with averaged seconds timestamps.
  Map<int, String> currentLyricsAveragedMap = {};

  /// [StreamController] to avoid possible race condition when index
  /// switching in playlist takes place.
  /// * Using `await for` to handle this scenario.
  final StreamController<Track> _controller = StreamController<Track>();

  /// Current query string for lyrics.
  Track? _track;

  /// Averaged timestamp in seconds vs. index.
  Map<int, int> _currentLyricsTimeStamps = {};

  /// Whether notification lyrics are hidden for the current song.
  bool _currentLyricsHidden = false;

  /// Prevent registering method call handler on platform channel more than once.
  static bool _initialized = false;

  /// Whether Android notification callbacks & channels are initialized.
  static bool _isAndroidNotificationInitialized = false;

  /// Currently visible notification lyrics' time stamp.
  int _currentLyricsTimeStamp = 0;
}
