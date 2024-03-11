// ignore_for_file: depend_on_referenced_packages
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/tracks/track_item.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/widgets.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen> {
  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return const DesktopTracksScreen();
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return const MobileTrackScreen();
    }
    throw UnimplementedError();
  }
}

class MobileTrackScreen extends StatelessWidget {
  const MobileTrackScreen({super.key});

  double get headerHeight => kMobileHeaderHeight;

  Widget headerBuilder(BuildContext context, int i, double h) => const MobileMediaLibraryHeader(key: ValueKey(''));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.track;

          return ScrollViewBuilder(
            margin: margin,
            span: scrollViewBuilderHelperData.span,
            headerCount: 1,
            headerBuilder: headerBuilder,
            headerHeight: headerHeight,
            itemCounts: [mediaLibrary.tracks.length],
            itemBuilder: (context, i, j, w, h) => TrackItem(
              key: mediaLibrary.tracks[j].scrollViewBuilderKey,
              track: mediaLibrary.tracks[j],
              width: w,
              height: h,
            ),
            labelConstraints: scrollViewBuilderHelperData.labelConstraints,
            labelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
            itemWidth: scrollViewBuilderHelperData.itemWidth,
            itemHeight: scrollViewBuilderHelperData.itemHeight,
          );
        },
      ),
    );
  }
}

class DesktopTracksScreen extends StatefulWidget {
  const DesktopTracksScreen({super.key});

  @override
  State<DesktopTracksScreen> createState() => DesktopTracksScreenState();
}

class DesktopTracksScreenState extends State<DesktopTracksScreen> {
  final _debouncer = Debouncer();
  final ValueNotifier<Map<String, double>> _widthsNotifier = ValueNotifier<Map<String, double>>(Configuration.instance.mediaLibraryDesktopTracksScreenColumnWidths);

