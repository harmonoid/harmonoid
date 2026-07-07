import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/features/media_library/utils/dimensions.dart';
import 'package:harmonoid/features/now_playing/utils/dimensions.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template media_library_scroll_view_builder_data_provider}
///
/// MediaLibraryScrollViewBuilderDataProvider
/// -----------------------------------------
/// Implementation to retrieve span, width & height of items for usage in [ScrollViewBuilder].
///
/// {@endtemplate}
class MediaLibraryScrollViewBuilderDataProvider {
  final BuildContext context;

  /// {@macro media_library_scroll_view_builder_data_provider}
  const MediaLibraryScrollViewBuilderDataProvider(this.context);

  ScrollViewBuilderData get album {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryAlbumScrollViewBuilderSpan == 0
              ? (MediaQuery.of(context).size.width - margin) ~/ (albumItemWidth + margin)
              : Configuration.instance.mobileMediaLibraryAlbumScrollViewBuilderSpan);
    final itemWidth = span != 1 ? albumItemWidth : double.infinity;
    final itemHeight = span != 1 ? albumItemHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        labelTextStyle = _theme.textTheme.titleLarge!;
        break;
      case AlbumSortType.timestamp:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
      case AlbumSortType.year:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
      case AlbumSortType.albumArtist:
        labelTextStyle = _theme.textTheme.titleLarge!;
        break;
    }
    return ScrollViewBuilderData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderData get track {
    const span = 1;
    const itemWidth = double.infinity;
    final itemHeight = linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryTrackSortType) {
      case TrackSortType.title:
        labelTextStyle = _theme.textTheme.titleLarge!;
        break;
      case TrackSortType.timestamp:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
      case TrackSortType.year:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderData get artist {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryArtistScrollViewBuilderSpan == 0
              ? (MediaQuery.of(context).size.width - margin) ~/ (artistItemWidth + margin)
              : Configuration.instance.mobileMediaLibraryArtistScrollViewBuilderSpan);
    final itemWidth = span != 1 ? artistItemWidth : double.infinity;
    final itemHeight = span != 1 ? artistItemHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        labelTextStyle = _theme.textTheme.titleLarge!;
        break;
      case ArtistSortType.timestamp:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderData get genre {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryGenreScrollViewBuilderSpan == 0
              ? (MediaQuery.of(context).size.width - margin) ~/ (genreItemWidth + margin)
              : Configuration.instance.mobileMediaLibraryGenreScrollViewBuilderSpan);
    final itemWidth = span != 1 ? genreItemWidth : double.infinity;
    final itemHeight = span != 1 ? genreItemHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryGenreSortType) {
      case GenreSortType.genre:
        labelTextStyle = _theme.textTheme.titleLarge!;
        break;
      case GenreSortType.timestamp:
        labelTextStyle = _theme.textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  EdgeInsets get padding {
    if (isDesktop) {
      return EdgeInsets.zero;
    } else if (isTablet) {
      throw UnimplementedError();
    } else if (isMobile) {
      return EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + margin + kMobileSearchBarHeight,
        bottom: kMobileNowPlayingBarHeight,
      );
    }
    throw UnimplementedError();
  }

  ThemeData get _theme => Theme.of(context);
}

class ScrollViewBuilderData {
  final int? span;
  final double itemWidth;
  final double itemHeight;
  final TextStyle labelTextStyle;

  const ScrollViewBuilderData(
    this.span,
    this.itemWidth,
    this.itemHeight,
    this.labelTextStyle,
  );
}
