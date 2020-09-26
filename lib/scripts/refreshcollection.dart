import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/getsavedmusic.dart';

class RefreshCollection {

  static Future<void> refreshAlbumsCollection() async {
    Globals.albums = (await GetSavedMusic.albums())['albums'];
    Globals.albumArts = await GetSavedMusic.albumArts();
    Globals.tracksList = new List<List<dynamic>>();

    for (int index = 0; index < Globals.albums.length; index++) {
      Globals.tracksList.add(
        (await GetSavedMusic.tracks(Globals.albums[index]['album_id']))['tracks']
      );
    }
  }

  static Future<void> refreshArtistsCollection() async {
    Globals.artists = (await GetSavedMusic.artists())['artists'];
    
    for (int index = 0; index < Globals.artists.length; index++) {
      Globals.artistTracksList.add([]);
      for (int albumIndex = 0; albumIndex < Globals.artists[index]['albums'].length; albumIndex++) {
        Globals.artistTracksList[index].add(
          (await GetSavedMusic.tracks(Globals.artists[index]['albums'][albumIndex]['album_id']))['tracks']
        );
      }
    }
  }
}