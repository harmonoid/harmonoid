import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';

Future<void> navigateToAlbum(BuildContext context, AlbumLookupKey key) async {
  final album = context.read<MediaLibrary>().lookupAlbum(key);
  if (album != null) {
    final tracks = await context.read<MediaLibrary>().tracksFromAlbum(album);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: album, cacheWidth: 20));
      palette = result.colors?.toList();
    }

    await precacheImage(cover(item: album), context);

    _sanitizeContext(context).push(
      '/$kMediaLibraryPath/$kAlbumPath',
      extra: AlbumPathExtra(
        album: album,
        tracks: tracks,
        palette: palette,
      ),
    );
  }
}

Future<void> navigateToArtist(BuildContext context, ArtistLookupKey key) async {
  final artist = context.read<MediaLibrary>().lookupArtist(key);
  if (artist != null) {
    final [tracks, albums] = await Future.wait([
      context.read<MediaLibrary>().tracksFromArtist(artist),
      context.read<MediaLibrary>().albumsFromArtist(artist),
    ]);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: artist, cacheWidth: 20));
      palette = result.colors?.toList();
    }

    await precacheImage(cover(item: artist), context);

    _sanitizeContext(context).push(
      '/$kMediaLibraryPath/$kArtistPath',
      extra: ArtistPathExtra(
        artist: artist,
        tracks: tracks as List<Track>,
        albums: albums as List<Album>,
        palette: palette,
      ),
    );
  }
}

Future<void> navigateToGenre(BuildContext context, GenreLookupKey key) async {
  final genre = context.read<MediaLibrary>().lookupGenre(key);
  if (genre != null) {
    final tracks = await context.read<MediaLibrary>().tracksFromGenre(genre);

    // NOTE: Palette is not used for genres.
    // List<Color>? palette;
    // if (isMaterial2) {
    //   final result = await PaletteGenerator.fromImageProvider(cover(item: genre, cacheWidth: 20));
    //   palette = result.colors?.toList();
    // }

    await precacheImage(cover(item: genre), context);

    _sanitizeContext(context).push(
      '/$kMediaLibraryPath/$kGenrePath',
      extra: GenrePathExtra(
        genre: genre,
        tracks: tracks,
        palette: null,
      ),
    );
  }
}

BuildContext _sanitizeContext(BuildContext context) {
  bool shouldPop() {
    try {
      return !router.location.startsWith('/$kMediaLibraryPath');
    } catch (_) {
      return true;
    }
  }

  final ctx = router.routerDelegate.navigatorKey.currentContext!;

  if (shouldPop()) {
    while (ctx.canPop()) {
      ctx.pop();
    }
  }

  return ctx;
}
