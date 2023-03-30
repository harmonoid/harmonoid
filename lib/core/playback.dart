/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:external_media_provider/external_media_provider.dart';
import 'package:media_library/media_library.dart' hide Media, Playlist;
import 'package:ytm_client/ytm_client.dart' hide Media, Track, Playlist;
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/android_tag_reader.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';

// NOTE: This is very spaghetti code. I will attempt to refactor it sometime in the future.
// Since it has been well tested & stable after a lot of iterations, I am not going to touch it for now.

/// Playback
/// --------
///
/// Media playback handler in [Harmonoid](https://github.com/harmonoid/harmonoid).
///
/// Features:
///
/// * Platform independence.
/// * State changes.
/// * [Lyrics] update.
/// * Notification lyrics.
/// * Discord Rich Presence.
/// * D-Bus MPRIS controls for GNU/Linux.
/// * `ITaskbarList3` & `SystemMediaTransportControls` controls for Windows.
///
class Playback extends ChangeNotifier {
  /// [Playback] object instance. Must call [Playback.initialize].
  static final Playback instance = Playback();

  int index = DefaultPlaybackValues.index;
  List<Track> tracks = DefaultPlaybackValues.tracks;
  double rate = DefaultPlaybackValues.rate;
  double pitch = DefaultPlaybackValues.pitch;
  double volume = DefaultPlaybackValues.volume;
  bool shuffling = DefaultPlaybackValues.shuffling;
  PlaylistLoopMode playlistLoopMode = DefaultPlaybackValues.playlistLoopMode;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool muted = false;
  bool playing = false;
  bool buffering = false;
  bool completed = false;

  // Consumed from [Player] of `package:media_kit`.
  AudioParams audioParams = AudioParams();
  double? audioBitrate;
  // Consumed from [AndroidTagReader] of `package:harmonoid`.
  AndroidMediaFormat androidAudioFormat = AndroidMediaFormat();

