import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';
import 'package:harmonoid/extensions/string.dart';

/// Extensions for [Album].
extension AlbumExtensions on Album {
  /// Display title.
  String get displayTitle => album.isNotEmpty ? album : kDefaultAlbum;

  /// Display subtitle.
  String get displaySubtitle => [
        if (albumArtist.isNotEmpty) albumArtist,
        if (year != 0) year.toString(),
      ].where((e) => e.isNotEmpty).join(' • ');

  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        return ValueKey(album.isEmpty ? kDefaultAlbum[0].uppercase() : album[0].uppercase());
      case AlbumSortType.timestamp:
        return ValueKey(timestamp.label.uppercase());
      case AlbumSortType.year:
        return ValueKey(year == 0 ? kDefaultYear : year.toString());
      case AlbumSortType.albumArtist:
        return ValueKey(album.isEmpty ? kDefaultAlbum[0].uppercase() : album[0].uppercase());
    }
  }
}
