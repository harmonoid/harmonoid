import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/lyrics.dart';


final AudioPlayer.AssetsAudioPlayer audioPlayer = new AudioPlayer.AssetsAudioPlayer.withId('harmonoid')
..current.listen((AudioPlayer.Playing? current) async {
  if (current != null) {
    await lyrics.fromName(current.audio.audio.metas.title! + ' - ' + current.audio.audio.metas.artist!);
  }
})
..currentPosition.listen((Duration? position) async {
  if (lyrics.current.isNotEmpty && position != null && configuration.notificationLyrics!) {
    for (Lyric lyric in lyrics.current) if (lyric.time ~/ 1000 == position.inSeconds) {
      const AndroidNotificationDetails settings = AndroidNotificationDetails(
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
});


abstract class Playback {

  static Future<void> play({required int index, required List<Track> tracks}) async {
    List<Track> _tracks = tracks;
    if (_tracks.length > 20) _tracks = tracks.sublist(index, index + 20);
    List<AudioPlayer.Audio> audios = <AudioPlayer.Audio>[];
    _tracks.forEach((Track track) {
      audios.add(
        new AudioPlayer.Audio.file(
          track.filePath!,
          metas: new AudioPlayer.Metas(
            id: track.trackId,
            image: new AudioPlayer.MetasImage.file(
              track.albumArt.path,
            ),
            title: track.trackName!,
            album: track.albumName!,
            artist: track.trackArtistNames!.join(', '),
            extra: track.toMap(),
          )
        ),
      );
    });
    audioPlayer.open(
      new AudioPlayer.Playlist(
        audios: audios,
        startIndex: index,
      ),
      showNotification: true,
      notificationSettings: new AudioPlayer.NotificationSettings(
        playPauseEnabled: true,
        nextEnabled: true,
        prevEnabled: true,
        seekBarEnabled: true,
        stopEnabled: false,   
      ),
    );
  }
}
