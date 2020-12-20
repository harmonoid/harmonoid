import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/appstate.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionAlbumTile extends StatelessWidget {
  final Album album;
  CollectionAlbumTile({Key key, @required this.album}) : super(key: key);

  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedElevation: 2,
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (_, __) => Container(
        height: 246,
        width: 156,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              collection.getAlbumArt(this.album.albumArtId),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.low,
              height: 156,
              width: 156,
            ),
            Container(
              margin: EdgeInsets.only(left: 2, right: 2),
              child: Column(
                children: [
                  Divider(
                    color: Colors.transparent,
                    height: 4,
                  ),
                  Text(
                    this.album.albumName,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 4,
                    thickness: 4,
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
                  Divider(
                    color: Colors.transparent,
                    height: 4,
                    thickness: 4,
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
  double _flexibleSpaceBarTitlePosition = 16.0;
  ScrollController _scrollController = new ScrollController();
  bool _init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this.album = widget.album;
      this.refresh();
    }
    this._scrollController.addListener(() {
      if (16.0 + this._scrollController.offset * (72.0 - 16.0) / MediaQuery.of(context).size.width < 62.0) {
        this.setState(() => this._flexibleSpaceBarTitlePosition = 16.0 + this._scrollController.offset * (72.0 - 16.0) / MediaQuery.of(context).size.width);
      }
    });
    this._init = false;
  }

  @override
  void dispose() {
    this._scrollController.dispose();
    super.dispose();
  }

  void refresh() {
    this.children = <Widget>[];
    for (int index = 0; index < this.album.tracks.length; index++) {
      Track track = this.album.tracks[index];
      this.children.add(
        new ListTile(
          onTap: () {
            AppState.setNowPlaying(this.album.tracks, index);
          },
          title: Text(track.trackName),
          subtitle: Text(track.artistNames.join(', ')),
          leading: CircleAvatar(
            child: Text(track.trackNumber),
            backgroundImage: FileImage(collection.getAlbumArt(widget.album.albumArtId)),
          ),
          trailing: PopupMenuButton(
            color: Theme.of(context).cardColor,
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
                              if (AppState.musicCollectionSearchRefresh != null) AppState.musicCollectionSearchRefresh();
                              if (AppState.musicCollectionRefresh != null) AppState.musicCollectionRefresh(AppState.musicCollectionCurrentTab);
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
        controller: this._scrollController,
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
                          if (AppState.musicCollectionSearchRefresh != null) AppState.musicCollectionSearchRefresh();
                          if (AppState.musicCollectionRefresh != null) AppState.musicCollectionRefresh(AppState.musicCollectionCurrentTab);
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
            flexibleSpace: TweenAnimationBuilder(
              tween: Tween<double>(begin: 72.0, end: this._flexibleSpaceBarTitlePosition),
              child: Image.file(
                collection.getAlbumArt(widget.album.albumArtId),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
              ),
              duration: Duration.zero,
              builder: (_, value, child) => FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: value, bottom: 16.0),
                title: Text(
                  this.album.albumName.split('(')[0].split('[')[0].split('-')[0],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                background: child,
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
