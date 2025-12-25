import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';

class TracksTable extends StatefulWidget {
  final List<Track> tracks;
  final WidgetBuilder? headerBuilder;
  final ScrollPhysics? physics;
  final DesktopOnColumnResize? desktopOnColumnResize;
  final bool mobileSliverList;
  final bool mobileDisplayLabel;
  const TracksTable({
    super.key,
    required this.tracks,
    this.headerBuilder,
    this.physics,
    this.desktopOnColumnResize,
    this.mobileSliverList = false,
    this.mobileDisplayLabel = false,
  });

  @override
  State<TracksTable> createState() => _TracksTableState();
}

class _TracksTableState extends State<TracksTable> {
  List<double> _desktopColumnWidths = Configuration.instance.desktopMediaLibraryTracksScreenColumnWidths;

  WidgetBuilder? get _buildFooter => isDesktop
      ? null
      : (BuildContext context) {
          return const SizedBox(
            key: ValueKey(''),
            height: kMobileNowPlayingBarHeight,
          );
        };

  @override
  Widget build(BuildContext context) {
    final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.track;

    final columns = [
      Localization.instance.TITLE,
      Localization.instance.ARTISTS,
      Localization.instance.ALBUM,
      Localization.instance.GENRES,
      Localization.instance.YEAR,
    ];

    final width = MediaQuery.sizeOf(context).width - 2 * ListItemTableState.kDesktopRowHeight;
    if (_desktopColumnWidths.length != columns.length) {
      _desktopColumnWidths = [width * 5 / 17, width * 4 / 17, width * 3 / 17, width * 3 / 17, width * 2 / 17];
    }

    return ListItemTable(
      headerBuilder: widget.headerBuilder,
      footerBuilder: _buildFooter,
      columns: columns,
      itemCount: widget.tracks.length,
      itemBuilder: (context, i) => ListItemData(
        key: widget.tracks[i].scrollViewBuilderKey,
        children: [
          widget.tracks[i].toTitleTappableText(),
          if (isDesktop) ...[
            widget.tracks[i].toArtistsTappableText(context),
            widget.tracks[i].toAlbumTappableText(context),
            widget.tracks[i].toGenresTappableText(context),
            widget.tracks[i].toYearTappableText(),
          ] else
            widget.tracks[i].toSubtitleTappableText(),
        ],
      ),
      leadingBuilder: (context, i) => Image(
        width: linearTileHeight,
        height: linearTileHeight,
        image: cover(
          item: widget.tracks[i],
          cacheHeight: linearTileHeight.toInt(),
        ),
        fit: BoxFit.cover,
      ),
      popupMenuBuilder: (context, i) => TrackMenuProvider(context, widget.tracks[i]).getPopupMenuItems(),
      onItemPressed: (context, i) {
        if (Configuration.instance.mediaLibraryAddPlaylistToNowPlaying) {
          MediaPlayer.instance.open(widget.tracks.map((e) => e.toPlayable()), index: i);
        } else {
          MediaPlayer.instance.open([widget.tracks[i].toPlayable()]);
        }
      },
      onPopupMenuItemSelected: (context, i, result) async {
        await TrackMenuProvider(context, widget.tracks[i]).handlePopupMenuAction(result);
      },
      physics: widget.physics,
      desktopBorders: true,
      desktopLeadingColumn: const Icon(Icons.album),
      desktopColumnWidths: _desktopColumnWidths,
      desktopOnColumnResize: widget.desktopOnColumnResize,
      mobileHeaderHeight: mediaLibraryScrollViewBuilderPadding.top + kMobileHeaderHeight,
      mobileSliverList: widget.mobileSliverList,
      mobileDisplayLabel: widget.mobileDisplayLabel,
      mobileLabelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
      showItemSelection: isDesktop || mediaLibrarySelectedTracks.value.isNotEmpty,
      isItemSelected: (i) => mediaLibrarySelectedTracks.value.contains(widget.tracks[i]),
      onItemSelected: (context, i, value) {
        if (value) {
          mediaLibrarySelectedTracks.value = {...mediaLibrarySelectedTracks.value, widget.tracks[i]};
        } else {
          mediaLibrarySelectedTracks.value = mediaLibrarySelectedTracks.value.difference({widget.tracks[i]});
        }
      },
      itemSelectionChangeNotifier: mediaLibrarySelectedTracks,
    );
  }
}
