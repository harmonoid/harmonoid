import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/language/constants.dart';


class CollectionAlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;
  CollectionAlbumTile({Key key, @required this.album, @required this.height, @required this.width}) : super(key: key);

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
            Image.file(
              collection.getAlbumArt(this.album),
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
                      '${this.album.albumArtistName}\n(${this.album.year  ?? 'Unknown Year'})',
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
      openBuilder: (_, __) => CollectionAlbum(
        album: this.album,
      ),
    );
  }
}


class LeadingCollectionALbumTile extends StatelessWidget {
  final double height;
  LeadingCollectionALbumTile({Key key, @required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8.0),
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
              Image.file(
                collection.getAlbumArt(collection.lastAlbum),
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
                      collection.lastAlbum.albumName,
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    Text(
                      collection.lastAlbum.albumArtistName,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                    Text(
                      '(${collection.lastAlbum.year  ?? 'Unknown Year'})',
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
        openBuilder: (_, __) => CollectionAlbum(
          album: collection.lastAlbum,
        ),
      ),
    );
  }
}


class CollectionAlbum extends StatefulWidget {
  final Album album;
  CollectionAlbum({Key key, @required this.album}) : super(key: key);
  CollectionAlbumState createState() => CollectionAlbumState();
}

class CollectionAlbumState extends State<CollectionAlbum> {
  Album album;
  List<Widget> children = new List<Widget>();
  bool _init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this.album = widget.album;
      this._refresh();
    }
    this._init = false;
  }

  void _refresh() {
    this.children = <Widget>[];
    for (int index = 0; index < this.album.tracks.length; index++) {
      Track track = this.album.tracks[index];
      this.children.add(
        new Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: new Material(
            color: Colors.transparent,
            child: new ListTile(
              onTap: () async {
                await Playback.play(
                  index: index,
                  tracks: this.album.tracks
                );
              },
              title: Text(track.trackName),
              subtitle: Text(track.trackArtistNames.join(', ')),
              leading: CircleAvatar(
                child: Text('${track.trackNumber ?? 1}'),
                backgroundImage: FileImage(collection.getAlbumArt(widget.album)),
              ),
              trailing: PopupMenuButton(
                color: Theme.of(context).appBarTheme.color,
                elevation: 2,
                onSelected: (index) {
                  switch(index) {
                    case 0: {
                      showDialog(
                        context: context,
                        builder: (subContext) => AlertDialog(
                          title: Text(
                            Constants.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                            style: Theme.of(subContext).textTheme.headline1,
                          ),
                          content: Text(
                            Constants.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                            style: Theme.of(subContext).textTheme.headline5,
                          ),
                          actions: [
                            MaterialButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () async {
                                await collection.delete(track);
                                this._refresh();
                                Navigator.of(subContext).pop();
                                if (this.album.tracks.length == 0) {
                                  Navigator.of(context).pop();
                                  States.refreshCollectionMusic?.call();
                                  States.refreshCollectionSearch?.call();
                                }
                              },
                              child: Text(Constants.STRING_YES),
                            ),
                            MaterialButton(
                                  textColor: Theme.of(context).primaryColor,
                              onPressed: Navigator.of(subContext).pop,
                              child: Text(Constants.STRING_NO),
                            ),
                          ],
                        ),
                      );
                    }
                    break;
                    case 1: {
                      Share.shareFiles(
                        [track.filePath],
                        subject: '${track.trackName} - ${track.albumName}. Shared using Harmonoid!',
                      );
                    }
                    break;
                    case 2: {
                      showDialog(
                        context: context,
                        builder: (subContext) => AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          actionsPadding: EdgeInsets.zero,
                          title: Text(
                            Constants.STRING_PLAYLIST_ADD_DIALOG_TITLE,
                            style: Theme.of(subContext).textTheme.headline1,
                          ),
                          content: Container(
                            height: 280,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 24, top: 8, bottom: 16),
                                  child: Text(
                                    Constants.STRING_PLAYLIST_ADD_DIALOG_BODY,
                                    style: Theme.of(subContext).textTheme.headline5,
                                  ),
                                ),
                                Container(
                                  height: 236,
                                  width: 280,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                                      bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                                    )
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: collection.playlists.length,
                                    itemBuilder: (BuildContext context, int playlistIndex) => ListTile(
                                      title: Text(collection.playlists[playlistIndex].playlistName, style: Theme.of(context).textTheme.headline2),
                                      leading: Icon(
                                        Icons.queue_music,
                                        size: Theme.of(context).iconTheme.size,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                                      onTap: () async {
                                        await collection.playlistAddTrack(
                                        collection.playlists[playlistIndex],
                                        track,
                                        );
                                        Navigator.of(subContext).pop();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            MaterialButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: Navigator.of(subContext).pop,
                              child: Text(Constants.STRING_CANCEL),
                            ),
                          ],
                        ),
                      );
                    }
                    break;
                  }
                },
                icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color, size: Theme.of(context).iconTheme.size),
                tooltip: Constants.STRING_OPTIONS,
                itemBuilder: (_) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 0,
                    child: Text(Constants.STRING_DELETE),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(Constants.STRING_SHARE),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(Constants.STRING_ADD_TO_PLAYLIST),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
         value: SystemUiOverlayStyle.light,                
         child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.file(
                  collection.getAlbumArt(widget.album),
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  filterQuality: FilterQuality.low,
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
                      ]
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
                          ]
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).cardColor,
                      margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8.0),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.file(
                              collection.getAlbumArt(widget.album),
                              height: 140,
                              width: 140,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.low,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 18),
                              width: MediaQuery.of(context).size.width - 16 - 16 - 140,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    this.album.albumName,
                                    style: Theme.of(context).textTheme.headline2,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                  ),
                                  Divider(
                                    color: Colors.transparent,
                                    height: 2,
                                  ),
                                  Text(
                                    this.album.albumArtistName,
                                    style: Theme.of(context).textTheme.headline5,
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                  ),
                                  Divider(
                                    color: Colors.transparent,
                                    height: 2,
                                  ),
                                  Text(
                                    '${this.album.year  ?? 'Unknown Year'}',
                                    style: Theme.of(context).textTheme.headline5,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                  ),
                                  Divider(
                                    color: Colors.transparent,
                                    height: 2,
                                  ),
                                  Text(
                                    '${this.album.tracks.length}' + ' '+ Constants.STRING_TRACK.toLowerCase(),
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
                    /* 👌
                    Positioned(
                      top: 0.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              iconSize: Theme.of(context).iconTheme.size,
                              splashRadius: Theme.of(context).iconTheme.size - 8,
                              onPressed: Navigator.of(context).pop,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              iconSize: Theme.of(context).iconTheme.size,
                              splashRadius: Theme.of(context).iconTheme.size - 8,
                              onPressed: () => showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  title: Text(
                                    Constants.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_HEADER,
                                    style: Theme.of(subContext).textTheme.headline1,
                                  ),
                                  content: Text(
                                    Constants.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_BODY,
                                    style: Theme.of(subContext).textTheme.headline5,
                                  ),
                                  actions: [
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        Navigator.of(subContext).pop();
                                        await collection.delete(widget.album);
                                        Navigator.of(context).pop();
                                        States.refreshCollectionMusic?.call();
                                        States.refreshCollectionSearch?.call();
                                      },
                                      child: Text(Constants.STRING_YES),
                                    ),
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: Navigator.of(subContext).pop,
                                      child: Text(Constants.STRING_NO),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    */
                  ],
                ),
                SubHeader(Constants.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER),
              ] + this.children,
            ),
          ],
        ),
      )
    );
  }
}
