import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/scripts/collection.dart';


class DiscoverAlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;
  DiscoverAlbumTile({Key key, @required this.album, @required this.height, @required this.width}) : super(key: key);

  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedElevation: 2,
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (_, __) => Container(
        height: this.height,
        width: this.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              this.album.albumArtHigh,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.low,
              height: this.width,
              width: this.width,
            ),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              height: this.height - this.width,
              width: this.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      this.album.albumName,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '${this.album.albumArtistName}\n(${this.album.year ?? 'Unknown Year'})',
                      style: Theme.of(context).textTheme.headline5,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      openBuilder: (_, __) => Container(),
    );
  }
}


class LeadingDiscoverAlbumTile extends StatelessWidget {
  final double height;
  final Album album;
  LeadingDiscoverAlbumTile({Key key, @required this.height, @required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 400),
        closedElevation: 2,
        closedColor: Theme.of(context).cardColor,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        closedBuilder: (_, __) => Container(
          height: this.height,
          width: MediaQuery.of(context).size.width - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                this.album.albumArtHigh,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
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
                      this.album.albumName,
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    Text(
                      this.album.albumArtistName,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                    Text(
                      '(${this.album.year  ?? 'Unknown Year'})',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        openBuilder: (_, __) => Container(),
      ),
    );
  }
}
