// ignore_for_file: empty_catches
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

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
    var video = await Client.request(
      'player',
      {
        'videoId': trackId!,
      },
    );
    var preferred;
    var fallback;
    var body =
        convert.jsonDecode(video.body)['streamingData']['adaptiveFormats'];
    for (var format in body) {
      if (format['itag'] == 251) preferred = format['signatureCipher'];
      if (format['itag'] == 18) fallback = format['signatureCipher'];
    }
    // Apparently YouTube Explode (Dart?) is very slow & unnecessarily way too much object oriented to
    // sub-class or expose certain utils. Its very inefficient how it deciphers the URL,
    // so decided to write own decipher backend using internal PyTube utils.
    //
    //The source code can be found in a comment below.
    //
    var stream = await http.get(Uri.parse(
        'https://yt-music-headless.vercel.app/decipher?${preferred ?? fallback}'));
    filePath = stream.body;
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

// import asyncio
// import aiohttp
// from pytube import YouTube
// from pytube.extract import apply_signature
// from pytube import YouTube, extract, __js_url__
// from fastapi import FastAPI, Response
// class Extractor(YouTube):
//     def __init__(self):
//         self._js_url: str = None
//         self._js: str = None
//         self.streams_data = []
//         self.stream_url = {}
//     async def get_javascript(self) -> None:
//         async with aiohttp.ClientSession() as session:
//             async with session.get('https://www.youtube.com/watch') as response:
//                 watch_html = await response.text()
//                 loop = asyncio.get_event_loop()
//                 self._js_url = await loop.run_in_executor(None, extract.js_url, watch_html)
//                 if __js_url__ != self._js_url:
//                     async with aiohttp.ClientSession() as session:
//                         async with session.get(self._js_url) as response:
//                             self._js = await response.text()
//     async def get_stream_url(self, s, url):
//         self.streams_data = [{
//             'itag': 0,
//             's': s,
//             'url': url,
//         }]
//         self._player_response = {
//             'player_response': {'streamingData': self.streams_data}}
//         await self._decipher()
//         return self.stream_url
//     async def _decipher(self, retry: bool = False) -> None:
//         if not self._js or retry:
//             await self.get_javascript()
//         loop = asyncio.get_event_loop()
//         await loop.run_in_executor(None, apply_signature, self.streams_data, self._player_response, self._js)
//         self.stream_url = self.streams_data[0]['url']
// app = FastAPI()
// extractor = Extractor()
// @app.on_event('startup')
// async def startup():
//     try:
//         await extractor.get_javascript()
//     except:
//         pass
// @app.get('/decipher')
// async def decipher(s: str, url: str):
//     url = await extractor.get_stream_url(s, url)
//     return Response(url, 200)
