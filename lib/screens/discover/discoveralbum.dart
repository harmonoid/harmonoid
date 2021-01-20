import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/discover.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/constants/constants.dart';


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
      openBuilder: (_, __) => DiscoverAlbum(
        album: this.album,
      ),
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
        openBuilder: (_, __) =>  DiscoverAlbum(
          album: this.album,
        ),
      ),
    );
  }
}

class DiscoverAlbum extends StatefulWidget {
  final Album album;
  DiscoverAlbum({Key key, @required this.album}) : super(key: key);
  DiscoverAlbumState createState() => DiscoverAlbumState();
}

class DiscoverAlbumState extends State<DiscoverAlbum> {
  Album album;

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9 ? '${durationSeconds - (minutes * 60)}' : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            brightness: Brightness.dark,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              iconSize: Theme.of(context).iconTheme.size,
              splashRadius: Theme.of(context).iconTheme.size - 8,
              onPressed: Navigator.of(context).pop,
            ),
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.width,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.album.albumName.split('(')[0].split('[')[0].split('-')[0],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              background: Image.network(
                widget.album.albumArtHigh,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate(
            <Widget>[
              SubHeader(Constants.STRING_ALBUM_VIEW_INFO_SUBHEADER),
              Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        widget.album.albumArtHigh,
                        height: 128,
                        width: 128,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 18),
                        width: MediaQuery.of(context).size.width - 16 - 16 - 128,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.album.albumName,
                              style: Theme.of(context).textTheme.headline2,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 2,
                            ),
                            Text(
                              widget.album.albumArtistName,
                              style: Theme.of(context).textTheme.headline5,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 2,
                            ),
                            Text(
                              '${widget.album.year  ?? 'Unknown Year'}',
                              style: Theme.of(context).textTheme.headline5,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SubHeader(Constants.STRING_ALBUM_VIEW_TRACKS_SUBHEADER),
              FadeFutureBuilder(
                future: () async => await discover.albumInfo(widget.album),
                initialWidgetBuilder: (BuildContext context) => FakeLinearProgressIndicator(
                  label: '',
                  duration: Duration(seconds: 10),
                  width: 96.0,
                  margin: EdgeInsets.only(top: 0.0),
                ),
                finalWidgetBuilder: (BuildContext context, Object object) {
                  List<Widget> trackWidgets = <Widget>[];
                  (object as List<Track>).forEach((Track track) => trackWidgets.add(
                    ListTile(
                      onTap: () {},
                      title: Text(track.trackName),
                      subtitle: Text(track.trackArtistNames.join(', ')),
                      leading: CircleAvatar(
                        child: Text('${track.trackNumber ?? 1}'),
                        backgroundImage: NetworkImage(widget.album.albumArtLow),
                      ),
                      trailing: Text(this._getDurationString(track.trackDuration)),
                    ),
                  ));
                  return Column(children: trackWidgets);
                },
                errorWidgetBuilder: (_, exception) => NetworkExceptionWidget(
                  exception: exception,
                  margin: EdgeInsets.only(top: 8.0),
                ),
                transitionDuration: Duration(milliseconds: 200),
              )
            ],
          )),
        ],
      ),
    );
  }
}
