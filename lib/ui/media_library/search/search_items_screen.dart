import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/extensions/album.dart';
import 'package:harmonoid/extensions/artist.dart';
import 'package:harmonoid/extensions/genre.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/albums/album_item.dart';
import 'package:harmonoid/ui/media_library/artists/artist_item.dart';
import 'package:harmonoid/ui/media_library/genres/genre_item.dart';
import 'package:harmonoid/ui/media_library/tracks/tracks_table.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';

class SearchItemsScreen extends StatefulWidget {
  final String query;
  final List<MediaLibraryItem> items;
  const SearchItemsScreen({
    super.key,
    required this.query,
    required this.items,
  });

  @override
  State<SearchItemsScreen> createState() => SearchItemsScreenState();
}

class SearchItemsScreenState extends State<SearchItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (widget.items[0] is Album) {
      final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.album;
      content = ScrollViewBuilder(
        margin: margin,
        span: scrollViewBuilderHelperData.span,
        headerCount: 1,
        headerBuilder: (context, i, h) => const SizedBox.shrink(key: ValueKey('')),
        headerHeight: 0.0,
        itemCounts: [widget.items.length],
        itemBuilder: (context, i, j, w, h) {
          final Album album = widget.items[j] as Album;
          return AlbumItem(
            key: album.scrollViewBuilderKey,
            album: album,
            width: w,
            height: h,
          );
        },
        itemWidth: scrollViewBuilderHelperData.itemWidth,
        itemHeight: scrollViewBuilderHelperData.itemHeight,
        padding: EdgeInsets.only(top: margin),
        displayHeaders: false,
      );
    } else if (widget.items[0] is Artist) {
      final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.artist;
      content = ScrollViewBuilder(
        margin: margin,
        span: scrollViewBuilderHelperData.span,
        headerCount: 1,
        headerBuilder: (context, i, h) => const SizedBox.shrink(key: ValueKey('')),
        headerHeight: 0.0,
        itemCounts: [widget.items.length],
        itemBuilder: (context, i, j, w, h) {
          final Artist artist = widget.items[j] as Artist;
          return ArtistItem(
            key: artist.scrollViewBuilderKey,
            artist: artist,
            width: w,
            height: h,
          );
        },
        itemWidth: scrollViewBuilderHelperData.itemWidth,
        itemHeight: scrollViewBuilderHelperData.itemHeight,
        padding: EdgeInsets.only(top: margin),
        displayHeaders: false,
      );
    } else if (widget.items[0] is Genre) {
      final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.genre;
      content = ScrollViewBuilder(
        margin: margin,
        span: scrollViewBuilderHelperData.span,
        headerCount: 1,
        headerBuilder: (context, i, h) => const SizedBox.shrink(key: ValueKey('')),
        headerHeight: 0.0,
        itemCounts: [widget.items.length],
        itemBuilder: (context, i, j, w, h) {
          final Genre genre = widget.items[j] as Genre;
          return GenreItem(
            key: genre.scrollViewBuilderKey,
            genre: genre,
            width: w,
            height: h,
          );
        },
        itemWidth: scrollViewBuilderHelperData.itemWidth,
        itemHeight: scrollViewBuilderHelperData.itemHeight,
        padding: EdgeInsets.only(top: margin),
        displayHeaders: false,
      );
    } else if (widget.items[0] is Track) {
      content = TracksTable(tracks: widget.items.cast());
    } else {
      throw UnsupportedError('SearchItemsScreenState: build: Unsupported type: ${widget.items[0].runtimeType}');
    }

    return ContentScreen(
      caption: kCaption,
      title: Localization.instance.RESULTS_FOR_QUERY.replaceAll('"QUERY"', widget.query),
      content: content,
    );
  }
}
