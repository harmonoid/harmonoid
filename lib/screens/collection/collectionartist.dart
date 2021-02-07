import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';

/* TODO: Make these dummy cards actually work. */

class LeadingCollectionArtistTile extends StatelessWidget {
  final double height;
  const LeadingCollectionArtistTile({Key key, @required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 8.0),
      child: Container(
        height: this.height,
        width: MediaQuery.of(context).size.width - 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: ClipOval(
                child: Image.file(
                  collection.getAlbumArt(collection.artists.first.tracks.last),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.low,
                  height: this.height - 24,
                  width: this.height - 24,
                ),
              ),
              height: this.height,
              width: this.height,
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              width: MediaQuery.of(context).size.width - 32 - this.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    collection.artists.first.artistName,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const CollectionArtistTile({Key key, @required this.height, @required this.width, @required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Container(
        height: this.height - 54,
        width: this.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: ClipOval(
                child: Image.file(
                  collection.getAlbumArt(this.artist.tracks.last),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.low,
                  height: this.width - 24,
                  width: this.width - 24,
                ),
              ),
              height: this.width,
              width: this.width,
            ),
            Container(
              height: (this.height - 54) - this.width,
              width: this.width,
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(8.0),
              child: Text(
                this.artist.artistName,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.left,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
