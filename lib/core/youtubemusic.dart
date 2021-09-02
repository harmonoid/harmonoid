import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:harmonoid/core/collection.dart';

const String REQUEST_AUTHORITY = 'music.youtube.com';

const String REQUEST_KEY = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';

const Map<String, String> REQUEST_HEADERS = {
  'accept': '*/*',
  'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8',
  'content-type': 'application/json',
  'dpr': '2',
  'sec-ch-ua-arch': '',
  'sec-fetch-dest': 'empty',
  'sec-fetch-mode': 'same-origin',
  'sec-fetch-site': 'same-origin',
  'x-origin': 'https://music.youtube.com',
  'x-youtube-client-name': '67',
  'x-youtube-client-version': '1.20210823.00.00',
};

const Map<String, dynamic> REQUEST_PAYLOAD = {
  'context': {
    'client': {
      'clientName': 'WEB_REMIX',
      'clientVersion': '0.1',
      'newVisitorCookie': true,
    },
    'user': {
      'lockedSafetyMode': false,
    }
  }
};

abstract class Client {
  static YoutubeExplode external = YoutubeExplode();

  static Future<http.Response> request(
      String path, Map<String, String> properties) async {
    var response = await http.post(
      Uri.https(
        REQUEST_AUTHORITY,
        '/youtubei/v1/$path',
        {
          'key': REQUEST_KEY,
        },
      ),
      headers: REQUEST_HEADERS,
      body: convert.jsonEncode({
        ...REQUEST_PAYLOAD,
        ...properties,
      }),
    );
    return response;
  }
}

abstract class YTM {
  static Future<List<Track>> search(String query) async {
    var result = [];
    var response = await Client.request(
      'search',
      {
        'query': query,
        'params': 'EgWKAQIIAWoMEAMQBBAOEAoQBRAJ',
      },
    );
    var body = convert.jsonDecode(response.body)['contents'];
    if (body.containsKey('tabbedSearchResultsRenderer')) {
      body = body['tabbedSearchResultsRenderer']['tabs'].first['tabRenderer']
          ['content'];
    } else {
      body = body['contents'];
    }
    try {
      body = body['sectionListRenderer']['contents'].first['musicShelfRenderer']
          ['contents'];
    } catch (exception) {
      return [];
    }
    for (var object in body) {
      object = object['musicResponsiveListItemRenderer'];
      try {
        var metas = object['flexColumns'][1]
                ['musicResponsiveListItemFlexColumnRenderer']['text']['runs']
            .map((meta) => meta['text'])
            .toList()
            .join(' ');
        var duration = metas.split('\u2022')[2].trim();
        duration = int.parse(duration.split(':').first) * 60 +
            int.parse(duration.split(':')[1]);
        var track = Track(
          trackId: object['flexColumns']
              .first['musicResponsiveListItemFlexColumnRenderer']['text']
                  ['runs']
              .first['navigationEndpoint']['watchEndpoint']['videoId'],
          trackName: object['flexColumns']
              .first['musicResponsiveListItemFlexColumnRenderer']['text']
                  ['runs']
              .first['text'],
          trackArtistNames: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>(),
          trackDuration: duration * 1000,
          networkAlbumArt: object['thumbnail']['musicThumbnailRenderer']
                  ['thumbnail']['thumbnails']
              .last['url'],
          albumId: object['menu']['menuRenderer']['items']
                      [object['menu']['menuRenderer']['items'].length - 3]
                  ['menuNavigationItemRenderer']['navigationEndpoint']
              ['browseEndpoint']['browseId'],
          albumName: metas.split('\u2022')[1].trim(),
        );
        result.add(track);
      } catch (exception) {}
    }
    return result.cast();
  }

  static Future<List<String>> suggestions(String query) async {
    var response = await Client.request(
      'music/get_search_suggestions',
      {
        'input': query,
      },
    );
    var body = convert.jsonDecode(response.body)['contents'][0]
        ['searchSuggestionsSectionRenderer']['contents'];
    var result = <String>[];
    for (var object in body) {
      if (object.containsKey('searchSuggestionRenderer')) {
        result.add(
          object['searchSuggestionRenderer']['suggestion']['runs']
              .map((text) => text['text'])
              .toList()
              .join(''),
        );
      }
    }
    return result;
  }
}

extension TrackExtension on Track {
  Future<void> attachAudioStream() async {
    if (filePath != null) return;
    var video = await Client.external.videos.get(trackId);
    var manifest =
        await Client.external.videos.streamsClient.getManifest(video.id);
    var description = video.description.split('\n\n');
    var year;
    try {
      if (description.length >= 5) {
        year = description[4].replaceAll('Released on: ', '').split('-').first;
      }
    } catch (e) {}
    try {
      trackName = trackName ?? video.title;
    } catch (e) {}
    try {
      trackDuration = trackDuration ?? video.duration!.inMilliseconds;
    } catch (e) {}
    try {
      trackArtistNames =
          trackArtistNames ?? description[1].split(' · ').sublist(1);
    } catch (e) {}
    try {
      albumName = albumName ?? description[2].trim();
    } catch (e) {}
    try {
      albumArtistName =
          albumArtistName ?? description[1].split(' · ').sublist(1).first;
    } catch (e) {}
    try {
      year = year ?? int.tryParse(year);
    } catch (e) {}
    filePath = filePath ?? manifest.audio.withHighestBitrate().url.toString();
  }

  Future<List<Track>> get recommendations async {
    var result = [];
    var response = await Client.request(
      'next',
      {
        'enablePersistentPlaylistPanel': 'true',
        'isAudioOnly': 'true',
        'params': 'wAEB',
        'tunerSettingValue': 'AUTOMIX_SETTING_NORMAL',
        'videoId': trackId!,
      },
    );
    var body = convert.jsonDecode(response.body)['contents']
                        ['singleColumnMusicWatchNextResultsRenderer']
                    ['tabbedRenderer']
                ['watchNextTabbedResultsRenderer']['tabs'][0]['tabRenderer']
            ['content']['musicQueueRenderer']['content']
        ['playlistPanelRenderer']['contents'];
    for (var object in body) {
      object = object['playlistPanelVideoRenderer'];
      try {
        var metas = object['longBylineText']['runs']
            .map((meta) => meta['text'])
            .toList()
            .join(' ');
        var duration = object['lengthText']['runs'][0]['text'];
        duration = int.parse(duration.split(':').first) * 60 +
            int.parse(duration.split(':')[1]);
        var track = Track(
          trackId: object['videoId'],
          trackName: object['title']['runs'][0]['text'],
          trackArtistNames: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>(),
          trackDuration: duration * 1000,
          networkAlbumArt: object['thumbnail']['thumbnails']
              [object['thumbnail']['thumbnails'].length - 3]['url'],
          albumId: object['menu']['menuRenderer']['items']
                      [object['menu']['menuRenderer']['items'].length - 2]
                  ['menuNavigationItemRenderer']['navigationEndpoint']
              ['browseEndpoint']['browseId'],
          albumName: metas.split('\u2022')[1].trim(),
          year: int.parse(metas.split('\u2022').last.trim()),
        );
        result.add(track);
      } catch (exception) {}
    }
    return result.cast();
  }
}
