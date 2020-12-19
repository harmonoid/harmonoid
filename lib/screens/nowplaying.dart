import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/appstate.dart';
import 'package:harmonoid/constants/constants.dart';


class NowPlaying extends StatefulWidget {
  NowPlaying({Key key}) : super(key: key);
  NowPlayingState createState() => NowPlayingState();
}


class NowPlayingState extends State<NowPlaying> {

  Track _track = new Track();

  @override
  void initState() {
    super.initState();
    AppState.setNowPlaying = (List<Track> tracks, int index) async {
      this.setState(() {
        this._track = tracks[index];
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedColor: Theme.of(context).cardColor,
      closedElevation: 2,
      closedBuilder: (_, __) => Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 8, right: 8),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: 64,
              padding: EdgeInsets.all(8.0),
              child: this._track.albumArtId != null ? CircleAvatar(
                backgroundImage: FileImage(collection.getAlbumArt(this._track.albumArtId)),
                child: Text('${this._track.trackNumber}'),
              ) : CircleAvatar(
                child: Icon(Icons.music_note),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      this._track.trackName ?? Constants.STRING_NOW_PLAYING_NOT_PLAYING_TITLE,
                      style: Theme.of(context).textTheme.headline2,
                      maxLines: 1,
                    ),
                    Text(
                      this._track.artistNames == null ? Constants.STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE : this._track.artistNames.join(', '),
                      style: Theme.of(context).textTheme.headline4,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 64,
              width: 64,
              padding: EdgeInsets.all(0.0),
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  tooltip: Constants.STRING_PLAY,
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.pause),
                  onPressed: () {},
                  iconSize: Theme.of(context).iconTheme.size,
                  color: Theme.of(context).iconTheme.color,
                  splashRadius: Theme.of(context).iconTheme.size - 4,
                ),
              ),
            ),
          ],
        ),
      ),
      openBuilder: (_, __) => Scaffold(floatingActionButton: FloatingActionButton(child: Icon(Icons.close), onPressed: Navigator.of(context).pop,) ,body: Center(child: Text('Coming Soon ...'))),
    );
  }
}