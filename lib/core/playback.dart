/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:libmpv/libmpv.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:media_library/media_library.dart' hide Media, Playlist;
import 'package:ytm_client/ytm_client.dart' hide Media, Track, Playlist;
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/main.dart';

/// Playback
/// --------
///
/// Media playback handler in [Harmonoid](https://github.com/harmonoid/harmonoid).
///
/// Features:
///
/// * Platform independence.
/// * State changes.
/// * `ITaskbarList3` & `SystemMediaTransportControls` controls on Windows.
/// * D-Bus MPRIS controls on Linux.
/// * Discord RPC.
/// * [Lyrics] update.
/// * Notification lyrics.
///
class Playback extends ChangeNotifier {
  /// [Playback] object instance. Must call [Playback.initialize].
  static late Playback instance = Playback();

  int index = DefaultPlaybackValues.index;
  List<Track> tracks = DefaultPlaybackValues.tracks;
  double volume = DefaultPlaybackValues.volume;
  double rate = DefaultPlaybackValues.rate;
  double pitch = DefaultPlaybackValues.pitch;
  PlaylistLoopMode playlistLoopMode = DefaultPlaybackValues.playlistLoopMode;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isMuted = false;
  bool isPlaying = false;
  bool isBuffering = false;
  bool isCompleted = false;
  bool isShuffling = DefaultPlaybackValues.isShuffling;

