import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';
import 'package:harmonoid/extensions/string.dart';

/// Extensions for [Artist].
extension ArtistExtensions on Artist {
  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        return ValueKey(artist.isEmpty ? kDefaultArtist[0].uppercase() : artist[0].uppercase());
      case ArtistSortType.timestamp:
        return ValueKey(timestamp.label);
    }
  }
}
