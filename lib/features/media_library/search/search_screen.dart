import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/albums/album_item.dart';
import 'package:harmonoid/features/media_library/artists/artist_item.dart';
import 'package:harmonoid/features/media_library/genres/genre_item.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/features/media_library/search/search_banner.dart';
import 'package:harmonoid/features/media_library/search/search_no_items_banner.dart';
import 'package:harmonoid/features/media_library/tracks/tracks_table.dart';
import 'package:harmonoid/features/media_library/utils/dimensions.dart';
import 'package:harmonoid/routing/models/search_items_path_extra.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/widgets.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with ScrollControllerMixin {
  static const int kLimit = 20;

  late final ScrollController _scrollController = getScrollController('search-screen');
  final List<Album> _albums = <Album>[];
  final List<Artist> _artists = <Artist>[];
  final List<Genre> _genres = <Genre>[];
  final List<Track> _tracks = <Track>[];

  String? _currentQuery;

  void update(String query) async {
    _currentQuery = query;
    final result = await context.read<MediaLibrary>().search(
      query,
      limit: kLimit,
    );
    if (_currentQuery != query) {
      return;
    }
    if (context.mounted) {
      setState(() {
        _albums
          ..clear()
          ..addAll(result.whereType<Album>());
        _artists
          ..clear()
          ..addAll(result.whereType<Artist>());
        _genres
          ..clear()
          ..addAll(result.whereType<Genre>());
        _tracks
          ..clear()
          ..addAll(result.whereType<Track>());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.query;
    update(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _currentQuery = widget.query;
      update(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaLibrarySearchViewVisible = TickerMode.of(context);
    if (widget.query.isEmpty) {
      return const SearchBanner();
    }
    if (_albums.isEmpty && _artists.isEmpty && _genres.isEmpty && _tracks.isEmpty) {
      return const SearchNoItemsBanner();
    }
    return Scaffold(
      body: ListView(
        controller: _scrollController,

        padding: EdgeInsets.zero,
        children: [
          if (_albums.isNotEmpty) ...[
            Row(
              children: [
                SubHeader(Localization.instance.ALBUMS),
                const Spacer(),
                if (_albums.length > kLimit)
                  ShowAllButton(
                    onPressed: () async {
                      context.push(
                        '/$kMediaLibraryPath/$kSearchItemsPath',
                        extra: SearchItemsPathExtra(
                          query: widget.query,
                          items: (await context.read<MediaLibrary>().search(widget.query)).whereType<Album>().toList(),
                        ),
                      );
                    },
                  ),
                SizedBox(width: margin),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: albumItemHeight + margin,
              child: ListView.separated(
                itemCount: _albums.length.clamp(0, kLimit),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: margin,
                  right: margin,
                  bottom: margin,
                ),
                itemBuilder: (context, i) => AlbumItem(
                  album: _albums[i],
                  width: albumItemWidth,
                  height: albumItemHeight,
                ),
                separatorBuilder: (context, _) => SizedBox(width: margin),
              ),
            ),
          ],
          if (_artists.isNotEmpty) ...[
            Row(
              children: [
                SubHeader(Localization.instance.ARTISTS),
                const Spacer(),
                if (_artists.length > kLimit)
                  ShowAllButton(
                    onPressed: () async {
                      context.push(
                        '/$kMediaLibraryPath/$kSearchItemsPath',
                        extra: SearchItemsPathExtra(
                          query: widget.query,
                          items: (await context.read<MediaLibrary>().search(widget.query)).whereType<Artist>().toList(),
                        ),
                      );
                    },
                  ),
                SizedBox(width: margin),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: artistItemHeight + margin,
              child: ListView.separated(
                itemCount: _artists.length.clamp(0, kLimit),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: margin,
                  right: margin,
                  bottom: margin,
                ),
                itemBuilder: (context, i) => ArtistItem(
                  artist: _artists[i],
                  width: artistItemWidth,
                  height: artistItemHeight,
                ),
                separatorBuilder: (context, _) => SizedBox(width: margin),
              ),
            ),
          ],
          if (_genres.isNotEmpty) ...[
            Row(
              children: [
                SubHeader(Localization.instance.GENRES),
                const Spacer(),
                if (_genres.length > kLimit)
                  ShowAllButton(
                    onPressed: () async {
                      context.push(
                        '/$kMediaLibraryPath/$kSearchItemsPath',
                        extra: SearchItemsPathExtra(
                          query: widget.query,
                          items: (await context.read<MediaLibrary>().search(widget.query)).whereType<Genre>().toList(),
                        ),
                      );
                    },
                  ),
                SizedBox(width: margin),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: genreItemHeight + margin,
              child: ListView.separated(
                itemCount: _genres.length.clamp(0, kLimit),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: margin,
                  right: margin,
                  bottom: margin,
                ),
                itemBuilder: (context, i) => GenreItem(
                  genre: _genres[i],
                  width: genreItemWidth,
                  height: genreItemHeight,
                ),
                separatorBuilder: (context, _) => SizedBox(width: margin),
              ),
            ),
          ],
          if (_tracks.isNotEmpty) ...[
            Row(
              children: [
                SubHeader(Localization.instance.TRACKS),
                const Spacer(),
                if (_tracks.length > kLimit)
                  ShowAllButton(
                    onPressed: () async {
                      context.push(
                        '/$kMediaLibraryPath/$kSearchItemsPath',
                        extra: SearchItemsPathExtra(
                          query: widget.query,
                          items: (await context.read<MediaLibrary>().search(widget.query)).whereType<Track>().toList(),
                        ),
                      );
                    },
                  ),
                SizedBox(width: margin),
              ],
            ),
            SizedBox(
              height: (_tracks.length + 1) * linearTileHeight,
              child: TracksTable(
                tracks: _tracks,
                physics: const NeverScrollableScrollPhysics(),
                mobileSliverList: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
