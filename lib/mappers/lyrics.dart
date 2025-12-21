import 'package:lrc/lrc.dart';

import 'package:harmonoid/models/lyrics.dart';

/// Mappers for [Lyrics].
extension LyricsMappers on Lyrics {
  /// Converts to formatted LRC.
  String toLrc() {
    return Lrc(
      lyrics: map(
        (lyric) => LrcLine(
          timestamp: Duration(milliseconds: lyric.timestamp),
          lyrics: lyric.text,
          readableText: lyric.text,
          parts: null,
          person: null,
          type: LrcTypes.simple,
        ),
      ).toList(),
    ).format();
  }
}
