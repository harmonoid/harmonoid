import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart'
    as AssetsAudioPlayer;
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:harmonoid/core/discordrpc.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:libwinmedia/libwinmedia.dart' as LIBWINMEDIA;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

/// Never listen to event Streams of any audio playback backend but use [nowPlaying] notifier.
/// This wil improve `Platform.isX` calls all around & keep code stream subscription cleaner.
/// It will also make things look more cross-platform on the surface & in the UI code.
///
/// For handling different platform specific calls, add methods inside the [Playback]
/// class below & then map within the UI code.
///

final LIBWINMEDIA.Player player = LIBWINMEDIA.Player(id: 0)
  ..streams.index.listen((index) {
    nowPlaying.index = index;
    onTrackChange();
  })
  ..streams.medias.listen((medias) {
    nowPlaying.tracks = medias
        .map(
          (media) => Track.fromMap(media.extras)!,
        )
        .toList();
  })
  ..streams.isPlaying.listen((isPlaying) {
    nowPlaying.isPlaying = isPlaying;
  })
  ..streams.isBuffering.listen((isBuffering) {
    nowPlaying.isBuffering = isBuffering;
  })
  ..streams.isCompleted.listen((isCompleted) async {
    nowPlaying.isCompleted = isCompleted;
    if (!isCompleted) {
      onTrackChange();
    }
    if (isCompleted) {
      discordRPC.clearPresence();
    }
  })
  ..streams.position.listen((position) {
    nowPlaying.position = position;
  })
  ..streams.duration.listen((duration) {
    nowPlaying.duration = duration;
  })
  ..volume = 1.0;

final AssetsAudioPlayer.AssetsAudioPlayer assetsAudioPlayer =
    AssetsAudioPlayer.AssetsAudioPlayer.withId('harmonoid')
      ..current.listen((AssetsAudioPlayer.Playing? current) async {
        if (current != null) {
          nowPlayingBar.height = 72.0;
          nowPlaying.tracks = current.playlist.audios
              .map(
                (audio) => Track.fromMap(audio.metas.extra)!,
              )
              .toList();
          nowPlaying.index = current.index;
          nowPlaying.duration = current.audio.duration;
          try {
            await lyrics.fromName(current.audio.audio.metas.title! +
                ' ' +
                current.audio.audio.metas.artist!);
            const AndroidNotificationDetails settings =
                AndroidNotificationDetails(
              'com.alexmercerind.harmonoid',
              'Harmonoid',
              '',
              icon: 'mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.max,
              showWhen: false,
              onlyAlertOnce: true,
              playSound: false,
              enableVibration: false,
              showProgress: true,
              indeterminate: true,
            );
            await notification.show(
              69420,
              lyrics.query,
              language!.STRING_LYRICS_RETRIEVING,
              NotificationDetails(android: settings),
            );
          } catch (exception) {
            Future.delayed(
              Duration(seconds: 2),
              () => notification.cancel(
                69420,
              ),
            );
          }
        }
      })
      ..currentPosition.listen((Duration? position) async {
        if (lyrics.current.isNotEmpty &&
            position != null &&
            configuration.notificationLyrics!) {
          nowPlaying.position = position;
          for (Lyric lyric in lyrics.current)
            if (lyric.time ~/ 1000 == position.inSeconds) {
              const AndroidNotificationDetails settings =
                  AndroidNotificationDetails(
                'com.alexmercerind.harmonoid',
                'Harmonoid',
                '',
                icon: 'mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: false,
                onlyAlertOnce: true,
                playSound: false,
                enableVibration: false,
              );
              await notification.show(
                100000,
                lyrics.query,
                lyric.words,
                NotificationDetails(android: settings),
              );
              break;
            }
        }
      })
      ..isPlaying.listen((isPlaying) {
        nowPlaying.isPlaying = isPlaying;
      })
      ..isBuffering.listen((isBuffering) {
        nowPlaying.isBuffering = isBuffering;
      });

