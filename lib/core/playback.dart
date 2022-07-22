/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:libmpv/libmpv.dart';
import 'package:ytm_client/ytm_client.dart' hide Media, Track, Playlist;
import 'package:assets_audio_player/assets_audio_player.dart'
    as assets_audio_player;
import 'package:mpris_service/mpris_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/models/media.dart' hide Media, Playlist;
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/state/desktop_now_playing_controller.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/constants/language.dart';

/// Playback
/// --------
///
/// Class to handle & control the [Media] playback in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Implements [ChangeNotifier] to trigger UI updates.
///
/// Automatically handles:
/// * State changes.
/// * Platform independence.
/// * `ITaskbarList3` & `SystemMediaTransportControls` controls on Windows.
/// * D-Bus MPRIS controls on Linux.
/// * Discord RPC.
/// * Lyrics.
///
class Playback extends ChangeNotifier {
  /// [Playback] object instance.
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
      player.play();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.play();
    }
  }

  void pause() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.pause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.pause();
    }
  }

  void playOrPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void next() {
    player.play().then((value) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        player.next();
      }
    });
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.next();
    }
  }

  void previous() {
    player.play().then((value) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        player.back();
      }
    });
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.previous();
    }
  }

  void jump(int value) {
    if (Platform.isWindows || Platform.isLinux) {
      player.jump(value);
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.playlistPlayAtIndex(value);
    }
  }

  void setRate(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.rate = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.setPlaySpeed(value);
    }
    rate = value;
    if (Platform.isLinux) {
      _Harmonoid.instance.rate = value;
    }
    notifyListeners();
  }

  void setVolume(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.volume = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.setVolume(value);
    }
    volume = value;
    if (Platform.isLinux) {
      _Harmonoid.instance.volume = value;
    }
    notifyListeners();
  }

  void setPitch(double value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.pitch = value;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.setPitch(value);
    }
    pitch = value;
    notifyListeners();
  }

  void setPlaylistLoopMode(PlaylistLoopMode value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.setPlaylistMode(PlaylistMode.values[value.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer
          .setLoopMode(assets_audio_player.LoopMode.values[value.index]);
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
      player.shuffle = !isShuffling;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.toggleShuffle();
    }
    isShuffling = !isShuffling;
    notifyListeners();
  }

  void seek(Duration position) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.seek(position).then((value) {
        Future.delayed(const Duration(milliseconds: 100), () {
          // [endTimeStamp] update needs to be sent.
          _updateDiscordRPC();
        });
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.seek(position);
    }
  }

  Future<void> open(List<Track> tracks, {int index = 0}) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await player.open(
        Playlist(
          tracks
              .map((e) => Media(
                    Plugins.redirect(e.uri).toString(),
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
      await assetsAudioPlayer.open(
        assets_audio_player.Playlist(
            startIndex: index,
            audios: tracks.map((e) {
              Uri? image;
              if (Plugins.isWebMedia(e.uri)) {
                final artwork = getAlbumArt(e, small: true);
                image =
                    Uri.parse((artwork as ExtendedNetworkImageProvider).url);
              } else {
                final artwork = getAlbumArt(e);
                image = (artwork as ExtendedFileImageProvider).file.uri;
              }
              return Plugins.isWebMedia(e.uri)
                  ? assets_audio_player.Audio.network(
                      Plugins.redirect(e.uri).toString(),
                      metas: assets_audio_player.Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: assets_audio_player.MetasImage(
                          path: image.toString(),
                          type: assets_audio_player.ImageType.network,
                        ),
                        extra: e.toJson(),
                      ),
                    )
                  : assets_audio_player.Audio.file(
                      e.uri.toFilePath(),
                      metas: assets_audio_player.Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: assets_audio_player.MetasImage(
                          path: image.toString(),
                          type: assets_audio_player.ImageType.file,
                        ),
                        extra: e.toJson(),
                      ),
                    );
            }).toList()),
        showNotification: true,
        loopMode: assets_audio_player.LoopMode.values[playlistLoopMode.index],
        notificationSettings: assets_audio_player.NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
      );
    }
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
        player.add(
          Media(
            Plugins.redirect(element.uri).toString(),
            extras: element.toJson(),
          ),
        );
      });
    }
    if (Platform.isAndroid || Platform.isIOS) {
      this.tracks.addAll(tracks);
      notifyListeners();
      tracks.forEach((e) {
        Uri? image;
        if (Plugins.isWebMedia(e.uri)) {
          final artwork = getAlbumArt(e, small: true);
          image = Uri.parse((artwork as ExtendedNetworkImageProvider).url);
        } else {
          final artwork = getAlbumArt(e);
          image = (artwork as ExtendedFileImageProvider).file.uri;
        }
        final audio = Plugins.isWebMedia(e.uri)
            ? assets_audio_player.Audio.network(
                Plugins.redirect(e.uri).toString(),
                metas: assets_audio_player.Metas(
                  id: e.uri.toString(),
                  title: e.trackName,
                  artist: e.trackArtistNames.take(2).join(', '),
                  album: e.albumName,
                  image: assets_audio_player.MetasImage(
                    path: image.toString(),
                    type: assets_audio_player.ImageType.network,
                  ),
                  extra: e.toJson(),
                ),
              )
            : assets_audio_player.Audio.file(
                e.uri.toFilePath(),
                metas: assets_audio_player.Metas(
                  id: e.uri.toString(),
                  title: e.trackName,
                  artist: e.trackArtistNames.take(2).join(', '),
                  album: e.albumName,
                  image: assets_audio_player.MetasImage(
                    path: image.toString(),
                    type: assets_audio_player.ImageType.file,
                  ),
                  extra: e.toJson(),
                ),
              );
        assetsAudioPlayer.playlist?.add(audio);
      });
    }
  }

  /// Load the last played playback state.
  ///
  /// Passing [open] as `false` causes file to not be opened inside [player] or [assetsAudioPlayer].
  ///
  Future<void> loadAppState({bool open = true}) async {
    isShuffling = AppState.instance.shuffle;
    playlistLoopMode = AppState.instance.playlistLoopMode;
    rate = AppState.instance.rate;
    volume = AppState.instance.volume;
    pitch = AppState.instance.pitch;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.rate = rate;
      player.volume = volume;
      player.pitch = pitch;
      player.setPlaylistMode(PlaylistMode.values[playlistLoopMode.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.setPlaySpeed(rate);
      assetsAudioPlayer.setVolume(volume / 100.0);
      assetsAudioPlayer.setPitch(pitch);
      assetsAudioPlayer.setLoopMode(
          assets_audio_player.LoopMode.values[playlistLoopMode.index]);
    }
    if (!open) return;
    tracks = AppState.instance.playlist;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player.open(
        Playlist(
          tracks
              .map((e) => Media(
                    Plugins.redirect(e.uri).toString(),
                    extras: e.toJson(),
                  ))
              .toList(),
          index: index,
        ),
        play: false,
      );
      // TODO (@alexmercerind):
      // index = AppState.instance.index;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.open(
        assets_audio_player.Playlist(
            startIndex: index,
            audios: tracks.map((e) {
              Uri? image;
              if (Plugins.isWebMedia(e.uri)) {
                final artwork = getAlbumArt(e, small: true);
                image =
                    Uri.parse((artwork as ExtendedNetworkImageProvider).url);
              } else {
                final artwork = getAlbumArt(e);
                image = (artwork as ExtendedFileImageProvider).file.uri;
              }
              return Plugins.isWebMedia(e.uri)
                  ? assets_audio_player.Audio.network(e.uri.toString(),
                      metas: assets_audio_player.Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: assets_audio_player.MetasImage(
                          path: image.toString(),
                          type: assets_audio_player.ImageType.network,
                        ),
                        extra: e.toJson(),
                      ))
                  : assets_audio_player.Audio.file(e.uri.toFilePath(),
                      metas: assets_audio_player.Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: assets_audio_player.MetasImage(
                          path: image.toString(),
                          type: assets_audio_player.ImageType.file,
                        ),
                        extra: e.toJson(),
                      ));
            }).toList()),
        showNotification: true,
        loopMode: assets_audio_player.LoopMode.values[playlistLoopMode.index],
        notificationSettings: assets_audio_player.NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
        autoStart: false,
      );
      index = AppState.instance.index;
    }
  }

  Playback() {
    // libmpv.dart specific.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.streams.playlist.listen((event) async {
        if (event.index < 0 || event.index > event.medias.length - 1) {
          return;
        }
        index = event.index;
        tracks = await compute<List, List<Track>>(
          (message) {
            return message
                .map((media) => Track.fromJson(media.extras))
                .toList();
          },
          event.medias,
        );
        notifyListeners();
        _update();
      });
      player.streams.isPlaying.listen((event) {
        isPlaying = event;
        notifyListeners();
        _update();
      });
      player.streams.isBuffering.listen((event) {
        isBuffering = event;
        notifyListeners();
        _update();
      });
      player.streams.isCompleted.listen((event) async {
        isCompleted = event;
        notifyListeners();
      });
      player.streams.position.listen((event) {
        position = event;
        notifyListeners();
        if (Platform.isWindows &&
            Configuration.instance.taskbarIndicator &&
            appWindow.isVisible) {
          WindowsTaskbar.setProgress(
            position.inMilliseconds,
            duration.inMilliseconds,
          );
        }
        if (Platform.isLinux) {
          _Harmonoid.instance.position = event;
        }
        // [PlaylistLoopMode.single] wrecks [endTimeStamp] in Discord RPC.
        // This is a workaround.
        if (event.inSeconds.compareTo(0) == 0) {
          _updateDiscordRPC();
        }
      });
      player.streams.duration.listen((event) {
        duration = event;
        notifyListeners();
      });
      try {
        // System Media Transport Controls. Windows specific.
        if (Platform.isWindows) {
          try {
            WindowsTaskbar.resetWindowTitle();
            smtc.create();
            smtc.events.listen((value) {
              switch (value) {
                case SMTCEvent.play:
                  play();
                  break;
                case SMTCEvent.pause:
                  pause();
                  break;
                case SMTCEvent.next:
                  next();
                  break;
                case SMTCEvent.previous:
                  previous();
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
        // Prevent dynamic library late initialization error on unsupported platforms.
        // TODO: Address issue within `dart_discord_rpc`.
        discord = DiscordRPC(applicationId: '881480706545573918');
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    // assets_audio_player specific.
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.current.listen((event) {
        if (event != null) {
          if (event.playlist.currentIndex < 0 ||
              event.playlist.currentIndex >= tracks.length) return;
          duration = event.audio.duration;
          tracks = event.playlist.audios
              .map((e) => Track.fromJson(e.metas.extra))
              .toList();
          if (isShuffling) {
            index =
                tracks.indexOf(Track.fromJson(event.audio.audio.metas.extra));
          } else {
            index = event.playlist.currentIndex;
          }
          notifyListeners();
          _update();
        }
      });
      assetsAudioPlayer.isPlaying.listen((event) {
        isPlaying = event;
        notifyListeners();
        _update();
      });
      assetsAudioPlayer.isBuffering.listen((event) {
        isBuffering = event;
        notifyListeners();
        _update();
      });
      assetsAudioPlayer.currentPosition.listen((event) {
        position = event;
        notifyListeners();
        if (Lyrics.instance.current.isNotEmpty &&
            Configuration.instance.notificationLyrics) {
          if (Platform.isAndroid) {
            for (final lyric in Lyrics.instance.current)
              if (lyric.time ~/ 1000 == position.inSeconds) {
                const settings = AndroidNotificationDetails(
                  'com.alexmercerind.harmonoid',
                  'Harmonoid',
                  '',
                  icon: 'drawable/splash',
                  importance: Importance.high,
                  priority: Priority.high,
                  showWhen: false,
                  onlyAlertOnce: true,
                  playSound: false,
                  enableVibration: false,
                );
                _notification.show(
                  69420,
                  tracks[index].trackName +
                      ' • ' +
                      tracks[index].trackArtistNames.join(', '),
                  lyric.words,
                  NotificationDetails(android: settings),
                );
                break;
              }
          }
        }
      });
      assetsAudioPlayer.playSpeed.listen((event) {
        rate = event;
        notifyListeners();
      });
    }
    // TODO: Restructure.
    ytm_request_authority = Configuration.instance.proxyURL;
  }

  void _update() async {
    try {
      final track = tracks[index];
      NowPlayingColorPalette.instance.update(track);
      Lyrics.instance.update([
        track.trackName,
        (track.albumArtistName.isNotEmpty &&
                track.albumArtistName != kUnknownArtist)
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
                ThumbnailToolbarAssetIcon(isPlaying
                    ? 'assets/icons/pause.ico'
                    : 'assets/icons/play.ico'),
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
            smtc.set_status(isPlaying ? SMTCStatus.playing : SMTCStatus.paused);
            smtc.set_music_data(
              album_title: track.albumName,
              album_artist: track.albumArtistName,
              artist: track.trackArtistNames.take(2).join(', '),
              title: track.trackName,
              track_number: track.trackNumber,
            );
            if (Plugins.isWebMedia(track.uri)) {
              final artwork = getAlbumArt(track, small: true);
              smtc.set_artwork((artwork as ExtendedNetworkImageProvider).url);
            } else {
              final artwork = getAlbumArt(track);
              smtc.set_artwork((artwork as ExtendedFileImageProvider).file);
            }
          } catch (exception, stacktrace) {
            debugPrint(exception.toString());
            debugPrint(stacktrace.toString());
          }
        }
        if (Platform.isLinux) {
          Uri? artworkUri;
          if (Plugins.isWebMedia(track.uri)) {
            final artwork = getAlbumArt(track, small: true);
            artworkUri =
                Uri.parse((artwork as ExtendedNetworkImageProvider).url);
          } else {
            final artwork = getAlbumArt(track);
            artworkUri = (artwork as ExtendedFileImageProvider).file.uri;
          }
          _Harmonoid.instance.isPlaying = isPlaying;
          _Harmonoid.instance.isCompleted = isCompleted;
          _Harmonoid.instance.index = index;
          _Harmonoid.instance.playlist = tracks.map((e) {
            final json = e.toJson();
            json['artworkUri'] = artworkUri.toString();
            return MPRISMedia.fromJson(json);
          }).toList();
        }
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Fetch [largeImageKey] if the current [track] was changed.
          if (track != _discordLastTrack) {
            _discordLastLargeImageKey = Plugins.isWebMedia(track.uri)
                // web music.
                ? Plugins.artwork(track.uri, small: true)
                // local music.
                : await (() async {
                    try {
                      // No OOP boilerplate for this small cute piece of code.
                      final result = await YTMClient.search(
                        [
                          track.trackName,
                          (track.albumArtistName.isNotEmpty &&
                                  track.albumArtistName != kUnknownArtist
                              ? track.albumArtistName
                              : track.trackArtistNames.take(1).join('')),
                        ].join(' '),
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
                        // No OOP boilerplate for this small cute piece of code.
                        final response = await get(
                          Uri.https(
                            'itunes.apple.com',
                            '/search',
                            {
                              'term': track.albumArtistName.isNotEmpty &&
                                      track.albumArtistName != kUnknownArtist
                                  ? track.albumArtistName
                                  : track.trackArtistNames.take(1).join(''),
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
            _discordLastTrack = track;
          }
          _updateDiscordRPC();
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
  void _updateDiscordRPC() {
    if (Configuration.instance.discordRPC) {
      try {
        final track = tracks[index];
        if (!isCompleted) {
          discord?.start(autoRegister: true);
          discord?.updatePresence(
            DiscordPresence(
              state: '${[
                null,
                kUnknownArtist
              ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(',') : track.albumArtistName}',
              details: '${track.trackName}',
              largeImageKey: _discordLastLargeImageKey,
              largeImageText:
                  Plugins.isWebMedia(track.uri) ? null : '${track.albumName}',
              smallImageKey: isPlaying ? 'play' : 'pause',
              smallImageText: isPlaying ? 'Playing' : 'Paused',
              button1Label: Plugins.isWebMedia(track.uri) ? 'Listen' : 'Find',
              button1Url: Plugins.isWebMedia(track.uri)
                  ? track.uri.toString()
                  : 'https://www.google.com/search?q=${Uri.encodeComponent([
                      track.trackName,
                      (track.albumArtistName.isNotEmpty &&
                              track.albumArtistName != kUnknownArtist
                          ? track.albumArtistName
                          : track.trackArtistNames.take(1).join('')),
                    ].join(' '))}',
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
  }

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

  final Player player = Player(video: false, osc: false, title: kTitle);
  final assets_audio_player.AssetsAudioPlayer assetsAudioPlayer =
      assets_audio_player.AssetsAudioPlayer.withId(
          Random().nextInt(1 << 32).toString());
  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();
  DiscordRPC? discord;
  String? _discordLastLargeImageKey;
  Track? _discordLastTrack;

  @override
  // ignore: must_call_super
  void dispose() {}

  double _volume = 50.0;

  get isFirstTrack => index == 0;
  get isLastTrack => index == tracks.length - 1;
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
  static double volume = 50.0;
  static double rate = 1.0;
  static double pitch = 1.0;
  static PlaylistLoopMode playlistLoopMode = PlaylistLoopMode.none;
  static bool isShuffling = false;
}

/// Implements `org.mpris.MediaPlayer2` & `org.mpris.MediaPlayer2.Player`.
class _Harmonoid extends MPRISService {
  /// [_Harmonoid] object instance.
  static final instance = _Harmonoid();

  _Harmonoid()
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
