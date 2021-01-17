import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';


Discover discover;


class Discover {
  String homeAddress;

  Discover(this.homeAddress);

  static Future<void> init({String homeAddress}) async {
    discover = new Discover(homeAddress);
  }

  Future<List<dynamic>> search(String keyword, dynamic mode) async {
    List<dynamic> result = <dynamic>[];
    String modeParam;
    if (mode is Album) modeParam = 'album';
    if (mode is Track) modeParam = 'track';
    if (mode is Artist) modeParam = 'artist';
    Uri uri = Uri.https(
      this.homeAddress,
      '/search', {
        'keyword': keyword,
        'mode': modeParam,
      },
    );
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      (convert.jsonDecode(response.body)[modeParam + 's'] as List).forEach((objectMap) {
        if (mode is Album) result.add(Album.fromMap(objectMap));
        if (mode is Track) result.add(Track.fromMap(objectMap));
        if (mode is Artist) result.add(Artist.fromMap(objectMap));
      });
    }
    List<dynamic> searchRecents = await configuration.getConfiguration(Configurations.discoverSearchRecents);
    if (searchRecents.length > 5) searchRecents.removeLast();
    searchRecents.insert(0, [keyword, modeParam]);
    print(searchRecents);
    await configuration.setConfiguration(Configurations.discoverSearchRecents, searchRecents);
    return result;
  }
}