abstract class Playback {
  static Future<void> add(List<Track> tracks) async {
    if (Platform.isWindows || Platform.isLinux) {
      tracks.forEach((track) {
        player.add(
          LIBWINMEDIA.Media(
            uri: track.filePath!,
            extras: track.toMap(),
          ),
        );
      });
    }
  }

  static Future<void> setRate(double rate) async {
    if (Platform.isWindows || Platform.isLinux) {
      player.rate = rate;
    }
  }

  static Future<void> setVolume(double volume) async {
    if (Platform.isWindows || Platform.isLinux) {
      player.volume = volume;
    }
  }

  static Future<void> back() async {
    if (Platform.isWindows || Platform.isLinux) {
      player.back();
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.previous();
    }
  }

  static Future<void> next() async {
    if (Platform.isWindows || Platform.isLinux) {
      player.next();
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.next();
    }
  }

  static Future<void> seek(Duration position) async {
    if (Platform.isWindows || Platform.isLinux) {
      player.seek(position);
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.seek(position);
    }
  }

  static Future<void> playOrPause() async {
    if (Platform.isWindows || Platform.isLinux) {
      if (player.state.isPlaying)
        player.pause();
      else
        player.play();
    }
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.playOrPause();
    }
  }

  static Future<void> play(
      {required int index, required List<Track> tracks}) async {
    List<Track> _tracks = [...tracks];
    // libwinmedia.dart
    if (Platform.isWindows || Platform.isLinux) {
      player.open(
        _tracks
            .map(
              (track) => LIBWINMEDIA.Media(
                uri: track.filePath!,
                extras: track.toMap(),
              ),
            )
            .toList(),
      );
      player.jump(index);
      player.play();
    }
    // assets_audio_player
    if (Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
      assetsAudioPlayer.open(
        AssetsAudioPlayer.Playlist(
          audios: _tracks
              .map(
                (track) => track.filePath!.startsWith('http')
                    ? AssetsAudioPlayer.Audio.network(
                        track.filePath!,
                        metas: AssetsAudioPlayer.Metas(
                          id: track.trackId,
                          image: AssetsAudioPlayer.MetasImage.network(
                            track.networkAlbumArt!,
                          ),
                          title: track.trackName!,
                          album: track.albumName!,
                          artist: track.trackArtistNames!.join(', '),
                          extra: track.toMap(),
                        ),
                      )
                    : AssetsAudioPlayer.Audio.file(
                        track.filePath!,
                        metas: AssetsAudioPlayer.Metas(
                          id: track.trackId,
                          image: AssetsAudioPlayer.MetasImage.file(
                            track.albumArt.path,
                          ),
                          title: track.trackName!,
                          album: track.albumName!,
                          artist: track.trackArtistNames!.join(', '),
                          extra: track.toMap(),
                        ),
                      ),
              )
              .toList()
              .cast(),
          startIndex: index,
        ),
        showNotification: true,
        loopMode: AssetsAudioPlayer.LoopMode.playlist,
        notificationSettings: AssetsAudioPlayer.NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
      );
    }
  }
}

/// Invoked when a new Track starts playing i.e. either index is changed or isPlaying changed.
void onTrackChange() {
  try {
    List<LIBWINMEDIA.Media> medias = player.state.medias;
    int index = player.state.index;
    Track track = Track.fromMap(medias[index].extras)!;
    // TODO (alexmercerind): SMTC only working on Windows.
    if (Platform.isWindows) {
      player.nativeControls.update(
        albumArtist: track.albumArtistName,
        album: track.albumName,
        title: track.trackName,
        artist: track.trackArtistNames?.join(', '),
        thumbnail: Uri.parse(
          track.networkAlbumArt ?? track.albumArt.path,
        ),
      );
    }
    discordRPC.start(autoRegister: true);
    discordRPC.updatePresence(
      DiscordPresence(
        state: '${track.albumName}',
        details: '${track.trackName} - ${track.albumArtistName}',
        startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        largeImageKey: '52f61nfzmwl51',
        largeImageText: 'Listening to music. 💜',
        smallImageKey: '32f61n5ghl51',
        smallImageText: 'Harmonoid',
      ),
    );
  } catch (exception) {}
}
