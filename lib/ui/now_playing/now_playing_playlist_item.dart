import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
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
                              : Text(
                                  '${index - mediaPlayer.state.index}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge,
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
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        final i = index - mediaPlayer.state.index;
        final playable = mediaPlayer.state.playables[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => mediaPlayer.jump(index),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 16.0),
                  Container(
                    width: 48.0,
                    height: 56.0,
                    alignment: Alignment.center,
                    child: index == mediaPlayer.state.index
                        ? const MusicAnimation(width: 20.0, height: 20.0)
                        : AutoSizeText(
                            '${i > 0 ? '+' : ''}$i',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18.0),
                          ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playable.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          playable.subtitle.isEmpty ? kDefaultArtist : playable.subtitle.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
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
