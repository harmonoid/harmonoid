import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_header.dart';
import 'package:harmonoid/features/media_library/media_library_menus.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_header.dart';
import 'package:harmonoid/features/media_library/state/media_library_scroll_view_builder_data_provider.dart';
import 'package:harmonoid/features/media_library/tracks/models/track_view_type.dart';
import 'package:harmonoid/features/media_library/tracks/track_grid_item.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class TracksGrid extends StatefulWidget {
  final List<Track> tracks;

  const TracksGrid({
    super.key,
    required this.tracks,
  });

  @override
  State<TracksGrid> createState() => TracksGridState();
}

class TracksGridState extends State<TracksGrid> {
  late final ValueNotifier<bool> _itemSelectionInvoked = ValueNotifier(mediaLibrarySelectedTracks.value.isNotEmpty);

  double get headerHeight {
    if (isDesktop) {
      return kDesktopHeaderHeight;
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return kMobileHeaderHeight;
    }
    throw UnimplementedError();
  }

  Widget headerBuilder(BuildContext context, int i, double h) {
    if (isDesktop) {
      return const DesktopMediaLibraryHeader(key: ValueKey(''));
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return const MobileMediaLibraryHeader(key: ValueKey(''));
    }
    throw UnimplementedError();
  }

  @override
  void dispose() {
    _itemSelectionInvoked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollViewBuilderHelperData = MediaLibraryScrollViewBuilderDataProvider(context).track;

    return ScrollViewBuilder(
      key: const PageStorageKey(TrackViewType.grid),
      margin: margin,
      span: scrollViewBuilderHelperData.span,
      headerCount: 1,
      headerBuilder: headerBuilder,
      headerHeight: headerHeight,
      itemCounts: [widget.tracks.length],
      itemBuilder: (context, _, index, width, height) {
        final track = widget.tracks[index];
        return TrackGridItem(
          key: track.scrollViewBuilderKey,
          track: track,
          width: width,
          height: height,
          popupMenuBuilder: () => TrackMenuProvider(context, track).getPopupMenuItems(),
          onItemPressed: () {
            if (Configuration.instance.mediaLibraryAddPlaylistToNowPlaying) {
              MediaPlayer.instance.open(widget.tracks.map((e) => e.toPlayable()), index: index);
            } else {
              MediaPlayer.instance.open([track.toPlayable()]);
            }
          },
          onPopupMenuItemSelected: (result) async {
            await TrackMenuProvider(context, track).handlePopupMenuAction(result);
          },
          isItemSelected: () => mediaLibrarySelectedTracks.value.contains(track),
          onItemSelected: (value) {
            if (value) {
              mediaLibrarySelectedTracks.value = {...mediaLibrarySelectedTracks.value, track};
            } else {
              mediaLibrarySelectedTracks.value = mediaLibrarySelectedTracks.value.difference({track});
            }
          },
          itemSelectionChangeNotifier: mediaLibrarySelectedTracks,
          itemSelectionInvoked: _itemSelectionInvoked,
        );
      },
      itemWidth: scrollViewBuilderHelperData.itemWidth,
      itemHeight: scrollViewBuilderHelperData.itemHeight,
      displayLabel: true,
      labelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
      padding: MediaLibraryScrollViewBuilderDataProvider(context).padding,
    );
  }
}
