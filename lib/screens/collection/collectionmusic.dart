import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/screens/collection/collectionalbum.dart';
import 'package:harmonoid/screens/collection/collectiontrack.dart';
import 'package:harmonoid/screens/collection/collectionplaylist.dart';
import 'package:harmonoid/screens/collection/collectionartist.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/language/constants.dart';


class CollectionMusic extends StatefulWidget {
  CollectionMusic({Key key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}


class CollectionMusicState extends State<CollectionMusic> with SingleTickerProviderStateMixin {
  int _elementsPerRow = 2;
  double _tileWidth;
  double _tileHeight;
  TabController _tabController;
  List<Widget> trackChildren = new List<Widget>();
  List<Widget> albumChildren = new List<Widget>();
  List<Widget> artistChildren = new List<Widget>();
  List<Widget> playlistChildren = new List<Widget>();
  TextEditingController _textFieldController = new TextEditingController();
  bool _init = true;

  void refreshAlbums() {
    this.albumChildren = tileGridListWidgets(
      context: context,
      tileHeight: this._tileHeight,
      tileWidth: this._tileWidth,
      elementsPerRow: this._elementsPerRow,
      subHeader: Constants.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
      leadingSubHeader: Constants.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
      widgetCount: collection.albums.length,
      leadingWidget: LeadingCollectionALbumTile(
        height: this._tileWidth,
      ),
      builder: (BuildContext context, int index) => CollectionAlbumTile(
        height: this._tileHeight,
        width: this._tileWidth,
        album: collection.albums[index],
      ),
    );
    this.setState(() {});
  }

  void refreshArtists() {
    this.artistChildren = tileGridListWidgets(
      context: context,
      tileHeight: this._tileHeight - 52.0,
      tileWidth: this._tileWidth - 52.0,
      elementsPerRow: this._elementsPerRow,
      subHeader: Constants.STRING_LOCAL_OTHER_SUBHEADER_ARTIST,
      leadingSubHeader: Constants.STRING_LOCAL_TOP_SUBHEADER_ARTIST,
      widgetCount: collection.artists.length,
      leadingWidget: LeadingCollectionArtistTile(
        height: this._tileWidth,
      ),
      builder: (BuildContext context, int index) => CollectionArtistTile(
        height: this._tileHeight,
        width: this._tileWidth,
        artist: collection.artists[index],
      ),
    );
    this.setState(() {});
  }

  void refreshTracks() {
    this.trackChildren = <Widget>[];
    this.trackChildren.addAll([
      SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_TRACK),
      LeadingCollectionTrackTile(),
      SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_TRACK)
    ]);
    for (int index = 0; index < collection.tracks.length; index++) {
      this.trackChildren.add(
        CollectionTrackTile(
          track: collection.tracks[index],
          index: index,
        ),
      );
    }
    this.setState(() {});
  }
  /* TODO: Separate this into another file. */
  void refreshPlaylists() {
    this.playlistChildren = <Widget>[];
    List<Widget> playlistChildren = <Widget>[];
    for (Playlist playlist in collection.playlists) {
      playlistChildren.add(
        new ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => CollectionPlaylist(
                  playlist: playlist,
                ),
              ),
            );
          },
          onLongPress: () => showDialog(
            context: context,
            builder: (subContext) => AlertDialog(
              title: Text(
                Constants.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER,
                style: Theme.of(subContext).textTheme.headline1,
              ),
              content: Text(
                Constants.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY,
                style: Theme.of(subContext).textTheme.headline5,
              ),
              actions: [
                MaterialButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    await collection.playlistRemove(playlist);
                    Navigator.of(subContext).pop();
                    this._refresh();
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
          leading: playlist.tracks.length != 0 ? CircleAvatar(
            backgroundImage: FileImage(collection.getAlbumArt(playlist.tracks.first.albumArtId)),
          ) : Icon(
            Icons.queue_music,
            size: Theme.of(context).iconTheme.size,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(playlist.playlistName),
          trailing: IconButton(
            onPressed: () => Playback.play(
              index: 0,
              tracks: playlist.tracks,
            ),
            icon: Icon(
              Icons.play_arrow,
              color: Theme.of(context).iconTheme.color,
            ),
            iconSize: Theme.of(context).iconTheme.size,
            splashRadius: Theme.of(context).iconTheme.size - 8,
          ),
        )
      );
    }
    playlistChildren = playlistChildren.reversed.toList();

    this.playlistChildren.addAll(
      [
        Container(
          margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          child: Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Constants.STRING_PLAYLISTS, style: Theme.of(context).textTheme.headline1),
                      Text(Constants.STRING_PLAYLISTS_SUBHEADER, style: Theme.of(context).textTheme.headline5),
                    ],
                  ),
                ),
                ExpansionTile(
                  maintainState: false,
                  childrenPadding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
                  leading: Icon(
                    Icons.queue_music,
                    size: Theme.of(context).iconTheme.size,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  trailing: Icon(
                    Icons.add,
                    size: Theme.of(context).iconTheme.size,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(Constants.STRING_PLAYLISTS_CREATE, style: Theme.of(context).textTheme.headline2),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: this._textFieldController,
                            cursorWidth: 1,
                            autofocus: true,
                            autocorrect: true,
                            onSubmitted: (String value) async {
                              if (value != '') {
                                FocusScope.of(context).unfocus();
                                await collection.playlistAdd(new Playlist(playlistName: value));
                                this._textFieldController.clear();
                                this._refresh();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: Constants.STRING_PLAYLISTS_TEXT_FIELD_LABEL,
                              hintText: Constants.STRING_PLAYLISTS_TEXT_FIELD_HINT,
                              labelStyle: TextStyle(color: Theme.of(context).accentColor),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 1)),
                              border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 1)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 1)),
                            ),
                          ),
                        ),
                        Container(
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () async {
                              if (this._textFieldController.text != '') {
                                FocusScope.of(context).unfocus();
                                await collection.playlistAdd(new Playlist(playlistName: this._textFieldController.text));
                                this._textFieldController.clear();
                                this._refresh();
                              }
                            },
                            icon: Icon(
                              Icons.check,
                              color: Theme.of(context).primaryColor,
                            ),
                            iconSize: 24,
                            splashRadius: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ] + playlistChildren,
            ),
          ),
        )
      ],
    );
    
    this.setState(() {});
  }

  void _refresh() {
    if (collection.albums.length != 0 && collection.tracks.length != 0 && collection.artists.length != 0) {
      this.refreshAlbums();
      this.refreshTracks();
      this.refreshArtists();
    }
    else {
      if (this._init) {
        Widget emptyMusicCollection = ExceptionWidget(
          margin: EdgeInsets.only(top: 96.0),
          height: this._tileWidth,
          assetImage: 'assets/images/albums.jpg',
          title: Constants.STRING_NO_COLLECTION_TITLE,
          subtitle: Constants.STRING_NO_COLLECTION_SUBTITLE,
        );
        this.albumChildren.add(emptyMusicCollection);
        this.trackChildren.add(emptyMusicCollection);
        this.artistChildren.add(emptyMusicCollection);
      }
    }
    this.refreshPlaylists();
  }

  @override
  void initState() {
    super.initState();
    States.refreshCollectionMusic = this._refresh;
    this._tabController = TabController(initialIndex: 0, length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
      this._tileWidth = (MediaQuery.of(context).size.width - 16 - (this._elementsPerRow - 1) * 8) / this._elementsPerRow;
      this._tileHeight = this._tileWidth * 242 / 156;
      this._refresh();
    }
    this._init = false;
  }

  @override
  void dispose() {
    States.refreshCollectionMusic = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                elevation: innerBoxIsScrolled ? 4.0 : 1.0,
                forceElevated: true,
                pinned: true,
                floating: true,
                snap: true,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
                  iconSize: Theme.of(context).iconTheme.size,
                  splashRadius: Theme.of(context).iconTheme.size - 8,
                  onPressed: () {},
                  tooltip: Constants.STRING_MENU,
                ),
                title: Text('Harmonoid'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 8,
                    tooltip: Constants.STRING_SEARCH_COLLECTION,
                    onPressed: () {
                      Navigator.of(context).pushNamed('collectionSearch');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 8,
                    tooltip: Constants.STRING_OPTIONS,
                    onPressed: () {},
                  ),
                ],
                bottom: TabBar(
                  controller: this._tabController,
                  indicatorColor: Theme.of(context).accentColor,
                  isScrollable: true,
                  onTap: (int index) {
                    /* TODO: Make this._refresh method efficient to re render only the focused tab. */
                  },
                  tabs: [
                    Tab(
                      child: Text(
                        Constants.STRING_ALBUM.toUpperCase(),
                      ),
                    ),
                    Tab(
                      child: Text(
                        Constants.STRING_TRACK.toUpperCase(),
                      ),
                    ),
                    Tab(
                      child: Text(
                        Constants.STRING_ARTIST.toUpperCase(),
                        )
                    ),
                    Tab(
                      child: Text(
                        Constants.STRING_PLAYLISTS.toUpperCase(),
                        )
                    ),
                  ],
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: this._tabController,
          children: <Widget>[
            Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverList(delegate: SliverChildListDelegate(this.albumChildren)),
                  ],
                );
              }
            ),
            Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverList(delegate: SliverChildListDelegate(this.trackChildren)),
                  ],
                );
              }
            ),
            Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverList(delegate: SliverChildListDelegate(this.artistChildren)),
                  ],
                );
              }
            ),
            Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverList(delegate: SliverChildListDelegate(this.playlistChildren)),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
