import 'dart:convert' as convert;
import 'dart:ffi';
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
    final video = await http.post(
      Uri.https('www.youtube.com', '/youtubei/v1/player', {
        'key': "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8",
        'contentCheckOk': "true",
        'racyCheckOk': "true",
        "videoId": videoId,
      }),
      body: convert.jsonEncode({
        'context': {
          'client': {'clientName': 'MWEB', 'clientVersion': '2.20211109.01.00'}
        },
        'api_key': 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8'
      }),
    );
    final Map response = convert.jsonDecode(video.body);
    final Map details = response['videoDetails'];
    final bool hasMicroformat = response.containsKey("microformat");
    final Map microformat = hasMicroformat
        ? response["microformat"]["playerMicroformatRenderer"]
        : {};
    final String description =
        hasMicroformat ? microformat["description"]["runs"][0]["text"] : "";
    var trackArtistNames;
    var albumName;
    try {
      trackArtistNames = [
        details["author"].toString().replaceAll(" - Topic", ""),
      ].cast<String>();
      if (description.endsWith('Auto-generated by YouTube.')) {
        albumName = description.split('\n')[4].trim();
      }
    } catch (_) {}
    int? bitrate;
    for (Map stream in response["streamingData"]["adaptiveFormats"]) {
      if (stream["itag"] == 251) {
        bitrate = stream["bitrate"];
      }
    }
    return Track(
      uri: Uri.parse('https://www.youtube.com/watch?v=$videoId'),
      trackName: details["title"],
      trackArtistNames:
          trackArtistNames.isNotEmpty ? trackArtistNames : [kUnknownArtist],
      albumArtistName:
          trackArtistNames.isNotEmpty ? trackArtistNames.first : kUnknownArtist,
      albumName: albumName ?? kUnknownAlbum,
      trackNumber: 1,
      year: hasMicroformat && microformat["publishDate"] != null
          ? microformat["publishDate"].toString().split("-")[0]
          : kUnknownYear,
      duration: Duration(seconds: int.parse(details["lengthSeconds"])),
      bitrate: bitrate,
      timeAdded: hasMicroformat
          ? DateTime.parse(microformat["publishDate"])
          : DateTime.now(),
    );
  }

  /// Contains cached suggestions for the given query.
  static var cacheSuggestions = Map<String, String>();

  static Future<List<String>> getSuggestions(String query) async {
    late String body;
    final result = <String>[];

    /// If cached, return cached suggestions.
    /// else make a request to the API.
    if (cacheSuggestions.containsKey(query)) {
      body = cacheSuggestions[query]!;
    } else {
      final response = await Client.request(
        'music/get_search_suggestions',
        {
          'input': query,
        },
      );
      body = response.body;
    }

    if (body.isNotEmpty) {
      cacheSuggestions[query] = body;
      final bodyDecoded = convert.jsonDecode(body);
      if (bodyDecoded['contents'] is List) {
        final contents = bodyDecoded['contents'][0]
            ['searchSuggestionsSectionRenderer']['contents'];

        if (contents is List) {
          for (var object in contents) {
            if (object.containsKey('searchSuggestionRenderer')) {
              result.add(object['searchSuggestionRenderer']['suggestion']
                      ['runs']
                  .map((text) => text['text'])
                  .toList()
                  .join(''));
            }
          }
        }
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
  'x-youtube-client-version': '1.20220209.00.00',
  'x-forwarded-for': '6.0.0.0/8',
  'user-agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36 Edg/97.0.1072.69,gzip(gfe)',
};
const Map<String, dynamic> _kRequestPayload = {
  'context': {
    'client': {
      'hl': 'en',
      'gl': 'US',
      'remoteHost': '6.0.0.0/8',
      'osName': 'Windows',
      'platform': 'DESKTOP',
      'userAgent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36 Edg/97.0.1072.69,gzip(gfe)',
      'clientName': 'WEB_REMIX',
      'clientVersion': '1.20220209.00.00',
      'timeZone': 'America/Phoenix',
      'visitorData': 'Cgtua1JLWXRtU0s0YyiFy6WQBg%3D%3D',
    },
    'user': {
      'lockedSafetyMode': false,
    },
    'request': {
      'useSsl': true,
      'internalExperimentFlags': [],
      'consistencyTokenJars': []
    },
  }
};
