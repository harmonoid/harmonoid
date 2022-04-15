/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart' hide Intent;
import 'package:harmonoid/state/now_playing_scroll_hider.dart';
import 'package:libmpv/libmpv.dart' hide Playlist;
import 'package:mpris_service/mpris_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
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
import 'package:harmonoid/state/now_playing_launcher.dart';
import 'package:harmonoid/constants/language.dart';

/// Playback
/// --------
///
/// Class to handle & control the [Media] playback in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Implements [ChangeNotifier] to trigger UI updates.
///
/// Automatically handles:
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
      if (Platform.isAndroid || Platform.isIOS) {
        assetsAudioPlayer.next();
      }
    });
  }

  void previous() {
    player.play().then((value) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        player.back();
      }
      if (Platform.isAndroid || Platform.isIOS) {
        assetsAudioPlayer.previous();
      }
    });
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
    _saveAppState();
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
    _saveAppState();
    notifyListeners();
  }

  void setPlaylistLoopMode(PlaylistLoopMode value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.setPlaylistMode(PlaylistMode.values[value.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.setLoopMode(LoopMode.values[value.index]);
    }
    playlistLoopMode = value;
    _saveAppState();
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
    _saveAppState();
    notifyListeners();
  }

  void seek(Duration position) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.seek(position);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.seek(position);
    }
  }

  void open(List<Track> tracks, {int index = 0}) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.open(_tracksToMediaList(tracks));
      player.jump(index);
      player.play();
      isShuffling = false;
      notifyListeners();
      if (Configuration
          .instance.automaticallyShowNowPlayingScreenAfterPlaying) {
        Future.delayed(const Duration(milliseconds: 500), () {
          NowPlayingLauncher.instance.maximized = true;
        });
      }
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.open(
        Playlist(
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
                  ? Audio.network(
                      e.uri.toString(),
                      metas: Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: MetasImage(
                          path: image.toString(),
                          type: ImageType.network,
                        ),
                        extra: e.toJson(),
                      ),
                    )
                  : Audio.file(
                      e.uri.toFilePath(),
                      metas: Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: MetasImage(
                          path: image.toString(),
                          type: ImageType.file,
                        ),
                        extra: e.toJson(),
                      ),
                    );
            }).toList()),
        showNotification: true,
        loopMode: LoopMode.values[playlistLoopMode.index],
        notificationSettings: NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        NowPlayingScrollHider.instance.show();
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
      // TODO:
    }
  }

  /// Load the last played playback state.
  Future<void> loadAppState() async {
    final state = AppState.instance;
    tracks = state.playlist;
    index = state.playlistIndex;
    isShuffling = state.shuffle;
    playlistLoopMode = state.playlistLoopMode;
    rate = player.rate = state.rate;
    volume = player.volume = state.volume;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await player.open(_tracksToMediaList(tracks), play: false);
      // A bug that results in [isPlaying] becoming `true` after attempting
      // to change the volume. Calling [pause] after a delay to ensure that
      // play button isn't in incorrect state at the startup of the application.
      Future.delayed(const Duration(milliseconds: 500), pause);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.open(
        Playlist(
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
                  ? Audio.network(
                      e.uri.toString(),
                      metas: Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: MetasImage(
                          path: image.toString(),
                          type: ImageType.network,
                        ),
                        extra: e.toJson(),
                      ),
                    )
                  : Audio.file(
                      e.uri.toFilePath(),
                      metas: Metas(
                        id: e.uri.toString(),
                        title: e.trackName,
                        artist: e.trackArtistNames.take(2).join(', '),
                        album: e.albumName,
                        image: MetasImage(
                          path: image.toString(),
                          type: ImageType.file,
                        ),
                        extra: e.toJson(),
                      ),
                    );
            }).toList()),
        showNotification: true,
        loopMode: LoopMode.values[playlistLoopMode.index],
        notificationSettings: NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
        autoStart: false,
      );
    }
  }

  Playback() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      loadAppState().then((value) {
        player.streams.index.listen((event) {
          index =
              event.clamp(0, (tracks.length - 1).clamp(0, 9223372036854775807));
          if (AppState.instance.playlistIndex != index) {
            _saveAppState();
          }
          notifyListeners();
          _update();
        });
        player.streams.playlist.listen((event) {
          tracks.clear();
          tracks = event.map((media) => Track.fromJson(media.extras)).toList();
          _saveAppState();
          notifyListeners();
          _update();
        });
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
            Configuration.instance.showTrackProgressOnTaskbar &&
            appWindow.isVisible) {
          WindowsTaskbar.setProgress(
            position.inMilliseconds,
            duration.inMilliseconds,
          );
        }
        if (Platform.isLinux) {
          _Harmonoid.instance.position = event;
        }
      });
      player.streams.duration.listen((event) {
        duration = event;
        notifyListeners();
      });
      try {
        if (Platform.isWindows) {
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
        }
        if (Platform.isLinux) {}
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    }
    if (Platform.isAndroid || Platform.isIOS) {
      loadAppState().then((value) {
        assetsAudioPlayer.current.listen((event) {
          if (event != null) {
            index = event.index
                .clamp(0, (tracks.length - 1).clamp(0, 9223372036854775807));
            if (AppState.instance.playlistIndex != index) {
              _saveAppState();
            }
            duration = event.audio.duration;
            tracks = event.playlist.audios
                .map((e) => Track.fromJson(e.metas.extra))
                .toList();
            notifyListeners();
            _update();
          }
        });
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
      });
      assetsAudioPlayer.playSpeed.listen((event) {
        rate = event;
        notifyListeners();
      });
    }
  }

  void _update() {
    try {
      final track = tracks[index];
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
          if (appWindow.isVisible)
            WindowsTaskbar.setProgressMode(isBuffering
                ? TaskbarProgressMode.indeterminate
                : TaskbarProgressMode.normal);
          if (appWindow.isVisible)
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
          if (!isCompleted) {
            discord.start(autoRegister: true);
            discord.updatePresence(
              DiscordPresence(
                state: '${track.albumName}',
                details: '${track.trackName} • ${track.albumArtistName}',
                largeImageKey: 'icon',
                largeImageText: Language.instance.LISTENING_TO_MUSIC,
                smallImageText: kTitle,
              ),
            );
          }
          if (isCompleted) {
            discord.clearPresence();
          }
        }
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
      Lyrics.instance.update(
          track.trackName + ' ' + track.trackArtistNames.take(2).join(', '));
    } catch (_) {}
  }

  /// Save the current playback state.
  void _saveAppState() => AppState.instance
      .save(tracks, index, rate, isShuffling, playlistLoopMode, volume);

  /// Convert [Track] list to [Media] list.
  List<Media> _tracksToMediaList(List<Track> tracks) => tracks
      .map((e) => Media(
            Plugins.redirect(e.uri).toString(),
            extras: e.toJson(),
          ))
      .toList();

  static final Player player = Player(video: false, osc: false, title: kTitle);
  static final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  static final discord = DiscordRPC(applicationId: '881480706545573918');

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
