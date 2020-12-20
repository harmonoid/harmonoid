import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/screens/collection/collectionalbum.dart';
import 'package:harmonoid/screens/collection/collectiontrack.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/appstate.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionMusicSearch extends StatefulWidget {
  CollectionMusicSearch({Key key}) : super(key: key);
  CollectionMusicSearchState createState() => CollectionMusicSearchState();
}


class CollectionMusicSearchState extends State<CollectionMusicSearch> {
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
  void initState() {
    super.initState();
    this._textFieldController.addListener(() async {
      this._albumResults = [];
      this._trackResults = [];
      this._artistResults = [];
      List<dynamic> resultCollection = await collection.search(this._textFieldController.text);
      for (dynamic collectionItem in resultCollection) {
        if (collectionItem is Album) {
          this._albumResults.add(
            Container(
              margin: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 16.0, right: 16.0),
              child: CollectionAlbumTile(
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
    AppState.musicCollectionSearchRefresh = this._refresh;
  }

  @override
  void dispose() {
    AppState.musicCollectionSearchRefresh = null;
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
            height: 258,
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
  TabController _tabController;
  ScrollController _scrollController = new ScrollController();
  List<Widget> children = <Widget>[Center(child: CircularProgressIndicator())];
  List<Widget> trackChildren = new List<Widget>();
  List<Widget> albumChildren = new List<Widget>();
  List<Widget> artistChildren = new List<Widget>();
  IconData _themeIcon = Icons.brightness_medium;
  bool _init = true;

  void refreshAlbums() {
    this.albumChildren = <Widget>[];
    this.albumChildren.addAll([
      SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_ALBUM),
      Container(
        margin: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 400),
          closedElevation: 2,
          closedColor: Theme.of(context).cardColor,
          openColor: Theme.of(context).scaffoldBackgroundColor,
          closedBuilder: (_, __) => Container(
            height: 156,
            width: MediaQuery.of(context).size.width - 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.file(
                  collection.getAlbumArt(collection.albums.last.albumArtId),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.low,
                  height: 156,
                  width: 156,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: MediaQuery.of(context).size.width - 48 - 156,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        collection.albums.last.albumName,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      Text(
                        collection.albums.last.artistNames.length < 2 ? 
                        collection.albums.last.artistNames.join(', ') : 
                        collection.albums.last.artistNames.sublist(0, 2).join(', '),
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      Text(
                        '(${collection.albums.last.year})',
                        style: Theme.of(context).textTheme.headline4,
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
            album: collection.albums.last,
          ),
        ),
      ),
      SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_ALBUM),
    ]);

    int rowIndex = 0;
    List<Widget> rowChildren = new List<Widget>();
    for (int index = 0; index < collection.albums.length; index++) {
      rowChildren.add(
        CollectionAlbumTile(
          album: collection.albums[index],
        ),
      );
      rowIndex++;
      if (rowIndex > this._elementsPerRow - 1) {
        this.albumChildren.add(
          new Container(
            height: 246.0 + 16.0,
            margin: EdgeInsets.only(left: 16, right: 16),
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
            album: collection.albums[index],
          ),
        );
      }
      for (int index = 0; index < this._elementsPerRow - (collection.albums.length % this._elementsPerRow); index++) {
        rowChildren.add(
          Container(
            height: 246,
            width: 156,
          ),
        );
      }
      this.albumChildren.add(
        new Container(
          height: 246.0 + 16.0,
          margin: EdgeInsets.only(left: 16, right: 16),
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
        margin: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
        child: Container(
          height: 156,
          width: MediaQuery.of(context).size.width - 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.file(
                    collection.getAlbumArt(collection.artists.last.tracks.last.albumArtId),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.low,
                    height: 132,
                    width: 132,
                  ),
                ),
                height: 156,
                width: 156,
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                width: MediaQuery.of(context).size.width - 48 - 156,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collection.artists.last.artistName,
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
            height: 216,
            width: 156,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.file(
                      collection.getAlbumArt(collection.artists[index].tracks.last.albumArtId),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.low,
                      height: 132,
                      width: 132,
                    ),
                  ),
                  height: 156,
                  width: 156,
                ),
                Container(
                  margin: EdgeInsets.only(left: 2, right: 2),
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.transparent,
                        height: 14,
                      ),
                      Container(
                        height: 38,
                        child: Text(
                          collection.artists[index].artistName,
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
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
        ),
      );
      rowIndex++;
      if (rowIndex > this._elementsPerRow - 1) {
        this.artistChildren.add(
          new Container(
            height: 216.0 + 16.0,
            margin: EdgeInsets.only(left: 16, right: 16),
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
              height: 216,
              width: 156,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.file(
                        collection.getAlbumArt(collection.artists[index].tracks.last.albumArtId),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low,
                        height: 132,
                        width: 132,
                      ),
                    ),
                    height: 156,
                    width: 156,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 2, right: 2),
                    child: Column(
                      children: [
                        Divider(
                          color: Colors.transparent,
                          height: 14,
                        ),
                        Container(
                          height: 38,
                          child: Text(
                            collection.artists[index].artistName,
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
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
          ),
        );
      }
      for (int index = 0; index < this._elementsPerRow - (collection.artists.length % this._elementsPerRow); index++) {
        rowChildren.add(
          Container(
            height: 216,
            width: 156,
          ),
        );
      }
      this.artistChildren.add(
        new Container(
          height: 246.0 + 16.0,
          margin: EdgeInsets.only(left: 16, right: 16),
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
      Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
        child: Container(
          height: 256,
          width: MediaQuery.of(context).size.width - 32 + 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.file(
                collection.getAlbumArt(collection.tracks.last.albumArtId),
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.low,
                alignment: Alignment.topCenter,
                height: 156,
                width: MediaQuery.of(context).size.width - 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      child: Text(collection.tracks.last.trackNumber),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8),
                    width: MediaQuery.of(context).size.width - 32 - 64 - 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                          color: Colors.transparent,
                          height: 12,
                        ),
                        Container(
                          height: 20,
                          child: Text(
                            collection.tracks.last.trackName,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 2,
                        ),
                        Text(
                          collection.tracks.last.albumName,
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 4,
                        ),
                        Text(
                          collection.tracks.last.artistNames.length < 2 ? 
                          collection.tracks.last.artistNames.join(', ') : 
                          collection.tracks.last.artistNames.sublist(0, 2).join(', '),
                          style: Theme.of(context).textTheme.headline4,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(${collection.tracks.last.year})',
                          style: Theme.of(context).textTheme.headline4,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      SubHeader(Constants.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER)
    ]);
    for (int index = 0; index < collection.tracks.length; index++) {
      this.trackChildren.add(
        CollectionTrackTile(
          track: collection.tracks[index],
        ),
      );
    }
    this.setState(() {});
  }

  void _refresh(dynamic musicCollectionCurrentTab) {
    this.refreshAlbums();
    this.refreshTracks();
    this.refreshArtists();
    this.setState(() {
      if (musicCollectionCurrentTab is Album) this.children = this.albumChildren;
      else if (musicCollectionCurrentTab is Track) this.children = this.trackChildren;
      else if (musicCollectionCurrentTab is Artist) this.children = this.artistChildren;
    });
  }

  @override
  void initState() {
    super.initState();
    AppState.musicCollectionRefresh = this._refresh;
    AppState.musicCollectionCurrentTab = new Album();
    this._tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
      this.refreshAlbums();
      this.refreshTracks();
      this.refreshArtists();
      this.children = this.albumChildren;
    }
    this._init = false;
  }

  @override
  void dispose() {
    AppState.musicCollectionRefresh = null;
    AppState.musicCollectionCurrentTab = null;
    this._scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: this._scrollController,
      slivers: [
        SliverAppBar(
          forceElevated: true,
          pinned: true,
          floating: true,
          snap: false,
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
                AppState.switchTheme();
                Timer(Duration(milliseconds: 400), () {
                  if (AppState.musicCollectionRefresh != null) AppState.musicCollectionRefresh(AppState.musicCollectionCurrentTab);
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
          expandedHeight: 56.0 + 48.0,
          bottom: TabBar(
            controller: this._tabController,
            indicatorColor: Theme.of(context).accentColor,
            isScrollable: true,
            onTap: (int index) {
              this._tabController.animateTo(index);
              AppState.musicCollectionCurrentTab = <dynamic>[new Album(), new Track(), new Artist()][this._tabController.index];
              if (AppState.musicCollectionRefresh != null) AppState.musicCollectionRefresh(AppState.musicCollectionCurrentTab);
            },
            tabs: [
              Tab(
                child: Text(
                  Constants.STRING_ALBUM.toUpperCase(), style: TextStyle(
                    color: Theme.of(context).accentColor,
                  )
                ),
              ),
              Tab(
                child: Text(
                  Constants.STRING_TRACK.toUpperCase(), style: TextStyle(
                    color: Theme.of(context).accentColor,
                  )
                ),
              ),
              Tab(
                child: Text(
                  Constants.STRING_ARTIST.toUpperCase(), style: TextStyle(
                    color: Theme.of(context).accentColor,
                  )
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(this.children),
        ),
      ],
    );
  }
}
