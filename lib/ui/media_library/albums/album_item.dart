import 'package:flutter/material.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class AlbumItem extends StatelessWidget {
  final Album album;
  final double width;
  final double height;
  AlbumItem({
    super.key,
    required this.album,
    required this.width,
    required this.height,
  });

  late final title = album.album.isNotEmpty ? album.album : kDefaultAlbum;
  late final subtitle = [
    if (album.albumArtist.isNotEmpty) album.albumArtist,
    if (album.year != 0) album.year.toString(),
  ].join(' • ');

  Widget _buildDesktopLayout(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO:
        },
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: width,
                child: ScaleOnHover(
                  child: Ink.image(
                    width: width,
                    height: width,
                    fit: BoxFit.cover,
                    image: cover(
                      item: album,
                      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