  Future<void> play() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.play();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.play();
    }
  }

  Future<void> pause() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.pause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.pause();
    }
  }

  Future<void> playOrPause() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.playOrPause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      if (playing) {
        await pause();
      } else {
        await play();
      }
    }
  }

  Future<void> next() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.next();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.skipToNext();
    }
  }

  Future<void> previous() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.previous();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.skipToPrevious();
    }
  }

  Future<void> jump(int index) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.jump(index);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.skipToQueueItem(index);
    }
  }

  Future<void> setRate(double value) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setRate(value);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.setSpeed(value);
    }
    rate = value;
    try {
      if (Platform.isLinux) {
        instance.mpris?.rate = value;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setVolume(value);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.setVolume(value / 100.0);
    }
    volume = value;
    try {
      if (Platform.isLinux) {
        instance.mpris?.volume = value / 100.0;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    notifyListeners();
  }

  Future<void> setPitch(double value) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setPitch(value);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.setPitch(value);
    }
    pitch = value;
    notifyListeners();
  }

  Future<void> setPlaylistLoopMode(PlaylistLoopMode value) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setPlaylistMode(
        PlaylistMode.values[value.index],
      );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.setRepeatMode(
        AudioServiceRepeatMode.values[value.index],
      );
    }
    playlistLoopMode = value;
    try {
      if (Platform.isLinux) {
        instance.mpris?.loopStatus =
            MPRISLoopStatus.values[instance.playlistLoopMode.index];
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (muted) {
      await setVolume(_volume);
    } else {
      _volume = volume;
      await setVolume(0.0);
    }
    muted = !muted;
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setShuffle(!shuffling);
      shuffling = !shuffling;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      // Handled through [StreamSubscription] on the Android.
      await audioService?.setShuffleMode(
        !shuffling ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player!.seek(position);
      Future.delayed(const Duration(milliseconds: 100), () {
        // Notify Discord RPC about the change in the position.
        notifyDiscordRPC();
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.seek(position);
      await audioService?.play();
    }
  }

  Future<void> open(List<Track> tracks, {int index = 0}) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final items = <Media>[];
      for (final track in tracks) {
        items.add(
          Media(
            ExternalMedia.redirect(track.uri).toString(),
            extras: track.toJson(),
          ),
        );
      }
      await player?.open(Playlist(items, index: index));
      // `package:media_kit` resets the shuffle state after loading new playlist.
      shuffling = false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      this.tracks = tracks;
      await audioService?.open(tracks, index: index);
    }

    // TODO(@alexmercerind): Refactor this to be outside of this class. Tight coupling is bad.
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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      for (final track in tracks) {
        await player?.add(
          Media(
            ExternalMedia.redirect(track.uri).toString(),
            extras: track.toJson(),
          ),
        );
      }
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.add(tracks);
    }
  }

  /// Load the last played playback state.
  ///
  /// Passing [open] as `false` causes file to not be opened inside [player] or [audioService].
  ///
  Future<void> loadAppState({bool open = true}) async {
    rate = AppState.instance.rate;
    pitch = AppState.instance.pitch;
    volume = AppState.instance.volume;
    shuffling = AppState.instance.shuffling;
    playlistLoopMode = AppState.instance.playlistLoopMode;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player?.setRate(rate);
      await player?.setPitch(pitch);
      await player?.setVolume(volume);
      await player?.setPlaylistMode(
        PlaylistMode.values[playlistLoopMode.index],
      );
      // Restore the custom player options/properties defined by the user.
      for (final entry in Configuration.instance.userLibmpvOptions.entries) {
        if (player?.platform is libmpvPlayer) {
          await (player?.platform as libmpvPlayer?)?.setProperty(
            entry.key,
            entry.value,
          );
        }
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
        shuffling ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      );
    }
    if (!open) return;
    index = AppState.instance.index;
    tracks = AppState.instance.tracks;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final items = <Media>[];
      for (final track in tracks) {
        items.add(
          Media(
            ExternalMedia.redirect(track.uri).toString(),
            extras: track.toJson(),
          ),
        );
      }
      await player?.open(
        Playlist(
          items,
          index: AppState.instance.index,
        ),
        play: false,
      );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await audioService?.open(
        tracks,
        index: AppState.instance.index,
        play: false,
      );
    }
  }

  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      instance.player = Player(
        configuration: PlayerConfiguration(
          vid: false,
          osc: false,
          pitch: true,
          title: 'Harmonoid',
        ),
      );
      instance.player?.streams.playlist.listen((event) async {
        // Boundary checking.
        if (event.index < 0 || event.index > event.medias.length - 1) {
          return;
        }
        instance.index = event.index;
        // Use another [Isolate] to deserialize the [Track]s playlist.
        instance.tracks = await compute<List, List<Track>>(
          (message) => message.map((e) => Track.fromJson(e.extras)).toList(),
          event.medias,
        );
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.player?.streams.playing.listen((event) {
        instance.playing = event;
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.player?.streams.buffering.listen((event) {
        instance.buffering = event;
        instance.notifyListeners();
        instance.notifyNativeListeners();
      });
      instance.player?.streams.completed.listen((event) async {
        instance.completed = event;
        instance.notifyListeners();
      });
      //
      instance.player?.streams.position
          // In `package:media_kit`, position update rate is very high.
          // Filter out the updates that are too close to each other.
          // This will reduce the number of re-builds & optimize performance.
          .distinct((a, b) => (a - b).abs() < const Duration(milliseconds: 200))
          .listen((event) {
        if (instance.interceptPositionChangeRebuilds) {
          // Refer to the comment in [interceptPositionChangeRebuilds].
          return;
        }
        instance.position = event;
        instance.notifyListeners();
        // Windows: Update the `ITaskbarList3` progress indicator.
        try {
          if (Platform.isWindows && Configuration.instance.taskbarIndicator) {
            WindowsTaskbar.setProgress(
              instance.position.inMilliseconds,
              instance.duration.inMilliseconds,
            );
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        // Linux: Update the MPRIS position.
        try {
          if (Platform.isLinux) {
            instance.mpris?.position = event;
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        try {
          // [PlaylistLoopMode.single] needs to update [endTimeStamp] in Discord RPC.
          if (event == Duration.zero) {
            instance.notifyDiscordRPC();
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      });
      instance.player?.streams.duration.listen((event) {
        instance.duration = event;
        instance.notifyListeners();
      });
      instance.player?.streams.audioParams.listen((event) {
        instance.audioParams = event;
        instance.notifyListeners();
        try {
          instance.notifyDiscordRPC();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      });
      instance.player?.streams.audioBitrate.listen((event) {
        instance.audioBitrate = event;
        instance.notifyListeners();
        try {
          instance.notifyDiscordRPC();
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
      });
      // MPRIS & System Media Transport Controls.
      try {
        // MPRIS.
        if (Platform.isLinux) {
          instance.mpris = await MPRIS.create(
            busName: 'org.mpris.MediaPlayer2.harmonoid',
            identity: 'Harmonoid',
            desktopEntry: '/usr/share/applications/harmonoid',
          );
          instance.mpris?.minimumRate = 0.5;
          instance.mpris?.maximumRate = 2.0;
          instance.mpris?.setEventHandler(
            MPRISEventHandler(
              play: instance.play,
              pause: instance.pause,
              playPause: instance.playOrPause,
              next: instance.next,
              previous: instance.previous,
              seek: instance.seek,
              rate: instance.setRate,
              // [MPRIS] operates in range [0.0, 1.0] while [Playback] operates in range [0.0, 100.0].
              volume: (value) => instance.setVolume(value * 100.0),
              shuffle: (value) async {
                if (value == instance.shuffling) return;
                await instance.toggleShuffle();
              },
              setPosition: (_, value) => instance.jump(value),
              openUri: (value) => Intent.instance.playURI(value.toString()),
              loopStatus: (value) => instance.setPlaylistLoopMode(
                PlaylistLoopMode.values[value.index],
              ),
            ),
          );
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
      // Discord RPC.
      instance.discord = DiscordRPC(applicationId: '881480706545573918');
    }
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

  void notifyNativeListeners() async {
    try {
      // Boundary checking.
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
        }();
        if (Platform.isWindows) {
          // `package:windows_taskbar`
          try {
            if (Configuration.instance.taskbarIndicator) {
              WindowsTaskbar.setProgressMode(
                buffering
                    ? TaskbarProgressMode.indeterminate
                    : TaskbarProgressMode.normal,
              );
            }
            WindowsTaskbar.setWindowTitle(
              [
                track.trackName,
                if (!track.trackArtistNamesNotPresent)
                  track.trackArtistNames.take(2).join(', '),
                'Harmonoid',
              ].join(' • '),
            );
            WindowsTaskbar.setThumbnailToolbar(
              [
                ThumbnailToolbarButton(
                  ThumbnailToolbarAssetIcon('assets/icons/previous.ico'),
                  Language.instance.PREVIOUS,
                  previous,
                  mode: index == 0 ? ThumbnailToolbarButtonMode.disabled : 0,
                ),
                ThumbnailToolbarButton(
                  ThumbnailToolbarAssetIcon(
                    playing
                        ? 'assets/icons/pause.ico'
                        : 'assets/icons/play.ico',
                  ),
                  playing ? Language.instance.PAUSE : Language.instance.PLAY,
                  playing ? pause : play,
                ),
                ThumbnailToolbarButton(
                  ThumbnailToolbarAssetIcon('assets/icons/next.ico'),
                  Language.instance.NEXT,
                  next,
                  mode: index == tracks.length - 1
                      ? ThumbnailToolbarButtonMode.disabled
                      : 0,
                ),
              ],
            );
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
          // `package:system_media_transport_controls`
          try {
            SystemMediaTransportControls.instance.setStatus(
              playing ? SMTCStatus.playing : SMTCStatus.paused,
            );
            SystemMediaTransportControls.instance.setMusicData(
              title: track.trackName,
              artist: track.trackArtistNamesNotPresent
                  ? null
                  : track.trackArtistNames.take(2).join(', '),
              albumArtist: track.albumArtistNameNotPresent
                  ? null
                  : track.albumArtistName,
              albumTitle: track.albumName,
              trackNumber: track.trackNumber,
            );
            if (ExternalMedia.supported(track.uri)) {
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
        // `package:mpris_service`
        if (Platform.isLinux) {
          Uri? image;
          if (ExternalMedia.supported(track.uri)) {
            final artwork = getAlbumArt(track, small: true);
            image = Uri.parse((artwork as ExtendedNetworkImageProvider).url);
          } else {
            final artwork = getAlbumArt(track);
            image = (artwork as ExtendedFileImageProvider).file.uri;
          }
          instance.mpris?.playbackStatus = instance.completed
              ? MPRISPlaybackStatus.stopped
              : instance.playing
                  ? MPRISPlaybackStatus.playing
                  : MPRISPlaybackStatus.paused;
          instance.mpris?.metadata = MPRISMetadata(
            track.uri,
            artUrl: image,
            length: duration,
            title: track.trackName,
            album: track.albumArtistNameNotPresent ? null : track.albumName,
            artist: track.trackArtistNamesNotPresent
                ? null
                : track.trackArtistNames,
            albumArtist: track.albumArtistNameNotPresent
                ? null
                : [track.albumArtistName],
            trackNumber: track.trackNumber,
            discNumber: track.discNumber,
            firstUsed: track.timeAdded,
            genre: track.genresNotPresent ? null : track.genres,
          );
        }
        // Discord RPC gibberish.
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Fetch [largeImageKey] if the current [track] was changed.
          if (track != _discordPreviousTrack) {
            _discordPreviousLargeImageKey = ExternalMedia.supported(track.uri)
                ? ExternalMedia.thumbnail(track.uri, small: true).toString()
                : await (() async {
                    // Chances are file has no tagged metadata, thus fallback to the default album art.
                    if (track.albumNameNotPresent &&
                        track.trackArtistNamesNotPresent &&
                        track.albumArtistNameNotPresent) {
                      return 'default_album_art';
                    }
                    final search = [
                      track.trackName,
                      if (!track.trackArtistNamesNotPresent)
                        track.trackArtistNames.take(1).join('')
                      else if (!track.albumArtistNameNotPresent)
                        track.albumArtistName
                      else if (!track.albumNameNotPresent)
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
            if (!track.trackArtistNamesNotPresent)
              track.trackArtistNames.take(1).join('')
            else if (!track.albumArtistNameNotPresent)
              track.albumArtistName,
          ].join(' ');
          if (!completed) {
            final title = track.trackName,
                subtitle = !track.trackArtistNamesNotPresent
                    ? track.trackArtistNames.join(', ')
                    : !track.albumArtistNameNotPresent
                        ? track.albumArtistName
                        : '';
            final details = track.uri.isScheme('FILE')
                ? [title, subtitle].join(' • ')
                : track.trackName;
            final state =
                track.uri.isScheme('FILE') ? audioFormatLabelSmall : subtitle;
            discord?.start(autoRegister: true);
            discord?.updatePresence(
              DiscordPresence(
                details: details,
                state: state,
                largeImageKey: _discordPreviousLargeImageKey,
                largeImageText:
                    !track.albumNameNotPresent ? track.albumName : null,
                smallImageKey: playing ? 'play' : 'pause',
                smallImageText: playing ? 'Playing' : 'Paused',
                button1Label: track.uri.isScheme('FILE') ? 'Find' : 'Listen',
                button1Url: track.uri.isScheme('FILE')
                    ? 'https://www.google.com/search?q=${Uri.encodeComponent(search)}'
                    : track.uri.toString(),
                endTimeStamp: playing
                    ? DateTime.now().millisecondsSinceEpoch +
                        duration.inMilliseconds -
                        position.inMilliseconds
                    : null,
              ),
            );
          }
          if (completed) {
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
  Future<void> saveAppState() => AppState.instance.save(
        index,
        tracks,
        rate,
        pitch,
        volume,
        shuffling,
        playlistLoopMode,
      );

  @override
  // ignore: must_call_super
  Future<void> dispose() async {
    await player?.dispose();
  }

  /// `package:player` [Player] instance used on Windows, Linux & macOS.
  Player? player;

  /// `package:just_audio` & `package:audio_service` based [_HarmonoidMobilePlayer] instance used on Android & iOS.
  _HarmonoidMobilePlayer? audioService;

  /// `package:dart_discord_rpc` based [DiscordRPC] instance used on Windows, Linux & macOS.
  DiscordRPC? discord;

  /// This is used to keep the last found artwork URI or image key. It prevents redundant requests for the same [Track].
  String? _discordPreviousLargeImageKey;

  /// Current [Track] being used in the Discord RPC.
  Track? _discordPreviousTrack;

  /// For synchronizing Discord RPC calls.
  final Lock _discordLock = Lock();

  /// MPRIS controls for Linux.
  MPRIS? mpris;

  /// The volume that is restored to, before the unmute.
  double _volume = 0.0;

  /// Public getter.
  bool get isFirstTrack => index == 0;

  /// Public getter.
  bool get isLastTrack => index == tracks.length - 1;

  /// NOTE: Only for Windows / GNU/Linux / macOS.
  /// In current analysis, I have observed that rebuilds in the seekbar [Slider] present on [NowPlayingBar] causes substantial lag in the hero animations.
  /// By setting [interceptPositionChangeRebuilds] to `true`, whenever a [Route] is in the middle of transition, the [NowPlayingBar] will not rebuild. This causes experience to be jittery.
  /// Since, the transition is only visible for 300 ~ 400ms, this should be fine. While, the animation will be buttery smooth to the user's eyes.
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
  static double rate = 1.0;
  static double pitch = 1.0;
  static double volume =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 50.0 : 100.0;
  static bool shuffling = false;
  static PlaylistLoopMode playlistLoopMode = PlaylistLoopMode.none;
}

/// Android/iOS specific implementation for audio playback & media notification.
///
/// Completely based around the `package:just_audio` and `package:audio_service` packages.
///
/// This class is used in composition with the parent [Playback] class & can be accessed from its singleton available as [Playback.instance].
/// Takes existing [Playback] reference as [playback]. This is tightly coupled with the parent [Playback] class.
class _HarmonoidMobilePlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  _HarmonoidMobilePlayer(this.playback) {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects:
            Configuration.instance.androidEnableVolumeBoostFilter
                ? [_androidLoudnessEnhancer]
                : null,
      ),
    );
    _player.playbackEventStream.listen((e) {
      debugPrint(e.processingState.toString());
      if (e.processingState == ProcessingState.completed) {
        // The audio playback needs to be interpreted as paused once the playback of a media is completed.
        playback.playing = false;
      }
      playback
        ..completed = e.processingState == ProcessingState.completed
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
                if (ExternalMedia.supported(Uri.parse(queue.value[e].id))) {
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
        ..playing = e
        ..notify(),
    );
    _player.shuffleModeEnabledStream.listen(
      (e) => playback
        ..shuffling = e
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
      ..playing = true
      ..notify();
  }

  @override
  Future<void> pause() async {
    _player.pause();
    playback
      ..playing = false
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
    await play();
  }

  @override
  Future<void> skipToPrevious() async {
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
      await _androidLoudnessEnhancer.setEnabled(false);
    } else {
      _player.setVolume(1.0);
      await _androidLoudnessEnhancer.setEnabled(true);
      await _androidLoudnessEnhancer.setTargetGain(20.0 * (volume - 1.0));
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
      ..muted = _muted
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
    Intent.instance.preemptPlayURI();
    // Cause notification to be dismissed.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
    // Stop existing playback.
    await _player.stop();
    // This has been done to safely handle the issues with media notification, UI update when handling the intent from Android.
    final children = <AudioSource>[];
    for (final track in tracks) {
      children.add(AudioSource.uri(
        ExternalMedia.redirect(track.uri),
        tag: track.toJson(),
      ));
    }
    final playlist = ConcatenatingAudioSource(children: children);
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
            if (ExternalMedia.supported(tracks[index].uri)) {
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
    final children = <AudioSource>[];
    for (final track in tracks) {
      children.add(AudioSource.uri(
        ExternalMedia.redirect(track.uri),
        tag: track.toJson(),
      ));
    }
    return source.addAll(children);
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
        ExternalMedia.redirect(Uri.parse(mediaItem.id)),
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
        album: !track.albumNameNotPresent ? track.albumName : null,
        artist: !track.trackArtistNamesNotPresent
            ? track.trackArtistNames.take(2).join(', ')
            : !track.albumArtistNameNotPresent
                ? track.albumArtistName
                : null,
        duration: track.duration,
        extras: track.toJson(),
      );

  /// [AudioPlayer] instance from `package:just_audio`.
  late final AudioPlayer _player;
  final AndroidLoudnessEnhancer _androidLoudnessEnhancer =
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
    return _fetchFormatLock.synchronized(
      () async {
        playback
          ..androidAudioFormat = await AndroidTagReader.instance.format(uri)
          ..notify();
      },
    );
  }

  /// This is used to maintain synchronization with [MetadataRetriever.format] calls.
  final Lock _fetchFormatLock = Lock();
}
