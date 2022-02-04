import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:harmonoid/models/media.dart';

abstract class YoutubeApi {
  static Future<List<Track>> search(String query) async {
    final result = <Track>[];
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
    } catch (_) {
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
          uri: Uri.parse(
              'https://www.youtube.com/watch?v=${object['flexColumns'].first['musicResponsiveListItemFlexColumnRenderer']['text']['runs'].first['navigationEndpoint']['watchEndpoint']['videoId']}'),
          trackName: object['flexColumns']
              .first['musicResponsiveListItemFlexColumnRenderer']['text']
                  ['runs']
              .first['text'],
          albumName: metas.split('\u2022')[1].trim(),
          trackArtistNames: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>(),
          albumArtistName: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>()
              .first,
          trackNumber: 1,
          year: kUnknownYear,
          duration: Duration(seconds: duration),
          bitrate: null,
          timeAdded: DateTime.now(),
        );
        result.add(track);
      } catch (_) {}
    }
    return result;
  }

  static Future<List<Track>> getRecommendations(String? videoId) async {
    if (videoId == null) {
      return [];
    }
    final result = <Track>[];
    final response = await Client.request(
      'next',
      {
        'enablePersistentPlaylistPanel': 'true',
        'isAudioOnly': 'true',
        'params': 'wAEB',
        'tunerSettingValue': 'AUTOMIX_SETTING_NORMAL',
        'videoId': videoId,
      },
    );
    final body = convert.jsonDecode(response.body)['contents']
                        ['singleColumnMusicWatchNextResultsRenderer']
                    ['tabbedRenderer']
                ['watchNextTabbedResultsRenderer']['tabs'][0]['tabRenderer']
            ['content']['musicQueueRenderer']['content']
        ['playlistPanelRenderer']['contents'];
    for (var object in body) {
      object = object['playlistPanelVideoRenderer'];
      try {
        final metas = object['longBylineText']['runs']
            .map((meta) => meta['text'])
            .toList()
            .join(' ');
        var duration = object['lengthText']['runs'][0]['text'];
        duration = int.parse(duration.split(':').first) * 60 +
            int.parse(duration.split(':')[1]);
        final track = Track(
          uri:
              Uri.parse('https://www.youtube.com/watch?v=${object['videoId']}'),
          trackName: object['title']['runs'][0]['text'],
          albumName: metas.split('\u2022')[1].trim(),
          trackArtistNames: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>(),
          albumArtistName: metas
              .split('\u2022')
              .first
              .split(RegExp(',|&'))
              .map((meta) => meta.trim())
              .toList()
              .cast<String>()
              .first,
          trackNumber: 1,
          year: kUnknownYear,
          duration: Duration(seconds: duration),
          bitrate: null,
          timeAdded: DateTime.now(),
        );
        result.add(track);
      } catch (_) {}
    }
    return result;
  }

  static Future<Track?> getTrack(String query) async {
    String? videoId;
    if (query.contains('youtu') && query.contains('/')) {
      if (query.contains('/watch?v=')) {
        videoId = query.substring(query.indexOf('=') + 1);
      } else {
        videoId = query.substring(query.indexOf('/') + 1);
      }
    }
    videoId = videoId?.split('&').first.split('/').first;
    if (videoId == null) {
      return null;
    }
    final video = await http.get(
      Uri.https(
        'www.youtube.com',
        '/watch',
        {
          'v': videoId,
        },
      ),
    );
    final body = video.body.split(';</script>');
    final response = convert.jsonDecode(body[body.length - 3]
            .split('var ytInitialData = ')
            .last)['contents']['twoColumnWatchNextResults']['results']
        ['results']['contents'];
    final description = response[1]['videoSecondaryInfoRenderer']['description']
        ['runs'][0]['text'];
    var trackArtistNames;
    var albumName;
    try {
      trackArtistNames = [
        response[1]['videoSecondaryInfoRenderer']['owner']['videoOwnerRenderer']
            ['title']['runs'][0]['text'],
      ].cast<String>();
      if (description.endsWith('Auto-generated by YouTube.')) {
        albumName = description.split('\n')[4].trim();
      }
    } catch (_) {}
    return Track(
      uri: Uri.parse('https://www.youtube.com/watch?v=$videoId'),
      trackName: response[0]['videoPrimaryInfoRenderer']['title']['runs'][0]
          ['text'],
      trackArtistNames:
          trackArtistNames.isNotEmpty ? trackArtistNames : [kUnknownArtist],
      albumArtistName:
          trackArtistNames.isNotEmpty ? trackArtistNames.first : kUnknownArtist,
      albumName: albumName,
      trackNumber: 1,
      year: kUnknownYear,
      duration: Duration.zero,
      bitrate: null,
      timeAdded: DateTime.now(),
    );
  }

  static Future<List<String>> getSuggestions(String query) async {
    final response = await Client.request(
      'music/get_search_suggestions',
      {
        'input': query,
      },
    );
    final body = convert.jsonDecode(response.body)['contents'][0]
        ['searchSuggestionsSectionRenderer']['contents'];
    final result = <String>[];
    for (var object in body) {
      if (object.containsKey('searchSuggestionRenderer')) {
        result.add(object['searchSuggestionRenderer']['suggestion']['runs']
            .map((text) => text['text'])
            .toList()
            .join(''));
      }
    }
    return result;
  }
}

abstract class Client {
  static Future<http.Response> request(
    String path,
    Map<String, String> properties,
  ) =>
      http.post(
        Uri.https(
          _kRequestAuthority,
          '/youtubei/v1/$path',
          {
            'key': _kRequestKey,
          },
        ),
        headers: _kRequestHeaders,
        body: convert.jsonEncode({
          ..._kRequestPayload,
          ...properties,
        }),
      );
}

const String _kRequestAuthority = 'music.youtube.com';
const String _kRequestKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';
const Map<String, String> _kRequestHeaders = {
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
const Map<String, dynamic> _kRequestPayload = {
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
