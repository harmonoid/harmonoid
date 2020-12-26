import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:share/share.dart';

import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/constants/constants.dart';


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
              collection.getAlbumArt(this.album.albumArtId),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.low,
              height: this.width,
              width: this.width,
            ),
            Container(
              margin: EdgeInsets.only(left: 2, right: 2),
              child: Column(
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text(
                    this.album.albumName,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text(
                    this.album.artistNames.length < 2 ? 
                    this.album.artistNames.join(', ') : 
                    this.album.artistNames.sublist(0, 2).join(', '),
                    style: Theme.of(context).textTheme.headline4,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '(${this.album.year})',
                    style: Theme.of(context).textTheme.headline4,
                    maxLines: 1,
                    textAlign: TextAlign.center,
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
      this.refresh();
    }
    this._init = false;
  }

  void refresh() {
    this.children = <Widget>[];
    for (int index = 0; index < this.album.tracks.length; index++) {
      Track track = this.album.tracks[index];
      this.children.add(
        new ListTile(
          onTap: () async {
            await Playback.play(
              index: index,
              tracks: this.album.tracks
            );
          },
          title: Text(track.trackName),
          subtitle: Text(track.artistNames.join(', ')),
          leading: CircleAvatar(
            child: Text(track.trackNumber),
            backgroundImage: FileImage(collection.getAlbumArt(widget.album.albumArtId)),
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
                        style: Theme.of(subContext).textTheme.headline4,
                      ),
                      actions: [
                        MaterialButton(
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () async {
                            await collection.delete(track);
                            this.refresh();
                            Navigator.of(subContext).pop();
                            if (this.album.tracks.length == 0) {
                              Navigator.of(context).pop();
                              if (States.musicCollectionSearchRefresh != null) States.musicCollectionSearchRefresh();
                              if (States.musicCollectionRefresh != null) States.musicCollectionRefresh(States.musicCollectionCurrentTab);
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
                                style: Theme.of(subContext).textTheme.headline4,
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
              PopupMenuItem(
                value: 3,
                child: Text(Constants.STRING_SAVE_TO_DOWNLOADS),
              ),
            ],
          ),
        ),
      );
    }
    this.setState(() {});
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
              splashRadius: Theme.of(context).iconTheme.size - 4,
              onPressed: Navigator.of(context).pop,
            ),
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                iconSize: Theme.of(context).iconTheme.size,
                splashRadius: Theme.of(context).iconTheme.size - 4,
                onPressed: () => showDialog(
                  context: context,
                  builder: (subContext) => AlertDialog(
                    title: Text(
                      Constants.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_HEADER,
                      style: Theme.of(subContext).textTheme.headline1,
                    ),
                    content: Text(
                      Constants.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_BODY,
                      style: Theme.of(subContext).textTheme.headline4,
                    ),
                    actions: [
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          Navigator.of(subContext).pop();
                          await collection.delete(widget.album);
                          Navigator.of(context).pop();
                          if (States.musicCollectionSearchRefresh != null) States.musicCollectionSearchRefresh();
                          if (States.musicCollectionRefresh != null) States.musicCollectionRefresh(States.musicCollectionCurrentTab);
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
            expandedHeight: MediaQuery.of(context).size.width,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                this.album.albumName.split('(')[0].split('[')[0].split('-')[0],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              background: Image.file(
                collection.getAlbumArt(widget.album.albumArtId),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate(
            <Widget>[
              SubHeader(Constants.STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER),
              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.file(
                        collection.getAlbumArt(widget.album.albumArtId),
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
                              this.album.artistNames.join(', '),
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 2,
                            ),
                            Text(
                              '${this.album.year}',
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 2,
                            ),
                            Text(
                              '${this.album.tracks.length}' + ' '+ Constants.STRING_TRACK.toLowerCase(),
                              style: Theme.of(context).textTheme.headline4,
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
              SubHeader(Constants.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER),
            ] + this.children
          )),
        ],
      ),
    );
  }
}
