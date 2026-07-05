import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/features/media_library/utils/constants.dart';

/// Extensions for [Genre].
extension GenreExtensions on Genre {
  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryGenreSortType) {
      case GenreSortType.genre:
        return ValueKey(genre.isEmpty ? kDefaultGenre[0].uppercase() : genre[0].uppercase());
      case GenreSortType.timestamp:
        return ValueKey(timestamp.label);
    }
  }
}
