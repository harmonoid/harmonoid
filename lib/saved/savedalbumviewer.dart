import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harmonoid/scripts/getsavedmusic.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:harmonoid/globals.dart';


class TrackElement extends StatelessWidget {

  final List<dynamic> albumTracks;
  final int index;
  final Map<String, dynamic> albumJson;
  TrackElement({Key key, @required this.index, @required this.albumTracks, @required this.albumJson}) : super(key: key);

  String trackDuration(int durationMilliseconds) {
    String trackDurationLabel;
    int durationSeconds = durationMilliseconds ~/ 1000;
    int minutes = durationSeconds ~/ 60;
    int seconds = durationSeconds - minutes * 60;
    if (seconds.toString().length == 2) {
      trackDurationLabel = minutes.toString() + ":" + seconds.toString();
    }
    else {
      trackDurationLabel = minutes.toString() + ":0" + seconds.toString();
    }
    return trackDurationLabel;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Text(this.albumTracks[this.index]['track_name'].split('(')[0].trim().split('-')[0].trim()),
      subtitle: Text(this.albumTracks[this.index]['track_artists'].join(', ')),
      leading: CircleAvatar(
        child: Text(
          this.albumTracks[this.index]['track_number'].toString(),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        backgroundImage: NetworkImage(this.albumJson['album_art_64']),
      ),
      trailing: Text(this.trackDuration(this.albumTracks[this.index]['track_duration'])),
    );
  }
}


class SavedAlbumViewer extends StatefulWidget {
  final Map<String, dynamic> albumJson;
  final File albumArt;

  SavedAlbumViewer({Key key, @required this.albumJson, @required this.albumArt}): super(key: key);
  _SavedAlbumViewer createState() => _SavedAlbumViewer();
}


class _SavedAlbumViewer extends State<SavedAlbumViewer> with SingleTickerProviderStateMixin {
  
  double _loaderShowing = 1.0;
  Animation<double> _searchResultOpacity;
  AnimationController _searchResultOpacityController;
  Color _accentColor = Colors.black87;

  List<Widget> _albumTracks = [
    Container(
      margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
      child: Text(
        Globals.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future<Color> getImageColor (ImageProvider imageProvider) async {
      final PaletteGenerator paletteGenerator = await PaletteGenerator
          .fromImageProvider(imageProvider);
      return paletteGenerator.dominantColor.color;
    }
    this.setState(() {
      (() async => this._accentColor = await getImageColor(NetworkImage(widget.albumJson['album_art_64'])))(); 
    });

    this._searchResultOpacityController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
      this.setState(() {});
    });
    this._searchResultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(this._searchResultOpacityController);

    (() async {
      List<dynamic> albumTracks = (await GetSavedMusic.tracks(widget.albumJson['album_id']))['tracks'];
      for (int index = 0; index < albumTracks.length; index++) {
        this._albumTracks.add(
          TrackElement(
            index: index,
            albumTracks: albumTracks,
            albumJson: widget.albumJson,
          ),
        );
      }
      this.setState(() {
        this._loaderShowing = 0.0;
        this._albumTracks.insertAll(0, 
          [
            Container(
              margin: EdgeInsets.only(left: 16, top: 24, bottom: 18),
              child: Text(
                Globals.STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Card(
              elevation: 1,
              margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      widget.albumArt,
                      height: 128,
                      width: 128,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 18),
                      width: MediaQuery.of(context).size.width - 16 - 16 - 128,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim(),
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                          Divider(
                            color: Colors.white,
                            height: 12,
                            thickness: 12,
                          ),
                          Divider(
                            color: Colors.white,
                            height: 2,
                            thickness: 2,
                          ),
                          Text(
                            widget.albumJson['album_artists'].join(', '),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                          Divider(
                            color: Colors.white,
                            height: 2,
                            thickness: 2,
                          ),
                          Text(
                            '${widget.albumJson['year']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                          Divider(
                            color: Colors.white,
                            height: 2,
                            thickness: 2,
                          ),
                          Text(
                            '${widget.albumJson['album_length']}' + ' '+ Globals.STRING_TRACK.toLowerCase(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
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
        ]
      );
      });
      this._searchResultOpacityController.forward();
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: this._accentColor,
            leading: Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 24,
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                splashRadius: 20,
                onPressed: () => Navigator.of(context).pop(),
              )
            ),
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.albumJson['album_name'].split('(')[0].trim().split('-')[0].trim()),
              background: Image.file(
                widget.albumArt,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          this._loaderShowing != 0.0 ?
          SliverFillRemaining(
            child: Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: this._loaderShowing,
                child: TweenAnimationBuilder(
                  onEnd: () => this.setState(() {
                    this._loaderShowing = 0.0;
                  }),
                  duration: Duration(seconds: 8),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.linear,
                  child: Text(Globals.STRING_ALBUM_VIEW_LOADER_LABEL, style: TextStyle(fontSize: 16, color: Colors.black87)),
                  builder: (context, value, child) => Container(
                    width: 148,
                    height: 36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        child,
                        LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent[400],),
                          backgroundColor: Colors.deepPurpleAccent[100],
                          value: value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          :
          SliverOpacity(
            opacity: this._searchResultOpacity.value,
            sliver: SliverList(
              delegate: SliverChildListDelegate(this._albumTracks),
            ),
          ),
        ],
      ),
    );
  }
}