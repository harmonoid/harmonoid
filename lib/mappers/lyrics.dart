import 'package:lrc/lrc.dart';

import 'package:harmonoid/models/lyrics.dart';

/// Mappers for [Lyrics].
extension LyricsMappers on Lyrics {
  /// Converts to formatted LRC.
  String toLrc() {
    return Lrc(lyrics: map((lyric) => LrcLine(timestamp: Duration(milliseconds: lyric.timestamp), lyrics: lyric.text, type: LrcTypes.simple)).toList()).format();
  }
}
