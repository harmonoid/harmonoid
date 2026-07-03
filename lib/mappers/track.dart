import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/widgets.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/extensions/set.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/utils/constants.dart';

/// Mappers for [Track].
extension TrackMappers on Track {
  /// Converts to [Playable].
  Playable toPlayable() => Playable(
    uri: uri,
    title: title,
    subtitle: [...artists],
    description: [if (album.isNotEmpty) album.toString(), if (year != 0) year.toString()],
  );

  /// Converts to title [TappableText].
  TappableText toTitleTappableText() => TappableText(text: [TappableTextData(text: title)]);

  /// Converts to subtitle [TappableText].
  TappableText toSubtitleTappableText() => TappableText(
    text: [
      TappableTextData(
        text: [
          if (artists.isNotEmpty) artists.join(', '),
          if (album.isNotEmpty) album,
          if (year != 0) year.toString(),
        ].where((e) => e.isNotEmpty).join(' • '),
      ),
    ],
  );

  /// Converts to artists [TappableText].
  TappableText toArtistsTappableText(BuildContext context) => TappableText(
    text: artists
        .ifEmpty({''})
        .map(
          (e) => TappableTextData(
            text: e.nullIfBlank() ?? kDefaultArtist,
            onTap: () => navigateToArtist(context, ArtistLookupKey(artist: e)),
          ),
        ),
  );

  /// Converts to album [TappableText].
  TappableText toAlbumTappableText(BuildContext context) => TappableText(
    text: [
      TappableTextData(
        text: album.nullIfBlank() ?? kDefaultAlbum,
        onTap: () => navigateToAlbum(context, AlbumLookupKey(album: album, albumArtist: albumArtist, year: year)),
      ),
    ],
  );

  /// Converts to genres [TappableText].
  TappableText toGenresTappableText(BuildContext context) => TappableText(
    text: genres
        .ifEmpty({''})
        .map(
          (e) => TappableTextData(
            text: e.nullIfBlank() ?? kDefaultGenre,
            onTap: () => navigateToGenre(context, GenreLookupKey(genre: e)),
          ),
        ),
  );

  /// Converts to year [TappableText].
  TappableText toYearTappableText() => TappableText(text: [TappableTextData(text: year == 0 ? kDefaultYear : year.toString())]);

  /// Converts to [FileExplorer] grid subtitle 0 [TappableText].
  TappableText toFileExplorerGridSubtitle0TappableText(BuildContext context) => TappableText(
    text: artists.map(
      (e) => TappableTextData(
        text: e.nullIfBlank() ?? kDefaultArtist,
        onTap: () => navigateToArtist(context, ArtistLookupKey(artist: e)),
      ),
    ),
  );

  /// Converts to [FileExplorer] grid subtitle 1 [TappableText].
  TappableText toFileExplorerGridSubtitle1TappableText(BuildContext context) => TappableText(
    text: [
      if (album.isNotEmpty)
        TappableTextData(
          text: album,
          onTap: () => navigateToAlbum(context, AlbumLookupKey(album: album, albumArtist: albumArtist, year: year)),
        ),
      if (year != 0) TappableTextData(text: year.toString()),
    ],
    separator: ' • ',
  );

  /// Converts to [LyricsKey].
  LyricsKey toLyricsKey() {
    return LyricsKey(
      track: title,
      artist: artists.firstOrNull ?? '',
      duration: duration,
    );
  }
}
