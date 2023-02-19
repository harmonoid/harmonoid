/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_engine/media_engine.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:extended_image/extended_image.dart';
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
import 'package:harmonoid/utils/metadata_retriever.dart';
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
  // Only for Windows & Linux.
  AudioParams audioParams = AudioParams();
  double? audioBitrate;
  // Only for Android.
  AndroidMediaFormat androidAudioFormat = AndroidMediaFormat();

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

  void next({bool skipAndPlay = true}) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.next();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.skipToNext(seekAndPlay: skipAndPlay);
    }
  }

  void previous({bool skipAndPlay = true}) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      libmpv?.previous();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      audioService?.skipToPrevious(seekAndPlay: skipAndPlay);
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
    instance.mpris?.rate = value;
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
    instance.mpris?.volume = value;
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

  void seek(Duration position, {bool seekAndPlay = true}) async {
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
      if (seekAndPlay) {
        await audioService?.play();
      }
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
    // TODO(alexmercerind): Tighly coupled impl.
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

  Future<void> add(List<Track> tracks) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      for (final track in tracks) {
        await libmpv?.add(
          Media(
            LibmpvPluginUtils.redirect(track.uri).toString(),
            extras: track.toJson(),
          ),
        );
      }
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.add(tracks);
    }
  }

  Future<void> insertAt(List<Track> tracks, int index) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // await libmpv?.remove(
      //   index,
      // );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.insertAt(tracks, index);
    }
  }

  Future<void> removeAt(int index) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await libmpv?.remove(
        index,
      );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.removeAt(index);
    }
  }

  Future<void> removeRange(int first, int last) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await libmpv?.remove(
        index,
      );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.removeRange(first, last);
    }
  }

  Future<void> removeAndInsertAt(
      List<Track> tracks, int oldIndex, int newIndex) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // await libmpv?.remove(
      //   index,
      // );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.removeAndInsertAt(tracks, oldIndex, newIndex);
    }
  }

  void updateFadeVolume() {
    audioService?.updateFadeVolume();
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

      // Shuffle is per-playlist, so this is meaningless for current `package:media_engine` implementation.
      // libmpv?.shuffle = isShuffling;

      // Restore the custom libmpv options set by the user.
      for (final option in Configuration.instance.userLibmpvOptions.keys) {
        await libmpv?.setProperty(
          option,
          Configuration.instance.userLibmpvOptions[option]!,
        );
      }
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
        if (Platform.isWindows && Configuration.instance.taskbarIndicator) {
          WindowsTaskbar.setProgress(
            instance.position.inMilliseconds,
            instance.duration.inMilliseconds,
          );
        }
        if (Platform.isLinux) {
          instance.mpris?.position = event;
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
      instance.libmpv?.streams.audioParams.listen((event) {
        instance.audioParams = event;
        instance.notifyListeners();
      });
      instance.libmpv?.streams.audioBitrate.listen((event) {
        instance.audioBitrate = event;
        instance.notifyListeners();
      });
      try {
        // MPRIS.
        if (Platform.isLinux) {
          instance.mpris = MPRIS(instance);
        }
        // System Media Transport Controls.
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
  }

  // void addToTopSongPlaylist() {
  //   var currentValue = Playback.instance;
  //   int elapsedTime = 0;
  //   int firstTime = 0;
  //   firstTime = DateTime.now().millisecondsSinceEpoch;
  //   currentValue.addListener(() {
  //     if (currentValue.isPlaying) {
  //       if (elapsedTime == firstTime + 5000) {
  //         print("STOPWATCH ADDEDDDDD");
  //       } else {
  //         print("STOPWATCH ffffffffffffffffffff$firstTime");
  //         elapsedTime = DateTime.now().millisecondsSinceEpoch;
  //       }
  //       // debugPrint("STOPWATCH $elapsedTime");
  //     }
  //   });
  // }

  // void addToTopSongPlaylist() {
  //   Stopwatch stopwatch = new Stopwatch();
  //   var currentValue = Playback.instance;
  //   currentValue.addListener(() {
  //     if (currentValue.isPlaying) {
  //       stopwatch.start();
  //     } else {
  //       stopwatch.stop();
  //       var timeSpent = stopwatch.elapsed;
  //       print("Time spent: $timeSpent");
  //       stopwatch.reset();
  //     }
  //   });
  // }
  // void addToTopSongPlaylist() {
  //   var currentValue = Playback.instance;

  //   int? playStart;
  //   int totalElapsedTime = 0;
  //   int threshold = 10 * 1000; // 30 seconds in milliseconds

  //   currentValue.addListener(() {
  //     if (currentValue.isPlaying) {
  //       print("valueeee ${totalElapsedTime}");
  //       if (playStart == null) {
  //         playStart = DateTime.now().millisecondsSinceEpoch;
  //       } else {
  //         totalElapsedTime +=
  //             DateTime.now().millisecondsSinceEpoch - playStart!;
  //         playStart = DateTime.now().millisecondsSinceEpoch;
  //       }
  //       if (totalElapsedTime >= threshold) {
  //         Collection.instance.playlistAddTrack(
  //           Collection.instance.topSongsPlaylist,
  //           tracks[index],
  //         );
  //         totalElapsedTime = 0;
  //       }
  //     } else {
  //       totalElapsedTime += DateTime.now().millisecondsSinceEpoch - playStart!;
  //       playStart = null;
  //     }
  //   });

  //   // Future.delayed(Duration(seconds: 4), () {
  //   //   Collection.instance.playlistAddTrack(
  //   //     Collection.instance.topSongsPlaylist,
  //   //     tracks[index],
  //   //   );
  //   // });
  // }

  void notifyNativeListeners() async {
    try {
      if (index < 0 || index > tracks.length - 1) {
        return;
      }
      final track = tracks[index];
      NowPlayingColorPalette.instance.update(track);
      Lyrics.instance.update(track);
      try {
        // Add to History in asynchronous suspension.
        () async {
          if (Collection.instance.historyPlaylist.tracks.isEmpty) {
            Collection.instance.playlistAddTrack(
              Collection.instance.historyPlaylist,
              track,
            );
          } else if (Collection.instance.historyPlaylist.tracks.first !=
              track) {
            Collection.instance.playlistAddTrack(
              Collection.instance.historyPlaylist,
              track,
            );
          }
          // addToTopSongPlaylist();
        }();
        if (Platform.isWindows) {
          if (Configuration.instance.taskbarIndicator) {
            WindowsTaskbar.setProgressMode(isBuffering
                ? TaskbarProgressMode.indeterminate
                : TaskbarProgressMode.normal);
          }
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
                isPlaying ? 'assets/icons/pause.ico' : 'assets/icons/play.ico',
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
          instance.mpris
            ?..isPlaying = isPlaying
            ..isCompleted = isCompleted
            ..index = index
            ..playlist = tracks.map((e) {
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

  /// MPRIS controls for Linux.
  MPRIS? mpris;

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
class MPRIS extends MPRISService {
  /// The [Playback] object present as composition in this class.
  final Playback playback;

  MPRIS(this.playback)
      : super(
          'harmonoid',
          identity: 'Harmonoid',
          desktopEntry: '/usr/share/applications/harmonoid.desktop',
        );

  @override
  void setLoopStatus(String value) {
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
  void setRate(double value) {
    Playback.instance.setRate(value);
  }

  @override
  void setShuffle(bool value) {
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
  void doSeek(int value) {
    Playback.instance.seek(Duration(microseconds: value));
  }

  @override
  void doSetPosition(String objectPath, int timeMicroseconds) {
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
  void doOpenUri(Uri uri) {
    Intent.instance.playURI(uri.toString());
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
///
class _HarmonoidMobilePlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  _HarmonoidMobilePlayer(this.playback) {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          // TODO: Missing implementation for [AndroidEqualizer].
          // _playerAndroidEqualizer,
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
        // Request for album art for the current track.
        // More performant than requesting for all the album arts at once inside [_transformEvent].
        if (e >= 0 && e < queue.value.length) {
          debugPrint(queue.value[e].toString());
          mediaItem.add(
            queue.value[e].copyWith(
              artUri: () {
                Uri? image;
                if (LibmpvPluginUtils.isSupported(
                    Uri.parse(queue.value[e].id))) {
                  final artwork = getAlbumArt(
                    Track.fromJson(queue.value[e].extras),
                    small: true,
                  );
                  image =
                      Uri.parse((artwork as ExtendedNetworkImageProvider).url);
                } else {
                  final artwork = getAlbumArt(
                    Track.fromJson(
                      queue.value[e].extras,
                    ),
                  );
                  image = (artwork as ExtendedFileImageProvider).file.uri;
                }
                return image;
              }(),
            ),
          );
          // Update [Playback.format] using [MetadataRetriever].
          fetchFormat(Uri.parse(queue.value[e].id));
        }
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
    _player.positionStream
        .distinct(
          (previous, next) =>
              (next - previous).abs() < const Duration(milliseconds: 200),
        )
        .listen(
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

  double _fadeVolume = 1.0;

  void updateFadeVolume() {
    _fadeVolume = _player.volume;
  }

  void playWithFadeEffect() {
    fadeVolumeFromTo(0, _fadeVolume, 250);
    _player.play();
    playback..isPlaying = true;
  }

  void pauseWithFadeEffect() {
    updateFadeVolume();
    fadeVolumeFromTo(_fadeVolume, 0, 250);
    Future.delayed(Duration(milliseconds: 250), () {
      _player.pause();
      playback
        ..isPlaying = false
        ..notify();
    });
  }

  @override
  Future<void> play() async {
    // If [play] is called after the playback was finished.
    // Then, player gets stuck in a fixed state, unless seeked.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: 0);
    }

    if (Configuration.instance.enableVolumeFadeOnPlayPause) {
      playWithFadeEffect();
    } else {
      // this step is useful for the case when the user pauses while [enableFade] is true, then set it to false then play again
      _player.setVolume(_fadeVolume);

      _player.play();
      playback
        ..isPlaying = true
        ..notify();
    }
  }

  @override
  Future<void> pause() async {
    if (Configuration.instance.enableVolumeFadeOnPlayPause) {
      pauseWithFadeEffect();
    } else {
      _player.pause();
      playback
        ..isPlaying = false
        ..notify();
    }
  }

  void fadeVolumeFromTo(double from, double to, int len) {
    double vol = from;
    double diff = to - from;
    double steps = (diff / 0.01).abs();
    int stepLen = max(4, (steps > 0) ? len ~/ steps : len);
    int lastTick = DateTime.now().millisecondsSinceEpoch;

    // // Update the volume value on each interval ticks
    Timer.periodic(new Duration(milliseconds: stepLen), (Timer? t) {
      var now = DateTime.now().millisecondsSinceEpoch;
      var tick = (now - lastTick) / len;
      lastTick = now;
      vol += diff * tick;

      vol = max(0, vol);
      vol = min(1, vol);
      vol = (vol * 100).round() / 100;

      _player.setVolume(vol);

      if ((to < from && vol <= to) || (to > from && vol >= to)) {
        if (t != null) {
          t.cancel();
          t = null;
        }
        _player.setVolume(vol);
      }
    });
  }

  @override
  Future<void> seek(position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext({bool seekAndPlay = true}) async {
    // Once [LoopMode.one] is enabled, force skipping to next index when [skipToNext] is called.
    if (_player.loopMode == LoopMode.one) {
      final next = playback.index + 1;
      await _player.seek(
        Duration.zero,
        index: next >= playback.tracks.length ? 0 : next,
      );
    } else {
      // Supports shuffle.
      _player.seekToNext();
    }
    if (seekAndPlay) {
      await play();
    }
  }

  @override
  Future<void> skipToPrevious({bool seekAndPlay = true}) async {
    // Once [LoopMode.one] is enabled, force skipping to previous index when [skipToPrevious] is called.
    if (_player.loopMode == LoopMode.one) {
      final previous = playback.index - 1;
      await _player.seek(
        Duration.zero,
        index: previous < 0 ? playback.tracks.length - 1 : previous,
      );
    } else {
      // Supports shuffle.
      _player.seekToPrevious();
    }
    if (seekAndPlay) {
      await play();
    }
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
      mediaItem.add(
        _trackToMediaItem(tracks[index]).copyWith(
          artUri: () {
            Uri? image;
            if (LibmpvPluginUtils.isSupported(tracks[index].uri)) {
              final artwork = getAlbumArt(
                tracks[index],
                small: true,
              );
              image = Uri.parse((artwork as ExtendedNetworkImageProvider).url);
            } else {
              final artwork = getAlbumArt(
                tracks[index],
              );
              image = (artwork as ExtendedFileImageProvider).file.uri;
            }
            return image;
          }(),
        ),
      );
      await fetchFormat(tracks[index].uri);
    }
  }

  /// For the [Playback] implementation.
  /// Not a part of `package:audio_service`.
  Future<void> add(List<Track> tracks) {
    queue.add(queue.value + tracks.map(_trackToMediaItem).toList());
    playback
      ..tracks = playback.tracks + tracks
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    final children = tracks
        .map(
          (e) => AudioSource.uri(
            LibmpvPluginUtils.redirect(e.uri),
            tag: e.toJson(),
          ),
        )
        .toList();
    return source.addAll(children);
  }

  Future<void> insertAt(List<Track> tracks, int index) {
    queue.value.insertAll(index, tracks.map(_trackToMediaItem).toList());
    playback.tracks.insertAll(index, tracks);
    playback
      ..tracks
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    final children = tracks
        .map(
          (e) => AudioSource.uri(
            LibmpvPluginUtils.redirect(e.uri),
            tag: e.toJson(),
          ),
        )
        .toList();
    return source.insertAll(index, children);
  }

  Future<void> removeAt(int index) {
    queue.value.removeAt(index);
    playback.tracks.removeAt(index);
    playback
      ..tracks
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    return source.removeAt(index);
  }

  Future<void> removeRange(int first, int last) {
    queue.value.removeRange(first, last);
    playback.tracks.removeRange(first, last);
    playback
      ..tracks
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    return source.removeRange(first, last);
  }

  Future<void> removeAndInsertAt(
      List<Track> tracks, int oldIndex, int newIndex) {
    queue.value.insert(newIndex,
        playback.tracks.map(_trackToMediaItem).toList().removeAt(oldIndex));
    playback.tracks.insert(newIndex, playback.tracks.removeAt(oldIndex));
    playback
      ..tracks
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    final children = tracks
        .map(
          (e) => AudioSource.uri(
            LibmpvPluginUtils.redirect(e.uri),
            tag: e.toJson(),
          ),
        )
        .toList();
    // didnt use move() because wont be useful when inserting numbers of tracks
    return source
        .removeAt(oldIndex)
        .then((value) => source.insertAll(newIndex, children))
        .then((value) => source.removeAt(playback.tracks.length));
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    queue.add(queue.value + [mediaItem]);
    playback
      ..tracks = playback.tracks + [Track.fromJson(mediaItem.extras)]
      ..notify();
    final source = _player.audioSource as ConcatenatingAudioSource;
    return source.add(
      AudioSource.uri(
        LibmpvPluginUtils.redirect(Uri.parse(mediaItem.id)),
        tag: mediaItem.extras,
      ),
    );
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) {
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
        extras: track.toJson(),
      );

  /// [AudioPlayer] instance from `package:just_audio`.
  late final AudioPlayer _player;

  /// TODO: Missing implementation for [AndroidEqualizer].
  /// final AndroidEqualizer _playerAndroidEqualizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer _playerAndroidLoudnessEnhancer =
      AndroidLoudnessEnhancer();
  final Playback playback;

  /// Encapsulated private attributes which are used to maintain & restore the mute state.
  bool _muted = false;
  double _volume = 0.0;

  /// Fetches [Playback.format] & notify listeners.
  Future<void> fetchFormat(Uri uri) {
    playback
      ..androidAudioFormat = AndroidMediaFormat()
      ..notify();
    // Update [Playback.format] using [MetadataRetriever].
    return _lock.synchronized(
      () async {
        playback
          ..androidAudioFormat = await MetadataRetriever.instance.format(uri)
          ..notify();
      },
    );
  }

  /// This is used to maintain synchronization with [MetadataRetriever.format] calls.
  final Lock _lock = Lock();
}
