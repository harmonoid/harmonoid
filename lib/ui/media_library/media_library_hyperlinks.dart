import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/rendering.dart';

Future<void> navigateToAlbum(BuildContext context, AlbumLookupKey key) async {
  final album = MediaLibrary.instance.lookupAlbum(key);
  if (album != null) {
    final tracks = await MediaLibrary.instance.tracksFromAlbum(album);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: album, cacheWidth: 200));
      palette = result.colors?.toList();
    }

    await precacheImage(cover(item: album), context);

    context.push(
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
  final artist = MediaLibrary.instance.lookupArtist(key);
  if (artist != null) {
    final tracks = await MediaLibrary.instance.tracksFromArtist(artist);

    List<Color>? palette;
    if (isMaterial2) {
      final result = await PaletteGenerator.fromImageProvider(cover(item: artist, cacheWidth: 200));
      palette = result.colors?.toList();
    }

    await precacheImage(cover(item: artist), context);

    context.push(
      '/$kMediaLibraryPath/$kArtistPath',
      extra: ArtistPathExtra(
        artist: artist,
        tracks: tracks,
        palette: palette,
      ),
    );
  }
}

Future<void> navigateToGenre(BuildContext context, GenreLookupKey key) async {
  final genre = MediaLibrary.instance.lookupGenre(key);
  if (genre != null) {
    final tracks = await MediaLibrary.instance.tracksFromGenre(genre);

    // NOTE: Palette is not used for genres.
    // List<Color>? palette;
    // if (isMaterial2) {
    //   final result = await PaletteGenerator.fromImageProvider(cover(item: genre, cacheWidth: 200));
    //   palette = result.colors?.toList();
    // }

    await precacheImage(cover(item: genre), context);

    context.push(
      '/$kMediaLibraryPath/$kGenrePath',
      extra: GenrePathExtra(
        genre: genre,
        tracks: tracks,
        palette: null,
      ),
    );
  }
}
