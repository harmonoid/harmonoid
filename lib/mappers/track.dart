import 'package:media_library/media_library.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/ui/media_library/tracks/tracks_screen.dart';
import 'package:harmonoid/utils/constants.dart';

/// Mappers for [Track].
extension TrackMappers on Track {
  /// Convert to [Playable].
  Playable toPlayable() => Playable(
        uri: uri,
        title: title,
        subtitle: [...artists.take(2)],
        description: [if (album.isNotEmpty) album.toString(), if (year != 0) year.toString()],
      );

  /// Convert to a [DataGridRow] used in [TracksScreen].
  DataGridRow toDataGridRow() => DataGridRow(
        cells: [
          DataGridCell(
            columnName: TracksDataSource.kTrackNumber,
            value: trackNumber == 0 ? '1' : trackNumber.toString(),
          ),
          DataGridCell(
            columnName: TracksDataSource.kTitle,
            value: title,
          ),
          DataGridCell(
            columnName: TracksDataSource.kArtists,
            value: artists.isEmpty ? {kDefaultArtist} : artists,
          ),
          DataGridCell(
            columnName: TracksDataSource.kAlbum,
            value: album.isEmpty ? kDefaultAlbum : album,
          ),
          DataGridCell(
            columnName: TracksDataSource.kGenres,
            value: genres.isEmpty ? {kDefaultGenre} : genres,
          ),
          DataGridCell(
            columnName: TracksDataSource.kYear,
            value: year == 0 ? kDefaultYear : year.toString(),
          ),
        ],
      );
}
