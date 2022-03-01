/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart' hide Intent;
import 'package:libmpv/libmpv.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/app_state.dart';
import 'package:harmonoid/models/media.dart' hide Media;
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
  /// Late initialized [Lyrics] object instance.
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

  /// Plays cross-fade effect between the current track and the next track.
  Future<void> playCrossFadeEffect({effectRate = 1}) async {
    var originalVolume = volume;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      while (player.state.volume - effectRate > 0) {
        player.volume = player.state.volume - effectRate;
        await Future.delayed(Duration(milliseconds: 1));
      }
      player.volume = originalVolume;
    }
  }

  void next() {
    player.play().then((value) {
      playCrossFadeEffect().then((_) {
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          player.next();
        }
        if (Platform.isAndroid || Platform.isIOS) {
          assetsAudioPlayer.next();
        }
      });
    });
  }

  void previous() {
    player.play().then((value) {
      playCrossFadeEffect().then((_) {
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          player.back();
        }
        if (Platform.isAndroid || Platform.isIOS) {
          assetsAudioPlayer.previous();
        }
      });
    });
  }

  void jump(int value) {
    playCrossFadeEffect(effectRate: 3).then((_) {
      if (Platform.isWindows || Platform.isLinux) {
        player.jump(value);
      }
      if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
        assetsAudioPlayer.playlistPlayAtIndex(value);
      }
    });
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
      mpris?.rate = value;
    }
    saveAppState();
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
      mpris?.volume = value;
    }
    saveAppState();
    notifyListeners();
  }

  void setPlaylistLoopMode(PlaylistLoopMode value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.setPlaylistMode(PlaylistMode.values[value.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {}
    playlistLoopMode = value;
    saveAppState();
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
    saveAppState();
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

  /// Convert [Track] list to [Media] list.
  List<Media> _tracksToMediaList(List<Track> tracks) => tracks
      .map((e) => Media(
            Plugins.redirect(e.uri).toString(),
            extras: e.toJson(),
          ))
      .toList();

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
    if (Platform.isAndroid || Platform.isIOS) {}
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
    if (Platform.isAndroid || Platform.isIOS) {}
  }

  /// Load the last played playback state.
  Future<void> loadAppState() async {
    final state = AppState.instance;
    tracks = state.playlist;
    index = state.playlistIndex;
    rate = state.rate;
    isShuffling = state.shuffle;
    playlistLoopMode = state.playlistLoopMode;
    volume = player.volume = state.volume;

    /// for some reason, await for player.open() is not enough
    /// so we have to use a timer here before jump() to index.
    await Future.delayed(Duration(milliseconds: 100), () async {
      await player.open(_tracksToMediaList(tracks), play: false);
    });
    await player.jump(index);

    /// for some reason, player start to play after jump() to index.
    await player.pause();
  }

  /// Save the current playback state.
  void saveAppState() => AppState.instance
      .save(tracks, index, rate, isShuffling, playlistLoopMode, volume);

  Playback() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      loadAppState().then((value) {
        player.streams.index.listen((event) {
          index = event.clamp(0, tracks.length);
          if (AppState.instance.playlistIndex != index) {
            saveAppState();
          }
          notifyListeners();
          update();
        });
        player.streams.playlist.listen((event) {
          tracks.clear();
          tracks = event.map((media) => Track.fromJson(media.extras)).toList();
          saveAppState();
          notifyListeners();
          update();
        });
      });

      player.streams.isPlaying.listen((event) {
        isPlaying = event;
        notifyListeners();
        update();
      });
      player.streams.isBuffering.listen((event) {
        isBuffering = event;
        notifyListeners();
        update();
      });
      player.streams.isCompleted.listen((event) async {
        isCompleted = event;
        notifyListeners();
      });
      player.streams.position.listen((event) {
        position = event;
        notifyListeners();
        if (Platform.isWindows &&
            Configuration.instance.showTrackProgressOnTaskbar) {
          WindowsTaskbar.setProgress(
            position.inMilliseconds,
            duration.inMilliseconds,
          );
        }
        if (Platform.isLinux) {
          mpris?.position = event;
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
        if (Platform.isLinux) {
          _Harmonoid();
        }
      } catch (_) {}
    }
  }

  void update() {
    try {
      final track = tracks[index];
      try {
        if (Platform.isWindows) {
          smtc.set_status(isPlaying ? SMTCStatus.playing : SMTCStatus.paused);
          smtc.set_music_data(
            album_title: track.albumName,
            album_artist: track.albumArtistName,
            artist: track.trackArtistNames.take(2).join(', '),
            title: track.trackName,
            track_number: track.trackNumber,
          );
          final artwork = getAlbumArt(track);
          if (artwork is FileImage) {
            smtc.set_artwork(artwork.file);
          } else if (artwork is NetworkImage) {
            smtc.set_artwork(artwork.url);
          }
          WindowsTaskbar.setProgressMode(isBuffering
              ? TaskbarProgressMode.indeterminate
              : TaskbarProgressMode.normal);
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
        if (Platform.isLinux) {
          Uri? artworkUri;
          final artwork = getAlbumArt(track);
          if (artwork is FileImage) {
            artworkUri = artwork.file.uri;
          } else if (artwork is NetworkImage) {
            artworkUri = Uri.parse(artwork.url);
          }
          mpris?.isPlaying = isPlaying;
          mpris?.isCompleted = isCompleted;
          mpris?.index = index;
          mpris?.playlist = tracks.map((e) {
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
      } catch (_, __) {
        print(_);
        print(__);
      }
      Lyrics.instance.update(
          track.trackName + ' ' + track.trackArtistNames.take(2).join(', '));
    } catch (_) {}
  }

  static final Player player = Player(video: false, osc: false, title: kTitle);
  static final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  static MPRISService? mpris;
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
class DefaultPlaybackValues {
  static int index = 0;
  static List<Track> tracks = [];
  static double volume = 50.0;
  static double rate = 1.0;
  static PlaylistLoopMode playlistLoopMode = PlaylistLoopMode.none;
  static bool isShuffling = false;
}

/// Implements `org.mpris.MediaPlayer2` & `org.mpris.MediaPlayer2.Player`.
class _Harmonoid extends MPRISService {
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
