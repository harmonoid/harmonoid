/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:libmpv/libmpv.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:system_media_transport_controls/system_media_transport_controls.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/models/media.dart' hide Media;
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

/// Playback
/// --------
///
/// Class to handle & control the [Media] playback in [Harmonoid](https://github.com/harmonoid/harmonoid).
/// Implements [ChangeNotifier] to trigger UI updates.
///
/// Automatically handles:
/// * `ITaskbarList3` & `SystemMediaTransportControls` controls on Windows.
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
  PlaylistMode playlistMode = PlaylistMode.none;
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
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      player.pause();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      assetsAudioPlayer.pause();
    }
    isPlaying = false;
    notifyListeners();
  }

  void playOrPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
    isPlaying = !isPlaying;
    notifyListeners();
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
    notifyListeners();
  }

  void setPlaylistMode(PlaylistMode value) {
    playlistMode = value;
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
        if (index == tracks.length - 1) {
          pause();
        }
        notifyListeners();
      });
      player.streams.position.listen((event) {
        position = event;
        notifyListeners();
        if (Platform.isWindows) {
          WindowsTaskbar.setProgress(
            position.inMilliseconds,
            duration.inMilliseconds,
          );
        }
      });
      player.streams.duration.listen((event) {
        duration = event;
        notifyListeners();
      });
      player.volume = volume;
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
      } catch (_) {}
      Lyrics.instance.update(
          track.trackName + ' ' + track.trackArtistNames.take(2).join(', '));
    } catch (_) {}
  }

  final Player player = Player(video: false, osc: false, title: kTitle);
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  final discord = DiscordRPC(
    applicationId: '881480706545573918',
  );

  double _volume = 50.0;
}

enum PlaylistMode {
  none,
  single,
  loop,
}
