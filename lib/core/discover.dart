import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:harmonoid/core/collection.dart';
import 'package:http/http.dart' as http;

const List<String> SCRIPTS = <String>['yt-music-headless'];
const String SCRIPT_PORT = '65535';

class Discover {
  Future<List<Track>> search(String query) async {
    http.Response response = await http.get(
      Uri.http(
        'localhost:$SCRIPT_PORT',
        '/track_search',
        {
          'query': query,
        },
      ),
    );
    if (response.statusCode != 200) return [];
    return jsonDecode(response.body)
        .map(
          (track) => Track(
            trackId: track['track_id'],
            trackName: track['track_name'],
            trackArtistNames: track['track_artists'].cast<String>(),
            albumId: track['album_id'],
            albumName: track['album_name'],
            albumArtistName: track['track_artists'].first,
            networkAlbumArt: track['track_album_art'],
            trackDuration: track['track_duration'],
            filePath:
                'http://localhost:$SCRIPT_PORT/track_stream?track_id=${track['track_id']}',
          ),
        )
        .toList()
        .cast<Track>();
  }

  static Future<void> init() async {
    for (var executable in SCRIPTS) {
      try {
        await _start(executable);
        return;
      } on ScriptNotFound {}
    }
    throw ScriptNotFound();
  }
}

extension on List {
  bool equals(List list) {
    if (this.length != list.length) return false;
    return this.every((item) => list.contains(item));
  }
}

class ScriptNotFound implements Exception {
  final String? message;
  const ScriptNotFound({this.message});
}

class ScriptStartError implements Exception {
  final String? message;
  const ScriptStartError({this.message});
}

Future<void> _start(String executable) async {
  Completer<void> completer = Completer<void>();
  try {
    Process process = await Process.start(
      executable,
      <String>[
        SCRIPT_PORT,
      ],
      workingDirectory: {
        'windows': () => Platform.environment['USERPROFILE']!,
        'linux': () => Platform.environment['HOME']!,
        'macos': () => Platform.environment['HOME']!,
      }[Platform.operatingSystem]!(),
    );
    process.stdout.listen((event) {
      if (event.equals(
          [83, 84, 65, 82, 84, 95, 83, 85, 67, 67, 69, 83, 83, 13, 10])) {
        if (!completer.isCompleted) completer.complete();
      } else {
        if (!completer.isCompleted) completer.completeError(ScriptStartError());
      }
    }, onDone: () {
      if (!completer.isCompleted) completer.completeError(ScriptStartError());
    });
    process.stderr.listen((event) {
      if (!completer.isCompleted) completer.completeError(ScriptStartError());
    });
  } on ProcessException {
    if (!completer.isCompleted) completer.completeError(ScriptNotFound());
  }
  return completer.future;
}
