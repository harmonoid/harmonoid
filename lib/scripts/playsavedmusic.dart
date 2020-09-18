library playsavedmusic;

import 'dart:io';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';
import 'package:harmonoid/globals.dart' as Globals;
import 'package:path/path.dart' as path;


class PlaySavedMusic {
  static Future<void> playTrack(String albumId, int trackNumber) async {

    Directory applicationDirectory = Directory(path.join(Globals.APP_DIR, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    
    AudioPlayer audioPlayer = new AudioPlayer();

    await audioPlayer.load(path.join(musicDirectory.path, albumId, trackNumber.toString() + '.mp3'));
    audioPlayer.play();
  }
}