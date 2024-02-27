import 'package:harmonoid/models/playable.dart';

/// Extensions for [Playable].
extension PlayableExtensions on Playable {
  /// Lyrics API name.
  String get lyricsApiName => [title, ...subtitle.take(2)].join(' ');
}
