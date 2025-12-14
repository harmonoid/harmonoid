import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/now_playing/now_playing_playlist_item.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/slide_on_enter.dart';
import 'package:harmonoid/utils/widgets.dart';

class DesktopNowPlayingPlaylist extends StatefulWidget {
  const DesktopNowPlayingPlaylist({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      useRootNavigator: true,
      // NOTE: The default barrier color. I have no fucking idea why this isn't available in Flutter's [ThemeData].
      barrierColor: Colors.black54,
      builder: (ctx) => const SlideOnEnter(
        child: Center(
          child: DesktopNowPlayingPlaylist(),
        ),
      ),
    );
  }

  @override
  State<DesktopNowPlayingPlaylist> createState() => _DesktopNowPlayingPlaylistState();
}

class _DesktopNowPlayingPlaylistState extends State<DesktopNowPlayingPlaylist> with ScrollControllerMixin {
  final _scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.track;
  late final ScrollController _scrollController = getScrollController(
    'desktop-now-playing-playlist',
    initialScrollOffset: () {
      final index = MediaPlayer.instance.state.index;
      final mixOffset = MediaPlayer.instance.state.mixOffset;
      // If current track is after mix, add 1 to account for mix header in the list
      final adjustedIndex = mixOffset != null && index >= mixOffset ? index + 1 : index;
      return adjustedIndex * _scrollViewBuilderHelperData.itemHeight;
    }(),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        return Container(
          width: kDesktopCenteredLayoutWidth,
          height: kDesktopCenteredLayoutWidth * 3.0 / 4.0,
          margin: const EdgeInsets.all(32.0),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localization.instance.NOW_PLAYING,
                        style: Theme.of(context).dialogTheme.titleTextStyle,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        mediaPlayer.state.playables.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', mediaPlayer.state.playables.length.toString()),
                        style: Theme.of(context).dialogTheme.contentTextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const Divider(height: 1.0),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      onReorder: (from, to) {
                        if (from != to) {
                          if (mediaPlayer.state.mixOffset != null) {
                            final mixOffset = mediaPlayer.state.mixOffset!;
                            if (from == mixOffset) return;
                            if (from > mixOffset) from--;
                            if (to > mixOffset) to--;
                          }
                          mediaPlayer.move(from, to);
                        }
                      },
                      scrollController: _scrollController,
                      itemCount: mediaPlayer.state.playables.length + 1,
                      itemExtent: _scrollViewBuilderHelperData.itemHeight,
                      itemBuilder: (context, listIndex) {
                        if ((mediaPlayer.state.mixOffset == null && listIndex == mediaPlayer.state.playables.length) ||
                            (mediaPlayer.state.mixOffset != null && listIndex == mediaPlayer.state.mixOffset!)) {
                          return Column(
                            key: const ValueKey('Mix'),
                            children: [
                              SubHeader(
                                Localization.instance.MIX,
                                height: _scrollViewBuilderHelperData.itemHeight - 1.0,
                                leading: const Icon(Icons.shuffle),
                                trailing: Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Switch(
                                      value: mediaPlayer.state.mixOffset != null,
                                      onChanged: (value) => mediaPlayer.mixOrUnmix(),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1.0, thickness: 1.0),
                            ],
                          );
                        }
                        if (mediaPlayer.state.mixOffset != null) {
                          if (listIndex > mediaPlayer.state.mixOffset!) {
                            final playableIndex = listIndex - 1;
                            return NowPlayingPlaylistItem(
                              key: ValueKey((playableIndex, mediaPlayer.state.playables[playableIndex])),
                              listIndex: listIndex,
                              playableIndex: playableIndex,
                              width: _scrollViewBuilderHelperData.itemWidth,
                              height: _scrollViewBuilderHelperData.itemHeight,
                            );
                          }
                        }

                        return NowPlayingPlaylistItem(
                          key: ValueKey((listIndex, mediaPlayer.state.playables[listIndex])),
                          listIndex: listIndex,
                          playableIndex: listIndex,
                          width: _scrollViewBuilderHelperData.itemWidth,
                          height: _scrollViewBuilderHelperData.itemHeight,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
