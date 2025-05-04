import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/now_playing/now_playing_playlist_item.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/slide_on_enter.dart';

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

class _DesktopNowPlayingPlaylistState extends State<DesktopNowPlayingPlaylist> {
  final _scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.track;
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: MediaPlayer.instance.state.index * _scrollViewBuilderHelperData.itemHeight,
  );

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) => Container(
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
                        mediaPlayer.move(from, to);
                      }
                    },
                    scrollController: _scrollController,
                    itemCount: mediaPlayer.state.playables.length,
                    itemExtent: _scrollViewBuilderHelperData.itemHeight,
                    itemBuilder: (context, index) => NowPlayingPlaylistItem(
                      key: ValueKey((index, mediaPlayer.state.playables[index])),
                      index: index,
                      width: _scrollViewBuilderHelperData.itemWidth,
                      height: _scrollViewBuilderHelperData.itemHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
