library addsavedmusic;

import 'package:harmonoid/globals.dart' as Globals;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class AddSavedMusic extends SaveTrack {
  @override
  int trackNumber;
  @override
  String trackId;
  @override
  Map<String, dynamic> albumJson;

  AddSavedMusic(this.trackNumber, this.trackId, this.albumJson);

  Future<int> save() async {

    await createAppDirectory();
    bool isAlbumSaved = !(await albumSaved());

    if (isAlbumSaved) {
      await saveAlbumAssets();
      await saveAlbumArt();
    }

    await saveTrackAssets();
    await saveTrackFile();

    return this.statusCode;
  }
}


abstract class GenerateDirectories {

  Directory externalDirectory;
  Directory applicationDirectory;
  Directory musicDirectory;

  Future<void> createAppDirectory() async {
    this.applicationDirectory = Directory(path.join(Globals.APP_DIR, '.harmonoid'));
    this.musicDirectory = Directory(path.join(this.applicationDirectory.path, 'musicLibrary'));

    if (!(await applicationDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    }
  }
}



abstract class SaveAlbumAssets extends GenerateDirectories {
  int trackNumber;
  String trackId;
  Map<String, dynamic> albumJson;
  Directory albumDirectory;
  int statusCode = 200;

  Future<bool> albumSaved() async {
    this.albumDirectory = Directory(path.join(this.musicDirectory.path, this.albumJson['album_id']));
    
    if (this.albumDirectory.existsSync()) {
      return true;
    }
    else {
      await this.albumDirectory.create(recursive: true);
      return false;
    }
  }

  Future<void> saveAlbumAssets() async {
    File albumAssets = File(path.join(this.albumDirectory.path, 'albumAssets.json'));
    
    try {
      await albumAssets.writeAsString(convert.jsonEncode(this.albumJson));
    }
    catch(error) {
      this.statusCode = 400;
    }
  }

  Future<void> saveAlbumArt() async {
    File albumAssets = File(path.join(this.albumDirectory.path, 'albumArt.png'));
    
    try {
      var imageBinary = (await http.get(this.albumJson['album_art_640'])).bodyBytes;
      await albumAssets.writeAsBytes(imageBinary);
    }
    catch(error) {
      this.statusCode = 400;
    }
  }
}


abstract class SaveTrack extends SaveAlbumAssets {

  Future<void> saveTrackFile() async {
    File trackFile = File(path.join(this.albumDirectory.path, '${this.trackNumber}.mp3'));

    Uri trackDownloadUri = Uri.https(Globals.STRING_HOME_URL, '/trackdownload', {'track_id': this.trackId, 'album_id': this.albumJson['album_id']});
    try {
      http.Response response = await http.get(trackDownloadUri);
      int contentLength = response.contentLength;
      int statusCode = response.statusCode;

      if (statusCode == 200) {
        if (contentLength < 500000) {
          this.statusCode = 403;
        }
        else {
          var trackBinary = response.bodyBytes;
          await trackFile.writeAsBytes(trackBinary);
        }
      }
      else {
        this.statusCode = 500;
      }
    }
    catch(error) {
      this.statusCode = 400;
    }
  }

  Future<void> saveTrackAssets() async {
    File trackAssets = File(path.join(this.albumDirectory.path, '${this.trackNumber}.json'));

    try {
      if (await trackAssets.exists()) {}
      else {

        Uri uri = Uri.https(Globals.STRING_HOME_URL, '/albuminfo', {'album_id': this.albumJson['album_id']});
        Map<String, dynamic> albumTracks = convert.jsonDecode((await http.get(uri)).body);
        String trackJson = convert.jsonEncode(albumTracks['tracks'][this.trackNumber - 1]);

        await trackAssets.create(recursive: true);
        await trackAssets.writeAsString(trackJson);
      }
    }
    catch(error) {
      this.statusCode = 400;
    }
  }
}