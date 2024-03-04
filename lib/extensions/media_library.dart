import 'package:media_library/media_library.dart';

/// Extensions for [MediaLibrary].
extension MediaLibraryExtension on MediaLibrary {
  /// Whether the media library is empty.
  bool get isEmpty => albums.isEmpty || artists.isEmpty || genres.isEmpty || tracks.isEmpty;
}
