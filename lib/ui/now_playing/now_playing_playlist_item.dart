import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingPlaylistItem extends StatelessWidget {
  final int index;
  final double width;
  final double height;
  const NowPlayingPlaylistItem({
    super.key,
    required this.index,
    required this.width,
    required this.height,
  });

  Widget _buildDesktopLayout(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        final playable = mediaPlayer.state.playables[index];
        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => mediaPlayer.jump(index),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: height * 2 + 8.0,
                          child: index == mediaPlayer.state.index
                              ? MusicAnimation(
                                  width: height / 2.0,
                                  height: height / 2.0,
                                )
                              : IgnorePointer(
                                  child: Text(
                                    '${index - mediaPlayer.state.index}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                        ),
                        const VerticalDivider(width: 1.0),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: height,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IgnorePointer(
                              child: Text(
                                playable.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1.0),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: height,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: HyperLink(
                              text: TextSpan(
                                children: [
                                  for (final artist in (playable.subtitle.isEmpty ? {''} : playable.subtitle)) ...[
                                    TextSpan(
                                      text: artist.isEmpty ? kDefaultArtist : artist,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          navigateToArtist(context, ArtistLookupKey(artist: artist));
                                        },
                                    ),
                                    const TextSpan(
                                      text: ', ',
                                    ),
                                  ]
                                ]..removeLast(),
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1.0),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
