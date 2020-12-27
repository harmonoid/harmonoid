import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/screens/collection/collectionalbum.dart';
import 'package:harmonoid/screens/collection/collectiontrack.dart';
import 'package:harmonoid/screens/collection/collectionplaylist.dart';
import 'package:harmonoid/scripts/playback.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionMusicSearch extends StatefulWidget {
  CollectionMusicSearch({Key key}) : super(key: key);
  CollectionMusicSearchState createState() => CollectionMusicSearchState();
}


class CollectionMusicSearchState extends State<CollectionMusicSearch> {
  int _elementsPerRow = 2;
  bool _init = true;
  double tileWidth;
  double tileHeight;
  List<Widget> _albumResults = new List<Widget>();
  List<Widget> _trackResults = new List<Widget>();
  List<Widget> _artistResults = new List<Widget>();
  TextEditingController _textFieldController = new TextEditingController();

  bool noSearch() => this._albumResults.length == 0 && this._trackResults.length == 0 && this._textFieldController.text == '';
  bool noResult() => this._albumResults.length == 0 && this._trackResults.length == 0 && this._textFieldController.text != '';
  bool noAlbums() => this._albumResults.length == 0;
  bool noTracks() => this._trackResults.length == 0;

  void _refresh() {
    String textFieldValue = this._textFieldController.text;
    this._textFieldController.clear();
    this._textFieldController.text = textFieldValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._textFieldController.addListener(() async {
        this._albumResults = [];
        this._trackResults = [];
        this._artistResults = [];
        List<dynamic> resultCollection = await collection.search(this._textFieldController.text);
        for (dynamic collectionItem in resultCollection) {
          if (collectionItem is Album) {
            this._albumResults.add(
              Container(
                margin: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                child: CollectionAlbumTile(
                  height: this.tileHeight,
                  width: this.tileWidth,
                  album: collectionItem,
                ),
              ),
            );
          }
          else if (collectionItem is Track) {
            this._trackResults.add(
              CollectionTrackTile(
                track: collectionItem,
              ),
            );
          }
        }
        this.setState(() {});
      });
      States.musicCollectionSearchRefresh = this._refresh;
    }
    this._init = false;
  }

  @override
  void dispose() {
    States.musicCollectionSearchRefresh = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: this._textFieldController,
          cursorWidth: 1.0,
          decoration: InputDecoration.collapsed(hintText: Constants.STRING_SEARCH_COLLECTION),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          iconSize: Theme.of(context).iconTheme.size,
          splashRadius: Theme.of(context).iconTheme.size - 4,
          onPressed: Navigator.of(context).pop,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
            iconSize: Theme.of(context).iconTheme.size,
            splashRadius: Theme.of(context).iconTheme.size - 4,
            tooltip: Constants.STRING_OPTIONS,
            onPressed: this._textFieldController.clear,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
           this.noSearch() ? Container(
            margin: EdgeInsets.only(top: 56),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Icon(Icons.search, size: 72, color: Theme.of(context).iconTheme.color),
                Divider(
                  color: Colors.transparent,
                  height: 8,
                ),
                Text(
                  Constants.STRING_LOCAL_SEARCH_WELCOME,
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            ),
          ) : Container(),
          this.noResult() ? Container(
            margin: EdgeInsets.only(top: 56),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Icon(Icons.close, size: 72, color: Theme.of(context).iconTheme.color),
                Divider(
                  color: Colors.transparent,
                  height: 8,
                ),
                Text(
                  Constants.STRING_LOCAL_SEARCH_NO_RESULTS,
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            ),
          ) : Container(),
          this.noAlbums() ? Container(): SubHeader(Constants.STRING_LOCAL_SEARCH_ALBUM_SUBHEADER),
          this.noAlbums() ? Container(): Container(
            margin: EdgeInsets.only(left: 8.0),
            height: this.tileHeight + 16.0,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: this._albumResults,
            ),
          ),
          this.noTracks() ? Container(): SubHeader(Constants.STRING_LOCAL_SEARCH_TRACK_SUBHEADER),
        ] + (this.noTracks() ? [Container()]: this._trackResults),
      ),
    );
  }
}


