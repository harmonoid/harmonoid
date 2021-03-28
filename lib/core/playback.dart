import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;

import 'package:harmonoid/core/collection.dart';


final AudioPlayer.AssetsAudioPlayer audioPlayer = new AudioPlayer.AssetsAudioPlayer.withId('harmonoid');


class Playback {
  static Future<void> play({required int index, required List<Track> tracks}) async {
    List<AudioPlayer.Audio> audios = <AudioPlayer.Audio>[];
    tracks.forEach((Track track) {
      audios.add(
        new AudioPlayer.Audio.file(
          track.filePath!,
          metas: new AudioPlayer.Metas(
            id: track.trackId!,
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
