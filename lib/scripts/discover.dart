import 'dart:io';
import 'package:harmonoid/scripts/download.dart';
import 'package:harmonoid/scripts/vars.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';


Discover discover;


class Discover {
  String homeAddress;

  Discover(this.homeAddress);

  static Future<void> init({String homeAddress}) async {
    discover = new Discover(homeAddress);
  }

  Future<List<dynamic>> search(String keyword, MediaType mode) async {
    List<dynamic> result = <dynamic>[];
    String modeString = mode.type.toLowerCase();
    Uri uri = Uri.https(
      this.homeAddress,
      '/search', {
        'keyword': keyword,
        'mode': modeString,
      },
    );
    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        (convert.jsonDecode(response.body)['result'] as List).forEach((objectMap) {
          if (mode is Album) result.add(Album.fromMap(objectMap));
          if (mode is Track) result.add(Track.fromMap(objectMap));
          if (mode is Artist) result.add(Artist.fromMap(objectMap));
        });
      }
      List<dynamic> searchRecents = configuration.discoverSearchRecent;
      String searchKeyword = '';
      for (String element in keyword.split(' ')) {
        if (element.length > 1)
          searchKeyword = searchKeyword + element[0].toUpperCase() + element.substring(1, element.length) + ' ';
      }
      searchRecents.insert(
        0,
        [searchKeyword, mode.type],
      );
      if (searchRecents.length > 5) searchRecents.removeLast();
      await configuration.save(discoverSearchRecent: searchRecents);
      return result;
    }
    catch(exception) {
      throw 'Please check your internet connection';
    }
  }

  Future<List<Track>> albumInfo(Album album) async {
    List<Track> result = <Track>[];
    Uri uri = Uri.https(
      this.homeAddress,
      '/albumInfo', {
        'albumId': album.albumId,
      },
    );
    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        (convert.jsonDecode(response.body)['tracks'] as List).forEach((objectMap) {
          objectMap['albumName'] = album.albumName;
          objectMap['albumId'] = album.albumId;
          result.add(Track.fromMap(objectMap));
        });
      }
      return result;
    }
    catch(exception) {
      throw 'Please check your internet connection';
    }
  }

  Future<void> trackDownload(Track track, {void Function() onCompleted, void Function(double progress) onProgress}) async {
    File trackDestination = File(
      path.join(
        MUSIC_DIRECTORY,
        '${track.trackArtistNames.join(', ')}_${track.trackName}'.replaceAll(new RegExp(r'[^\s\w]'),'') + '.OGG',
    ));
    download.addTask(
      new DownloadTask(
        fileUri: Uri.https(
          this.homeAddress,
          '/trackDownload', {
            'trackId': track.trackId,
            'albumId': track.albumId,
          }
        ),
        saveLocation: trackDestination,
        onProgress: onProgress,
        onCompleted: () {
          try {
            collection.add(
              trackFile: trackDestination
            );
            onCompleted?.call();
          } catch(exception) {}
        },
        extras: track,
      ),
    );
  }
}
