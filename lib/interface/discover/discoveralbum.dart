import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/discover.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/interface/discover/discovertrack.dart';

class DiscoverAlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;
  DiscoverAlbumTile(
      {Key? key,
      required this.album,
      required this.height,
      required this.width})
      : super(key: key);

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
              this.album.albumArtHigh!,
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
                      this.album.albumName!,
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
      openBuilder: (_, __) => DiscoverAlbum(
        album: this.album,
      ),
    );
  }
}

class LeadingDiscoverAlbumTile extends StatelessWidget {
  final double height;
  final Album album;
  LeadingDiscoverAlbumTile(
      {Key? key, required this.height, required this.album})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
                this.album.albumArtHigh!,
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
                      this.album.albumName!,
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    Text(
                      this.album.albumArtistName!,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                    Text(
                      '(${this.album.year ?? 'Unknown Year'})',
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
        openBuilder: (_, __) => DiscoverAlbum(
          album: this.album,
        ),
      ),
    );
  }
}

class DiscoverAlbum extends StatefulWidget {
  final Album album;
  DiscoverAlbum({Key? key, required this.album}) : super(key: key);
  DiscoverAlbumState createState() => DiscoverAlbumState();
}

class DiscoverAlbumState extends State<DiscoverAlbum> {
  late Album album;

  @override
  Widget build(BuildContext context) {
    double albumArtSize = MediaQuery.of(context).size.width;
    if (Platform.isWindows || Platform.isLinux) {
      albumArtSize = albumArtSize / 5;
    }
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Stack(
            alignment: () {
              if (Platform.isAndroid) {
                return Alignment.bottomCenter;
              } else {
                return Alignment.topCenter;
              }
            }(),
            children: [
              Image.network(
                widget.album.albumArtHigh!,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
                height: albumArtSize,
                width: albumArtSize,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.4,
                      1.0,
                    ],
                    colors: [
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ],
          ),
          ListView(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: albumArtSize * 1.75,
                    height: albumArtSize * 1.75,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0.3,
                            0.9,
                          ],
                          colors: [
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor,
                          ]),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    color: Theme.of(context).cardColor,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 0, bottom: 8.0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            widget.album.albumArtHigh!,
                            height: 140,
                            width: 140,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.low,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 16.0, right: 16.0),
                            width: MediaQuery.of(context).size.width -
                                16 -
                                16 -
                                140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.album.albumName!,
                                  style: Theme.of(context).textTheme.headline2,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                ),
                                Divider(
                                  color: Colors.transparent,
                                  height: 2,
                                ),
                                Text(
                                  widget.album.albumArtistName!,
                                  style: Theme.of(context).textTheme.headline5,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                ),
                                Divider(
                                  color: Colors.transparent,
                                  height: 2,
                                ),
                                Text(
                                  '${widget.album.year ?? 'Unknown Year'}',
                                  style: Theme.of(context).textTheme.headline5,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                ),
                                Divider(
                                  color: Colors.transparent,
                                  height: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SubHeader(language!.STRING_ALBUM_VIEW_TRACKS_SUBHEADER),
              FadeFutureBuilder(
                future: () async => await discover.albumInfo(widget.album),
                initialWidgetBuilder: (BuildContext context) => Center(
                  child: CircularProgressIndicator(),
                ),
                finalWidgetBuilder: (BuildContext context, Object? object) {
                  List<Widget> trackWidgets = <Widget>[];
                  (object as List<Track>).forEach((Track track) {
                    track.albumArtLow = widget.album.albumArtLow;
                    trackWidgets.add(
                      DiscoverTrackTile(track: track),
                    );
                  });
                  return Column(children: trackWidgets);
                },
                errorWidgetBuilder: (_, exception) => ExceptionWidget(
                  margin: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  height: 156.0,
                  assetImage: 'assets/images/exception.jpg',
                  title: language!.STRING_NO_INTERNET_TITLE,
                  subtitle: language!.STRING_NO_INTERNET_SUBTITLE,
                ),
                transitionDuration: Duration(milliseconds: 200),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