class CollectionMusic extends StatefulWidget {
  CollectionMusic({Key key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}


class CollectionMusicState extends State<CollectionMusic> with SingleTickerProviderStateMixin {
  int _elementsPerRow = 2;
  double tileWidth;
  double tileHeight;
  TabController _tabController;
  List<Widget> children = <Widget>[Center(child: CircularProgressIndicator())];
  List<Widget> trackChildren = new List<Widget>();
  List<Widget> albumChildren = new List<Widget>();
  List<Widget> artistChildren = new List<Widget>();
  List<Widget> playlistChildren = new List<Widget>();
  IconData _themeIcon = Icons.brightness_medium;
  TextEditingController _textFieldController = new TextEditingController();
  bool _init = true;

  void refreshAlbums() {
    this.tileWidth = (MediaQuery.of(context).size.width - 16 - (this._elementsPerRow - 1) * 8) / this._elementsPerRow;
    this.tileHeight = tileWidth * 242 / 156;
    this.albumChildren = <Widget>[];
    this.albumChildren.addAll([
      SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_ALBUM),
      LeadingCollectionALbumTile(
        height: tileWidth,
      ),
      SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_ALBUM),
    ]);

    int rowIndex = 0;
    List<Widget> rowChildren = new List<Widget>();
    for (int index = 0; index < collection.albums.length; index++) {
      rowChildren.add(
        CollectionAlbumTile(
          height: tileHeight,
          width: tileWidth,
          album: collection.albums[index],
        ),
      );
      rowIndex++;
      if (rowIndex > this._elementsPerRow - 1) {
        this.albumChildren.add(
          new Container(
            height: tileHeight + 8.0,
            margin: EdgeInsets.only(left: 8, right: 8),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        );
        rowIndex = 0;
        rowChildren = List<Widget>();
      }
    }
    if (collection.albums.length % this._elementsPerRow != 0) {
      rowChildren = <Widget>[];
      for (int index = collection.albums.length - (collection.albums.length % this._elementsPerRow); index < collection.albums.length; index++) {
        rowChildren.add(
          CollectionAlbumTile(
            height: tileHeight,
            width: tileWidth,
            album: collection.albums[index],
          ),
        );
      }
      for (int index = 0; index < this._elementsPerRow - (collection.albums.length % this._elementsPerRow); index++) {
        rowChildren.add(
          Container(
            height: tileHeight,
            width: tileWidth,
          ),
        );
      }
      this.albumChildren.add(
        new Container(
          height: tileHeight + 8.0,
          margin: EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }
    this.setState(() {});
  }

  void refreshArtists() {
    this.artistChildren = <Widget>[];
    this.artistChildren.addAll([
      SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_ARTIST),
      Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 0),
        child: Container(
          height: this.tileWidth,
          width: MediaQuery.of(context).size.width - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.file(
                    collection.getAlbumArt(collection.artists.first.tracks.first.albumArtId),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.low,
                    height: this.tileWidth - 24,
                    width: this.tileWidth - 24,
                  ),
                ),
                height: this.tileWidth,
                width: this.tileWidth,
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                width: MediaQuery.of(context).size.width - 32 - this.tileWidth,
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
      ),
      SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_ARTIST),
    ]);
    int rowIndex = 0;
    List<Widget> rowChildren = new List<Widget>();
    for (int index = 0; index < collection.artists.length; index++) {
      rowChildren.add(
        Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          elevation: 2,
          child: Container(
            height: this.tileHeight - 54,
            width: this.tileWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.file(
                      collection.getAlbumArt(collection.artists[index].tracks.first.albumArtId),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.low,
                      height: this.tileWidth - 24,
                      width: this.tileWidth - 24,
                    ),
                  ),
                  height: this.tileWidth,
                  width: this.tileWidth,
                ),
                Container(
                  height: (this.tileHeight - 54) - this.tileWidth,
                  width: this.tileWidth,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    collection.artists[index].artistName,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      rowIndex++;
      if (rowIndex > this._elementsPerRow - 1) {
        this.artistChildren.add(
          new Container(
            height: this.tileHeight - 54 + 8.0,
            margin: EdgeInsets.only(left: 8, right: 8),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        );
        rowIndex = 0;
        rowChildren = List<Widget>();
      }
    }
    if (collection.artists.length % this._elementsPerRow != 0) {
      rowChildren = <Widget>[];
      for (int index = collection.artists.length - (collection.artists.length % this._elementsPerRow); index < collection.artists.length; index++) {
        rowChildren.add(
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            elevation: 2,
            child: Container(
              height: this.tileHeight - 54,
              width: this.tileWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.file(
                        collection.getAlbumArt(collection.artists[index].tracks.first.albumArtId),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low,
                        height: this.tileWidth - 24,
                        width: this.tileWidth - 24,
                      ),
                    ),
                    height: this.tileWidth,
                    width: this.tileWidth,
                  ),
                  Container(
                    height: (this.tileHeight - 54) - this.tileWidth,
                    width: this.tileWidth,
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      collection.artists[index].artistName,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      for (int index = 0; index < this._elementsPerRow - (collection.artists.length % this._elementsPerRow); index++) {
        rowChildren.add(
          Container(
            height: this.tileHeight - 56,
            width: this.tileWidth,
          ),
        );
      }
      this.artistChildren.add(
        new Container(
          height: this.tileHeight - 54 + 8.0,
          margin: EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }
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
                style: Theme.of(subContext).textTheme.headline4,
              ),
              actions: [
                MaterialButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    await collection.playlistRemove(playlist);
                    Navigator.of(subContext).pop();
                    this._refresh(new Playlist());
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
            splashRadius: Theme.of(context).iconTheme.size - 4,
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
                      Text(Constants.STRING_PLAYLISTS_SUBHEADER, style: Theme.of(context).textTheme.headline4),
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
                                this._refresh(new Playlist());
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
                                this._refresh(new Playlist());
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

  void _refresh(dynamic musicCollectionCurrentTab) {
    if (collection.albums.length != 0 && collection.tracks.length != 0 && collection.artists.length != 0) {
      this.refreshAlbums();
      this.refreshTracks();
      this.refreshArtists();
    }
    else {
      Widget emptyMusicCollection = Center(
        child: Container(
          height: 128,
          margin: EdgeInsets.only(top: 156),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.library_music, 
                size: 64,
                color: Theme.of(context).iconTheme.color,
              ),
              Text(
                Constants.STRING_LOCAL_TOP_BODY_ALBUM_EMPTY,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              )
            ],
          ),
        ),
      );
      this.albumChildren.add(emptyMusicCollection);
      this.trackChildren.add(emptyMusicCollection);
      this.artistChildren.add(emptyMusicCollection);
    }
    this.refreshPlaylists();
    this.setState(() {
      if (musicCollectionCurrentTab is Album) this.children = this.albumChildren;
      else if (musicCollectionCurrentTab is Track) this.children = this.trackChildren;
      else if (musicCollectionCurrentTab is Artist) this.children = this.artistChildren;
      else if (musicCollectionCurrentTab is Playlist) this.children = this.playlistChildren;
    });
  }

  @override
  void initState() {
    super.initState();
    States.musicCollectionRefresh = this._refresh;
    States.musicCollectionCurrentTab = new Album();
    this._tabController = TabController(initialIndex: 0, length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
      this.tileWidth = (MediaQuery.of(context).size.width - 16 - (this._elementsPerRow - 1) * 8) / this._elementsPerRow;
      this.tileHeight = this.tileWidth * 242 / 156;
      this._refresh(new Album());
    }
    this._init = false;
  }

  @override
  void dispose() {
    States.musicCollectionRefresh = null;
    States.musicCollectionCurrentTab = null;
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
                forceElevated: true,
                pinned: true,
                floating: true,
                snap: true,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
                  iconSize: Theme.of(context).iconTheme.size,
                  splashRadius: Theme.of(context).iconTheme.size - 4,
                  onPressed: () {},
                  tooltip: Constants.STRING_MENU,
                ),
                title: Text('Harmonoid', style: Theme.of(context).textTheme.headline6),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 4,
                    tooltip: Constants.STRING_SEARCH_COLLECTION,
                    onPressed: () {
                      Navigator.of(context).pushNamed('collectionMusicSearch');
                    },
                  ),
                  IconButton(
                    icon: Icon(this._themeIcon, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 4,
                    tooltip: Constants.STRING_SWITCH_THEME,
                    onPressed: () {
                      this._themeIcon = this._themeIcon == Icons.brightness_medium ? Icons.brightness_high : Icons.brightness_medium;
                      States.switchTheme();
                      Timer(Duration(milliseconds: 400), () {
                        if (States.musicCollectionRefresh != null) States.musicCollectionRefresh(States.musicCollectionCurrentTab);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
                    iconSize: Theme.of(context).iconTheme.size,
                    splashRadius: Theme.of(context).iconTheme.size - 4,
                    tooltip: Constants.STRING_OPTIONS,
                    onPressed: () {},
                  ),
                ],
                bottom: TabBar(
                  controller: this._tabController,
                  indicatorColor: Theme.of(context).accentColor,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: MD2Indicator(
                    indicatorSize: MD2IndicatorSize.full,
                    indicatorHeight: 4.0,
                    indicatorColor: Theme.of(context).accentColor,
                  ),
                  onTap: (int index) {
                    this._tabController.animateTo(index);
                    States.musicCollectionCurrentTab = <dynamic>[new Album(), new Track(), new Artist(), new Playlist()][this._tabController.index];
                    if (States.musicCollectionRefresh != null) States.musicCollectionRefresh(States.musicCollectionCurrentTab);
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