  void play() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.play();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.play();
    }
  }

  void pause() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.pause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.pause();
    }
  }

  void playOrPause() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.playOrPause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      if (isPlaying) {
        pause();
      } else {
        play();
      }
    }
  }

  void next() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.next();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.skipToNext();
    }
  }

  void previous() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.previous();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.skipToPrevious();
    }
  }

  void jump(int value) {
    if (Platform.isWindows || Platform.isLinux) {
      libmpv?.jump(value);
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      audioService?.skipToQueueItem(value);
    }
  }

  void setRate(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.rate = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setSpeed(value);
    }
    rate = value;
    if (Platform.isLinux) {
      _HarmonoidMPRIS.instance.rate = value;
    }
    notifyListeners();
  }

  void setVolume(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.volume = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setVolume(value / 100.0);
    }
    volume = value;
    if (Platform.isLinux) {
      _HarmonoidMPRIS.instance.volume = value;
    }
    notifyListeners();
  }

  void setPitch(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.pitch = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setPitch(value);
    }
    pitch = value;
    notifyListeners();
  }

  void setPlaylistLoopMode(PlaylistLoopMode value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.setPlaylistMode(PlaylistMode.values[value.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setRepeatMode(AudioServiceRepeatMode.values[value.index]);
    }
    playlistLoopMode = value;
    notifyListeners();
  }

  void toggleMute() {
    if (isMuted) {
      setVolume(_volume);
    } else {
      _volume = volume;
      setVolume(0.0);
    }
    isMuted = !isMuted;
    notifyListeners();
  }

  void toggleShuffle() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.shuffle = !isShuffling;
      // Handled through stream subscription on the Android.
      isShuffling = !isShuffling;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setShuffleMode(
        !isShuffling
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );
    }
    notifyListeners();
  }

  void seek(Duration position) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.seek(position).then((value) {
        Future.delayed(const Duration(milliseconds: 100), () {
          // [endTimeStamp] update needs to be sent.
          notifyDiscordRPC();
        });
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.seek(position);
      await audioService?.play();
    }
  }

  Future<void> open(List<Track> tracks, {int index = 0}) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await libmpv?.open(
        Playlist(
          tracks
              .map((e) => Media(
                    LibmpvPluginUtils.redirect(e.uri).toString(),
                    extras: e.toJson(),
                  ))
              .toList(),
          index: index,
        ),
      );
      isShuffling = false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      this.tracks = tracks;
      await audioService?.open(
        tracks,
        index: index,
      );
    }
    // TODO: Get rid of this tight coupling with non-native & UI related implementation classes.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (Configuration.instance.jumpToNowPlayingScreenOnPlay) {
        Future.delayed(const Duration(milliseconds: 500), () {
          DesktopNowPlayingController.instance.maximize();
        });
      }
    }
    if (Platform.isAndroid || Platform.isIOS) {
      Future.delayed(const Duration(milliseconds: 500), () {
        MobileNowPlayingController.instance.show();
        if (Configuration.instance.jumpToNowPlayingScreenOnPlay) {
          Future.delayed(const Duration(milliseconds: 500), () {
            MobileNowPlayingController.instance.maximize();
          });
        }
      });
    }
  }

  void add(List<Track> tracks) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      tracks.forEach((element) {
        libmpv?.add(
          Media(
            LibmpvPluginUtils.redirect(element.uri).toString(),
            extras: element.toJson(),
          ),
        );
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.add(tracks);
    }
  }

  /// Load the last played playback state.
  ///
  /// Passing [open] as `false` causes file to not be opened inside [libmpv] or [audioService].
  ///
  Future<void> loadAppState({bool open = true}) async {
    isShuffling = AppState.instance.shuffle;
    playlistLoopMode = AppState.instance.playlistLoopMode;
    rate = AppState.instance.rate;
    volume = AppState.instance.volume;
    pitch = AppState.instance.pitch;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      libmpv?.rate = rate;
      libmpv?.volume = volume;
      libmpv?.pitch = pitch;
      libmpv?.setPlaylistMode(PlaylistMode.values[playlistLoopMode.index]);
      libmpv?.shuffle = isShuffling;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.setSpeed(rate);
      audioService?.setVolume(volume / 100.0);
      audioService?.setPitch(pitch);
      audioService?.setRepeatMode(
        AudioServiceRepeatMode.values[playlistLoopMode.index],
      );
      audioService?.setShuffleMode(
        isShuffling
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );
    }
    if (!open) return;
    tracks = AppState.instance.playlist;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await libmpv?.open(
        Playlist(
          tracks
              .map((e) => Media(
                    LibmpvPluginUtils.redirect(e.uri).toString(),
                    extras: e.toJson(),
                  ))
              .toList(),
          index: AppState.instance.index,
        ),
        play: false,
      );
      index = AppState.instance.index;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.open(
        tracks,
        index: AppState.instance.index,
        play: false,
      );
      index = AppState.instance.index;
    }
  }

  static Future<void> initialize() async {
    // `package:libmpv` specific.
    // This is assignment is here for a reason.
    // Don't remove it.
    instance.libmpv = Player(video: false, osc: false, title: kTitle);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      instance.discord = DiscordRPC(applicationId: '881480706545573918');
      instance.libmpv?.streams.playlist.listen((event) async {
        if (event.index < 0 || event.index > event.medias.length - 1) {
          return;
        }
        instance.index = event.index;
        instance.tracks = await compute<List, List<Track>>(
          (message) {
            return message
                .map((media) => Track.fromJson(media.extras))
                .toList();
          },
          event.medias,
        );
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.libmpv?.streams.isPlaying.listen((event) {
        instance.isPlaying = event;
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.libmpv?.streams.isBuffering.listen((event) {
        instance.isBuffering = event;
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.libmpv?.streams.isCompleted.listen((event) async {
        instance.isCompleted = event;
        instance.notifyListeners();
      });
      instance.libmpv?.streams.position
          .distinct(
        (previous, next) =>
            (next - previous).abs() < const Duration(milliseconds: 200),
      )
          .listen((event) {
        if (instance.interceptPositionChangeRebuilds) {
          return;
        }
        instance.position = event;
        instance.notifyListeners();
        if (Platform.isWindows &&
            Configuration.instance.taskbarIndicator &&
            appWindow.isVisible) {
          WindowsTaskbar.setProgress(
            instance.position.inMilliseconds,
            instance.duration.inMilliseconds,
          );
        }
        if (Platform.isLinux) {
          _HarmonoidMPRIS.instance.position = event;
        }
        // [PlaylistLoopMode.single] needs to update [endTimeStamp] in Discord RPC.
        if (event == Duration.zero) {
          instance.notifyDiscordRPC();
        }
      });
      instance.libmpv?.streams.duration.listen((event) {
        instance.duration = event;
        instance.notifyListeners();
      });
      try {
        // System Media Transport Controls. Windows specific.
        if (Platform.isWindows) {
          try {
            WindowsTaskbar.resetWindowTitle();
            SystemMediaTransportControls.instance.create();
            SystemMediaTransportControls.instance.events.listen((value) {
              switch (value) {
                case SMTCEvent.play:
                  instance.play();
                  break;
                case SMTCEvent.pause:
                  instance.pause();
                  break;
                case SMTCEvent.next:
                  instance.next();
                  break;
                case SMTCEvent.previous:
                  instance.previous();
                  break;
                default:
                  break;
              }
            });
          } catch (exception, stackTrace) {
            debugPrint(exception.toString());
            debugPrint(stackTrace.toString());
          }
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    // `package:just_audio` & `package:audio_service` specific.
    if (Platform.isAndroid || Platform.isIOS) {
      instance.audioService = await AudioService.init(
        builder: () => _HarmonoidMobilePlayer(instance),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.alexmercerind.harmonoid',
          androidNotificationChannelName: 'Harmonoid',
          androidNotificationIcon: 'drawable/ic_stat_music_note',
          androidNotificationOngoing: true,
        ),
      );
    }
    // TODO: Improve this garbage. What kind of coding style even is this. FUCK!
    ytm_request_authority = Configuration.instance.proxyURL;
  }

  void notifyNativeListeners() async {
    try {
      final track = tracks[index];
      NowPlayingColorPalette.instance.update(track);
      Lyrics.instance.update([
        track.trackName,
        track.albumArtistName.isNotEmpty &&
                track.albumArtistName != kUnknownArtist
            ? track.albumArtistName
            : track.trackArtistNames.take(1).join(''),
      ].join(' '));
      try {
        // Add to History in asynchronous suspension.
        () async {
          final history = Collection.instance.playlists
              .where((element) => element.id == kHistoryPlaylist)
              .first;
          if (history.tracks.isEmpty) {
            Collection.instance.playlistAddTrack(history, track);
            return;
          }
          if (history.tracks.first != track) {
            Collection.instance.playlistAddTrack(history, track);
          }
        }();
        if (Platform.isWindows) {
          if (appWindow.isVisible && Configuration.instance.taskbarIndicator) {
            WindowsTaskbar.setProgressMode(isBuffering
                ? TaskbarProgressMode.indeterminate
                : TaskbarProgressMode.normal);
          }
          if (appWindow.isVisible) {
            WindowsTaskbar.setWindowTitle(
              [
                track.trackName,
                if (track.trackArtistNames.isNotEmpty)
                  track.trackArtistNames.take(2).join(', '),
                'Harmonoid',
              ].join(' • '),
            );
            WindowsTaskbar.setThumbnailToolbar([
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/previous.ico'),
                Language.instance.PREVIOUS,
                previous,
                mode: index == 0 ? ThumbnailToolbarButtonMode.disabled : 0,
              ),
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon(
                  isPlaying
                      ? 'assets/icons/pause.ico'
                      : 'assets/icons/play.ico',
                ),
                isPlaying ? Language.instance.PAUSE : Language.instance.PLAY,
                isPlaying ? pause : play,
              ),
              ThumbnailToolbarButton(
                ThumbnailToolbarAssetIcon('assets/icons/next.ico'),
                Language.instance.NEXT,
                next,
                mode: index == tracks.length - 1
                    ? ThumbnailToolbarButtonMode.disabled
                    : 0,
              ),
            ]);
          }
          try {
            SystemMediaTransportControls.instance.setStatus(
              isPlaying ? SMTCStatus.playing : SMTCStatus.paused,
            );
            SystemMediaTransportControls.instance.setMusicData(
              title: track.trackName,
              artist: track.hasNoAvailableArtists
                  ? null
                  : track.trackArtistNames.take(2).join(', '),
              albumArtist: track.hasNoAvailableAlbumArtists
                  ? null
                  : track.albumArtistName,
              albumTitle: track.albumName,
              trackNumber: track.trackNumber,
            );
            if (LibmpvPluginUtils.isSupported(track.uri)) {
              final artwork = getAlbumArt(track, small: true);
              SystemMediaTransportControls.instance.setArtwork(
                (artwork as ExtendedNetworkImageProvider).url,
              );
            } else {
              final artwork = getAlbumArt(track);
              SystemMediaTransportControls.instance.setArtwork(
                (artwork as ExtendedFileImageProvider).file,
              );
            }
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
        if (Platform.isLinux) {
          Uri? image;
          if (LibmpvPluginUtils.isSupported(track.uri)) {
            final artwork = getAlbumArt(track, small: true);
            image = Uri.parse((artwork as ExtendedNetworkImageProvider).url);
          } else {
            final artwork = getAlbumArt(track);
            image = (artwork as ExtendedFileImageProvider).file.uri;
          }
          _HarmonoidMPRIS.instance.isPlaying = isPlaying;
          _HarmonoidMPRIS.instance.isCompleted = isCompleted;
          _HarmonoidMPRIS.instance.index = index;
          _HarmonoidMPRIS.instance.playlist = tracks.map((e) {
            final data = e.toJson();
            data['artworkUri'] = image.toString();
            return MPRISMedia.fromJson(data);
          }).toList();
        }
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Fetch [largeImageKey] if the current [track] was changed.
          if (track != _discordPreviousTrack) {
            _discordPreviousLargeImageKey = LibmpvPluginUtils.isSupported(
                    track.uri)
                ? LibmpvPluginUtils.thumbnail(track.uri, small: true).toString()
                : await (() async {
                    // Chances are file has no tagged metadata, thus fallback to the default album art.
                    if (track.hasNoAvailableAlbum &&
                        track.hasNoAvailableArtists &&
                        track.hasNoAvailableAlbumArtists) {
                      return 'default_album_art';
                    }
                    final search = [
                      track.trackName,
                      if (!track.hasNoAvailableArtists)
                        track.trackArtistNames.take(1).join('')
                      else if (!track.hasNoAvailableAlbumArtists)
                        track.albumArtistName
                      else if (!track.hasNoAvailableAlbum)
                        track.albumName,
                    ].join(' ');
                    try {
                      final result = await YTMClient.search(
                        search,
                        filter: SearchFilter.track,
                      );
                      return (result.values.first.first as dynamic)
                          .thumbnails
                          .values
                          .first;
                    } catch (exception, stacktrace) {
                      debugPrint(exception.toString());
                      debugPrint(stacktrace.toString());
                      try {
                        final response = await get(
                          Uri.https(
                            'itunes.apple.com',
                            '/search',
                            {
                              'term': search,
                              'limit': '1',
                              'country': 'us',
                              'entity': 'song',
                              'media': 'music',
                            },
                          ),
                        );
                        return jsonDecode(response.body)['results'][0]
                            ['artworkUrl100'];
                      } catch (exception, stacktrace) {
                        debugPrint(exception.toString());
                        debugPrint(stacktrace.toString());
                        return null;
                      }
                    }
                  }());
            _discordPreviousTrack = track;
          }
          notifyDiscordRPC();
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  /// Update Discord RPC state.
  void notifyDiscordRPC() async {
    return _discordLock.synchronized(() async {
      if (Configuration.instance.discordRPC) {
        try {
          final track = tracks[index];
          final search = [
            track.trackName,
            if (!track.hasNoAvailableArtists)
              track.trackArtistNames.take(1).join('')
            else if (!track.hasNoAvailableAlbumArtists)
              track.albumArtistName,
          ].join(' ');
          if (!isCompleted) {
            discord?.start(autoRegister: true);
            discord?.updatePresence(
              DiscordPresence(
                state: !track.hasNoAvailableArtists
                    ? track.trackArtistNames.join(', ')
                    : !track.hasNoAvailableAlbumArtists
                        ? track.albumArtistName
                        : null,
                details: track.trackName,
                largeImageKey: _discordPreviousLargeImageKey,
                largeImageText:
                    !track.hasNoAvailableAlbum ? track.albumName : null,
                smallImageKey: isPlaying ? 'play' : 'pause',
                smallImageText: isPlaying ? 'Playing' : 'Paused',
                button1Label: LibmpvPluginUtils.isSupported(track.uri)
                    ? 'Listen'
                    : 'Find',
                button1Url: LibmpvPluginUtils.isSupported(track.uri)
                    ? track.uri.toString()
                    : 'https://www.google.com/search?q=${Uri.encodeComponent(search)}',
                endTimeStamp: isPlaying
                    ? DateTime.now().millisecondsSinceEpoch +
                        duration.inMilliseconds -
                        position.inMilliseconds
                    : null,
              ),
            );
          }
          if (isCompleted) {
            discord?.clearPresence();
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      }
    });
  }

  /// Exposed for [_HarmonoidMobilePlayer].
  /// Since, we're using composition with it, there's no choice less-refactor requiring approach I suppose.
  void notify() => notifyListeners();

  /// Save the current playback state.
  Future<void> saveAppState() {
    return AppState.instance.save(
      tracks,
      index,
      rate,
      isShuffling,
      playlistLoopMode,
      volume,
      pitch,
    );
  }

  @override
  // ignore: must_call_super
  void dispose() async {}

  /// `package:libmpv` [Player] instance used on Windows, Linux & macOS.
  Player? libmpv;

  ///`package:just_audio` & `package:audio_service` based [_HarmonoidMobilePlayer] instance
  /// used on Android & iOS.
  _HarmonoidMobilePlayer? audioService;

  /// `package:dart_discord_rpc` based [DiscordRPC] instance used on Windows, Linux & macOS.
  DiscordRPC? discord;

  /// This is used to keep the last found artwork URI or image key. It prevents redundant requests for the same [Track].
  String? _discordPreviousLargeImageKey;

  /// Current [Track] being used in the Discord RPC.
  Track? _discordPreviousTrack;

  final Lock _discordLock = Lock();

  /// The volume that is restored to, before the unmute.
  /// See [toggleMute].
  double _volume = 0.0;

  /// Public getter.
  bool get isFirstTrack => index == 0;

  /// Public getter.
  bool get isLastTrack => index == tracks.length - 1;

  /// NOTE: Only applicable on desktop.
  /// In current analysis, I have observed that rebuilds in the seekbar [Slider] present on
  /// [NowPlayingBar] causes substantial lag in the hero animations.
  /// This causes experience to be jittery.
  ///
  /// By setting [interceptPositionChangeRebuilds] to `true`, whenever a [Route] is in the
  /// middle of transition, the [NowPlayingBar] will not rebuild.
  ///
  /// Since, the transition is only visible for 300 ~ 400ms, this should be fine. While,
  /// the animation will be buttery smooth to the user's eyes.
  bool interceptPositionChangeRebuilds = false;
}

enum PlaylistLoopMode {
  none,
  single,
  loop,
}

/// Default Playback class values.
abstract class DefaultPlaybackValues {
  static int index = 0;
  static List<Track> tracks = [];
  static double volume =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 50.0 : 100.0;
  static double rate = 1.0;
  static double pitch = 1.0;
  static PlaylistLoopMode playlistLoopMode = PlaylistLoopMode.none;
  static bool isShuffling = false;
}

/// Implements `org.mpris.MediaPlayer2` & `org.mpris.MediaPlayer2.Player`.
class _HarmonoidMPRIS extends MPRISService {
  /// [_HarmonoidMPRIS] object instance.
  static final instance = _HarmonoidMPRIS();

  _HarmonoidMPRIS()
      : super(
          'harmonoid',
          identity: 'Harmonoid',
          desktopEntry: '/usr/share/applications/harmonoid.desktop',
        );

  @override
  void setLoopStatus(value) {
    switch (value) {
      case 'None':
        {
          Playback.instance.setPlaylistLoopMode(PlaylistLoopMode.none);
          break;
        }
      case 'Track':
        {
          Playback.instance.setPlaylistLoopMode(PlaylistLoopMode.single);
          break;
        }
      case 'Playlist':
        {
          Playback.instance.setPlaylistLoopMode(PlaylistLoopMode.loop);
          break;
        }
    }
  }

  @override
  void setRate(value) {
    Playback.instance.setRate(value);
  }

  @override
  void setShuffle(value) {
    if (Playback.instance.isShuffling != value) {
      Playback.instance.toggleShuffle();
    }
  }

  @override
  void doNext() {
    Playback.instance.next();
  }

  @override
  void doPrevious() {
    Playback.instance.previous();
  }

  @override
  void doPause() {
    Playback.instance.pause();
  }

  @override
  void doPlay() {
    Playback.instance.play();
  }

  @override
  void doPlayPause() {
    Playback.instance.playOrPause();
  }

  @override
  void doSeek(value) {
    Playback.instance.seek(Duration(microseconds: value));
  }

  @override
  void doSetPosition(objectPath, timeMicroseconds) {
    final index = playlist
        .map(
          (e) => '/' + e.uri.toString().hashCode.toString(),
        )
        .toList()
        .indexOf(objectPath);
    if (index >= 0 && index != this.index) {
      Playback.instance.jump(index);
    }
    Playback.instance.seek(Duration(microseconds: timeMicroseconds));
  }

  @override
  void doOpenUri(uri) {
    Intent.instance.playUri(uri);
  }
}

/// Android/iOS specific implementation for audio playback & media notification.
/// Completely based around the `package:just_audio` and `package:audio_service` packages.
///
/// This class is used in composition with the parent [Playback] class & can be accessed
/// from its singleton available as [Playback.instance].
///
/// Takes existing [Playback] reference as [playback]. This is tightly coupled with the
/// parent [Playback] class. But, I guess it's the best approach for now.
class _HarmonoidMobilePlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  _HarmonoidMobilePlayer(this.playback) {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          _playerAndroidEqualizer,
          _playerAndroidLoudnessEnhancer,
        ],
      ),
    );
    _player.playbackEventStream.listen((e) {
      debugPrint(e.processingState.toString());
      if (e.processingState == ProcessingState.completed) {
        // The audio playback needs to be interpreted as paused once the playback of a media is completed.
        playback.isPlaying = false;
      }
      playback
        ..isCompleted = e.processingState == ProcessingState.completed
        ..notify()
        ..notifyNativeListeners();
      playbackState.add(_transformEvent(e));
    });
    _player.currentIndexStream.listen((e) {
      debugPrint('_HarmonoidMobilePlayer/_player.currentIndex: $e');
      if (e != null) {
        playback
          ..index = e
          ..notify();
        debugPrint(queue.value[e].toString());
        mediaItem.add(queue.value[e]);
      }
    });
    // Handled within [Playback] instance.
    // _player.volumeStream.listen(
    //   (e) => playback
    //     ..volume = e * 100.0
    //     ..notify(),
    // );
    _player.speedStream.listen(
      (e) => playback
        ..rate = e
        ..notify(),
    );
    _player.pitchStream.listen(
      (e) => playback
        ..pitch = e
        ..notify(),
    );
    _player.loopModeStream.listen(
      (e) => playback
        ..playlistLoopMode = {
          LoopMode.off: PlaylistLoopMode.none,
          LoopMode.one: PlaylistLoopMode.single,
          LoopMode.all: PlaylistLoopMode.loop,
        }[e]!
        ..notify(),
    );
    _player.positionStream.listen(
      (e) => playback
        ..position = e
        ..notify(),
    );
    _player.durationStream.listen(
      (e) => playback
        ..duration = e ?? Duration.zero
        ..notify(),
    );
    _player.playingStream.listen(
      (e) => playback
        ..isPlaying = e
        ..notify(),
    );
    _player.shuffleModeEnabledStream.listen(
      (e) => playback
        ..isShuffling = e
        ..notify(),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> play() async {
    // If [play] is called after the playback was finished.
    // Then, player gets stuck in a fixed state, unless seeked.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: 0);
    }
    _player.play();
    playback
      ..isPlaying = true
      ..notify();
  }

  @override
  Future<void> pause() async {
    _player.pause();
    playback
      ..isPlaying = false
      ..notify();
  }

  @override
  Future<void> seek(position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
    await play();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
    await play();
  }

  @override
  Future<void> skipToQueueItem(index) {
    if (index != _player.currentIndex) {
      return _player.seek(
        Duration.zero,
        index: index,
      );
    }
    return Future.value(null);
  }

  @override
  Future<void> setSpeed(speed) => _player.setSpeed(speed);

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  Future<void> setVolume(volume) async {
    if (volume <= 1.0) {
      await _player.setVolume(volume);
      await _playerAndroidLoudnessEnhancer.setEnabled(false);
    } else {
      _player.setVolume(1.0);
      await _playerAndroidLoudnessEnhancer.setEnabled(true);
      await _playerAndroidLoudnessEnhancer.setTargetGain(20.0 * (volume - 1.0));
    }
  }

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  Future<void> setPitch(volume) => _player.setPitch(volume);

  @override
  Future<void> setRepeatMode(repeatMode) => _player.setLoopMode({
        AudioServiceRepeatMode.all: LoopMode.all,
        AudioServiceRepeatMode.one: LoopMode.one,
        AudioServiceRepeatMode.none: LoopMode.off,
      }[repeatMode]!);

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  Future<void> toggleMute() async {
    if (_muted) {
      await _player.setVolume(_volume);
    } else {
      _volume = _player.volume;
      await _player.setVolume(0.0);
    }
    _muted = !_muted;
    playback
      ..isMuted = _muted
      ..notify();
  }

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  /// [play] is passed as `false` only when restoring the app state from [Playback.loadAppState].
  Future<void> open(
    List<Track> tracks, {
    int index = 0,
    bool play = true,
  }) async {
    // Cause notification to be dismissed.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
    // Stop existing playback.
    await _player.stop();
    // This has been done to safely handle the issues with media notification, UI update when
    // handling the intent from Android.
    final playlist = ConcatenatingAudioSource(
      children: tracks
          .map((e) => AudioSource.uri(
                LibmpvPluginUtils.redirect(e.uri),
                tag: e.toJson(),
              ))
          .toList(),
    );
    queue.add(tracks.map((e) => _trackToMediaItem(e)).toList());
    playback
      ..tracks = tracks
      ..notify();
    await _player.setAudioSource(
      playlist,
      initialIndex: index,
    );
    if (play) {
      _player.play();
      // Update [mediaItem] regardless, since index change won't happen.
      mediaItem.add(_trackToMediaItem(tracks[index]));
    }
  }

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  Future<void> add(List<Track> tracks) {
    queue.add(queue.value + tracks.map(_trackToMediaItem).toList());
    playback
      ..tracks = playback.tracks + tracks
      ..notify();
    return (_player.audioSource as ConcatenatingAudioSource).addAll(
      tracks
          .map((e) => AudioSource.uri(LibmpvPluginUtils.redirect(e.uri),
              tag: e.toJson()))
          .toList(),
    );
  }

  @override
  Future<void> addQueueItem(mediaItem) async {
    queue.add(queue.value + [mediaItem]);
    playback
      ..tracks = playback.tracks + [Track.fromJson(mediaItem.extras)]
      ..notify();
    return (_player.audioSource as ConcatenatingAudioSource).add(
      AudioSource.uri(
        LibmpvPluginUtils.redirect(Uri.parse(mediaItem.id)),
        tag: mediaItem.extras,
      ),
    );
  }

  @override
  Future<void> setShuffleMode(shuffleMode) {
    return _player.setShuffleModeEnabled(
      {
        AudioServiceShuffleMode.all: true,
        AudioServiceShuffleMode.none: false,
      }[shuffleMode]!,
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.playPause,
        MediaAction.stop,
        MediaAction.setShuffleMode,
        MediaAction.setSpeed,
      },
      androidCompactActionIndices: const [
        0,
        1,
        2,
      ],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        // Hide the media session notification when the currently playing media or playlist is complete.
        ProcessingState.completed: AudioProcessingState.idle,
      }[_player.processingState]!,
      // The audio playback needs to be interpreted as paused once the playback of a media is completed.
      playing:
          _player.playing && _player.processingState == ProcessingState.ready,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  static MediaItem _trackToMediaItem(Track track) => MediaItem(
        id: track.uri.toString(),
        title: track.trackName,
        album: !track.hasNoAvailableAlbum ? track.albumName : null,
        artist: !track.hasNoAvailableArtists
            ? track.trackArtistNames.take(2).join(', ')
            : !track.hasNoAvailableAlbumArtists
                ? track.albumArtistName
                : null,
        genre: track.genre,
        duration: track.duration,
        artUri: () {
          Uri? image;
          if (LibmpvPluginUtils.isSupported(track.uri)) {
            final artwork = getAlbumArt(track, small: true);
            image = Uri.parse((artwork as ExtendedNetworkImageProvider).url);
          } else {
            final artwork = getAlbumArt(track);
            image = (artwork as ExtendedFileImageProvider).file.uri;
          }
          return image;
        }(),
        extras: track.toJson(),
      );

  /// [AudioPlayer] instance from `package:just_audio`.
  late final AudioPlayer _player;
  final AndroidEqualizer _playerAndroidEqualizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer _playerAndroidLoudnessEnhancer =
      AndroidLoudnessEnhancer();
  final Playback playback;
  // Encapsulated private attributes which are used to maintain & restore the mute state.
  bool _muted = false;
  double _volume = 0.0;
}
