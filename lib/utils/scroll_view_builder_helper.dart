import 'package:adaptive_layouts/adaptive_layouts.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template scroll_view_builder_helper}
///
/// ScrollViewBuilderHelper
/// -----------------------
/// Implementation to retrieve span, width & height of items for usage in [ScrollViewBuilder].
///
/// {@endtemplate}
class ScrollViewBuilderHelper {
  /// Singleton instance.
  static const ScrollViewBuilderHelper instance = ScrollViewBuilderHelper._();

  /// {@macro scroll_view_builder_helper}
  const ScrollViewBuilderHelper._();

  ScrollViewBuilderHelperData get album {
    final span = isDesktop ? null : Configuration.instance.mobileAlbumGridSpan;
    final itemWidth = span != 1 ? kAlbumTileWidth : double.infinity;
    final itemHeight = span != 1 ? kAlbumTileHeight : kAlbumListTileHeight;
    return ScrollViewBuilderHelperData(span, itemWidth, itemHeight);
  }

  ScrollViewBuilderHelperData get track {
    const span = 1;
    const itemWidth = double.infinity;
    final itemHeight = isDesktop ? kDesktopTrackTileHeight : kMobileTrackTileHeight;
    return ScrollViewBuilderHelperData(span, itemWidth, itemHeight);
  }

  ScrollViewBuilderHelperData get artist {
    final span = isDesktop ? null : Configuration.instance.mobileArtistGridSpan;
    final itemWidth = span != 1 ? kArtistTileWidth : double.infinity;
    final itemHeight = span != 1 ? kArtistTileHeight : kArtistListTileHeight;
    return ScrollViewBuilderHelperData(span, itemWidth, itemHeight);
  }

  ScrollViewBuilderHelperData get genre {
    final span = isDesktop ? null : Configuration.instance.mobileGenreGridSpan;
    final itemWidth = span != 1 ? kGenreTileWidth : double.infinity;
    final itemHeight = span != 1 ? kGenreTileHeight : kArtistListTileHeight;
    return ScrollViewBuilderHelperData(span, itemWidth, itemHeight);
  }
}

/// {@template scroll_view_builder_helper_data}
///
/// ScrollViewBuilderHelperData
/// ---------------------------
///
/// {@endtemplate}
class ScrollViewBuilderHelperData {
  final int? span;
  final double itemWidth;
  final double itemHeight;

  /// {@macro scroll_view_builder_helper_data}
  const ScrollViewBuilderHelperData(
    this.span,
    this.itemWidth,
    this.itemHeight,
  );
}
