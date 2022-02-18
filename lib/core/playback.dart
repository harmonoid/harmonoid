/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart' hide Intent;
import 'package:harmonoid/core/intent.dart';
import 'package:libmpv/libmpv.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart' hide Media;
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

  int index = 0;
  List<Track> tracks = [];
  double volume = 50.0;
  double rate = 1.0;
  PlaylistLoopMode playlistLoopMode = PlaylistLoopMode.none;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isMuted = false;
  bool isPlaying = false;
  bool isBuffering = false;
  bool isCompleted = false;
  bool isShuffling = false;

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
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.next();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.next();
    }
  }

  void previous() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.back();
    }
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
      mpris?.rate = value;
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
      mpris?.volume = value;
    }
    notifyListeners();
  }

  void setPlaylistLoopMode(PlaylistLoopMode value) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.setPlaylistMode(PlaylistMode.values[value.index]);
    }
    if (Platform.isAndroid || Platform.isIOS) {}
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
      player.seek(position);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.seek(position);
    }
  }

  void open(List<Track> tracks, {int index = 0}) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.open(
        tracks
            .map(
              (e) => Media(
                Plugins.redirect(e.uri).toString(),
                extras: e.toJson(),
              ),
            )
            .toList(),
      );
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

  Playback() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      player.streams.index.listen((event) {
        index = event.clamp(0, tracks.length);
        notifyListeners();
        update();
      });
      player.streams.playlist.listen((event) {
        tracks = event.map((media) => Track.fromJson(media.extras)).toList();
        notifyListeners();
        update();
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
      player.volume = volume;
      // A bug that results in [isPlaying] becoming `true` after attempting to change the volume.
      // Calling [pause] after a delay to ensure that play button isn't in incorrect state at the
      // startup of the application.
      Future.delayed(const Duration(milliseconds: 500), () {
        pause();
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
          mpris = MPRISService(
            'harmonoid',
            identity: 'Harmonoid',
            desktopEntry: '/usr/share/applications/harmonoid.desktop',
            setLoopStatus: (value) {
              switch (value) {
                case 'None':
                  {
                    setPlaylistLoopMode(PlaylistLoopMode.none);
                    break;
                  }
                case 'Track':
                  {
                    setPlaylistLoopMode(PlaylistLoopMode.single);
                    break;
                  }
                case 'Playlist':
                  {
                    setPlaylistLoopMode(PlaylistLoopMode.loop);
                    break;
                  }
              }
            },
            setRate: (value) {
              setRate(value);
            },
            setShuffle: (value) {
              if (this.isShuffling != value) {
                toggleShuffle();
              }
            },
            setVolume: (value) {
              setVolume(value);
            },
            doNext: next,
            doPrevious: previous,
            doPause: pause,
            doPlayPause: playOrPause,
            doPlay: play,
            doSeek: (value) {
              seek(Duration(microseconds: value));
            },
            doSetPosition: (objectPath, timeMicroseconds) {
              final index = mpris?.playlist
                      .map(
                        (e) => '/' + e.uri.toString().hashCode.toString(),
                      )
                      .toList()
                      .indexOf(objectPath) ??
                  -1;
              if (index >= 0 && index != this.index) {
                jump(index);
              }
              seek(Duration(microseconds: timeMicroseconds));
            },
            doOpenUri: (uri) {
              Intent.instance.playUri(uri);
            },
          );
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
          final artwork = Collection.instance.getAlbumArt(track);
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
          final artwork = Collection.instance.getAlbumArt(track);
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
                startTimeStamp: DateTime.now().millisecondsSinceEpoch,
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

  final Player player = Player(video: false, osc: false, title: kTitle);
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  MPRISService? mpris;
  final discord = DiscordRPC(applicationId: '881480706545573918');

  double _volume = 50.0;
}

enum PlaylistLoopMode {
  none,
  single,
  loop,
}