  @override
  void initState() {
    super.initState();
    _debouncer.dispose();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _widthsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _widthsNotifier.value[TracksDataSource.kTrackNumber] ??= kDesktopTrackTileHeight + 8.0;
    _widthsNotifier.value[TracksDataSource.kTitle] ??= (MediaQuery.of(context).size.width - kDesktopTrackTileHeight - 8.0) * 5 / 17;
    _widthsNotifier.value[TracksDataSource.kArtists] ??= (MediaQuery.of(context).size.width - kDesktopTrackTileHeight - 8.0) * 4 / 17;
    _widthsNotifier.value[TracksDataSource.kAlbum] ??= (MediaQuery.of(context).size.width - kDesktopTrackTileHeight - 8.0) * 3 / 17;
    _widthsNotifier.value[TracksDataSource.kAlbum] ??= (MediaQuery.of(context).size.width - kDesktopTrackTileHeight - 8.0) * 3 / 17;
    _widthsNotifier.value[TracksDataSource.kYear] ??= (MediaQuery.of(context).size.width - kDesktopTrackTileHeight - 8.0) * 2 / 17;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final source = TracksDataSource(
            context: context,
            tracks: mediaLibrary.tracks,
          );
          return Column(
            children: [
              const SizedBox(
                height: kDesktopHeaderHeight,
                child: DesktopMediaLibraryHeader(),
              ),
              Expanded(
                child: ValueListenableBuilder<Map<String, double>>(
                  valueListenable: _widthsNotifier,
                  builder: (context, widths, _) => SfDataGridTheme(
                    data: SfDataGridThemeData(
                      rowHoverColor: Theme.of(context).highlightColor,
                      gridLineColor: Theme.of(context).dividerTheme.color,
                      gridLineStrokeWidth: 1.0,
                    ),
                    child: SfDataGrid(
                      rowHeight: kDesktopTrackTileHeight,
                      headerRowHeight: kDesktopHeaderHeight,
                      allowColumnsResizing: true,
                      columnWidthMode: ColumnWidthMode.none,
                      columnResizeMode: ColumnResizeMode.onResize,
                      gridLinesVisibility: GridLinesVisibility.both,
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      source: source,
                      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                        _widthsNotifier.value = {
                          ..._widthsNotifier.value,
                          details.column.columnName: details.width,
                        };
                        _debouncer.run(() {
                          Configuration.instance.set(mediaLibraryDesktopTracksScreenColumnWidths: _widthsNotifier.value);
                        });
                        return true;
                      },
                      onCellTap: (e) async {
                        await MediaPlayer.instance.open(
                          mediaLibrary.tracks.map((e) => e.toPlayable()).toList(),
                          index: e.rowColumnIndex.rowIndex - 1,
                        );
                      },
                      onCellSecondaryTap: (e) async {
                        final result = await showMaterialMenu(
                          context: context,
                          constraints: const BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          position: RelativeRect.fromLTRB(
                            e.globalPosition.dx,
                            e.globalPosition.dy - captionHeight - kDesktopAppBarHeight,
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                          ),
                          items: trackPopupMenuItems(
                            context,
                            mediaLibrary.tracks[e.rowColumnIndex.rowIndex - 1],
                          ),
                        );
                        if (result != null) {
                          await trackPopupMenuHandle(
                            context,
                            mediaLibrary.tracks[e.rowColumnIndex.rowIndex - 1],
                            result,
                          );
                        }
                      },
                      columns: [
                        GridColumn(
                          columnName: TracksDataSource.kTrackNumber,
                          width: widths[TracksDataSource.kTrackNumber]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: kDesktopTrackTileHeight,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.center,
                            child: Text(
                              '#',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: TracksDataSource.kTitle,
                          width: widths[TracksDataSource.kTitle]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: 200.0,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.TRACK,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: TracksDataSource.kArtists,
                          width: widths[TracksDataSource.kArtists]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: 200.0,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.ARTISTS,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: TracksDataSource.kAlbum,
                          width: widths[TracksDataSource.kAlbum]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: 200.0,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.ALBUM,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: TracksDataSource.kGenres,
                          width: widths[TracksDataSource.kGenres]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: 200.0,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.GENRES,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: TracksDataSource.kYear,
                          width: widths[TracksDataSource.kYear]!,
                          columnWidthMode: ColumnWidthMode.none,
                          minimumWidth: 200.0,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Language.instance.YEAR,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TracksDataSource extends DataGridSource {
  final List<Track> tracks;
  final BuildContext context;

  TracksDataSource({required this.tracks, required this.context});

  late final List<DataGridRow> _rows = tracks.map((track) => track.toDataGridRow()).toList();

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map(
        (cell) {
          final style = Theme.of(context).textTheme.bodyLarge;
          final alignment = {
            kTrackNumber: Alignment.center,
            kTitle: Alignment.centerLeft,
            kArtists: Alignment.centerLeft,
            kAlbum: Alignment.centerLeft,
            kGenres: Alignment.centerLeft,
            kYear: Alignment.centerLeft,
          }[cell.columnName]!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: alignment,
            child: {
              kTrackNumber: () => Text(
                    cell.value as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
              kTitle: () => Text(
                    cell.value as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
              kArtists: () => HyperLink(
                    text: TextSpan(
                      children: [
                        for (final e in cell.value as Set<String>) ...[
                          TextSpan(
                            text: e,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO:
                              },
                          ),
                          const TextSpan(
                            text: ', ',
                          ),
                        ]
                      ]..removeLast(),
                    ),
                    style: style,
                  ),
              kAlbum: () => HyperLink(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: cell.value as String,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO:
                            },
                        ),
                      ],
                    ),
                    style: style,
                  ),
              kGenres: () => HyperLink(
                    text: TextSpan(
                      children: [
                        for (final e in cell.value as Set<String>) ...[
                          TextSpan(
                            text: e,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO:
                              },
                          ),
                          const TextSpan(
                            text: ', ',
                          ),
                        ]
                      ]..removeLast(),
                    ),
                    style: style,
                  ),
              kYear: () => Text(
                    cell.value as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
            }[cell.columnName]!
                .call(),
          );
        },
      ).toList(),
    );
  }

  static const String kTrackNumber = '0';
  static const String kTitle = '1';
  static const String kArtists = '2';
  static const String kAlbum = '3';
  static const String kGenres = '4';
  static const String kYear = '5';
}
