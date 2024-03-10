import 'package:flutter/material.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class ArtistItem extends StatelessWidget {
  final Artist artist;
  final double width;
  final double height;
  ArtistItem({
    super.key,
    required this.artist,
    required this.width,
    required this.height,
  });

  late final title = artist.artist.isNotEmpty ? artist.artist : kDefaultArtist;

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: const CircleBorder(),
            child: Container(
              width: width,
              height: width,
              padding: const EdgeInsets.all(4.0),
              child: ClipOval(
                child: Material(
                  child: InkWell(
                    onTap: () {
                      // TODO:
                    },
                    child: ScaleOnHover(
                      child: Ink.image(
                        width: width,
                        height: width,
                        fit: BoxFit.cover,
                        image: cover(
                          item: artist,
                          cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: width,
              alignment: Alignment.center,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
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
