import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/screens/savedalbum.dart';
import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/constants/constants.dart';


class MusicCollection extends StatefulWidget {
  MusicCollection({Key key}) : super(key: key);
  MusicCollectionState createState() => MusicCollectionState();
}

class MusicCollectionState extends State<MusicCollection> with TickerProviderStateMixin{
  int _elementsPerRow = 2;
  Animation<double> _opacity;
  AnimationController _controller;
  TabController _tabController;
  ScrollController _scrollController = new ScrollController();
  List<Widget> children = <Widget>[Center(child: CircularProgressIndicator())];
  List<Widget> trackChildren = new List<Widget>();
  List<Widget> albumChildren = new List<Widget>();
  List<Widget> artistChildren = new List<Widget>();
  bool _init = true;

  void refreshAlbums() {
    this.albumChildren = <Widget>[];
    this.albumChildren.addAll([
      SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_ALBUM),
      Container(
        margin: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
        child: OpenContainer(
          closedElevation: 2,
          closedBuilder: (_, __) => Container(
            height: 156,
            width: MediaQuery.of(context).size.width - 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.memory(
                  collection.getAlbumArt(collection.albums.last.albumArtId),
                  fit: BoxFit.fill,
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
                        maxLines: 1,
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
          openBuilder: (_, __) => SavedAlbum(
            album: collection.albums.last,
            refreshCollection: this.refreshCollection,
          ),
        ),
      ),
      SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_ALBUM),
    ]);

    int rowIndex = 0;
    List<Widget> rowChildren = new List<Widget>();
    for (int index = 0; index < collection.albums.length; index++) {
      rowChildren.add(
        OpenContainer(
          closedElevation: 2,
          closedBuilder: (_, __) => Container(
            height: 246,
            width: 156,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.memory(
                  collection.getAlbumArt(collection.albums[index].albumArtId),
                  fit: BoxFit.fill,
                  height: 156,
                  width: 156,
                ),
                Container(
                  margin: EdgeInsets.only(left: 2, right: 2),
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.transparent,
                        height: 8,
                      ),
                      Container(
                        height: 38,
                        child: Text(
                          collection.albums[index].albumName,
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                        thickness: 4,
                      ),
                      Text(
                        collection.albums[index].artistNames.length < 2 ? 
                        collection.albums[index].artistNames.join(', ') : 
                        collection.albums[index].artistNames.sublist(0, 2).join(', '),
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(${collection.albums[index].year})',
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
          openBuilder: (_, __) => SavedAlbum(
            album: collection.albums[index],
            refreshCollection: this.refreshCollection,
          ),
        ),
      );
      rowIndex++;
      if (rowIndex > this._elementsPerRow - 1) {
        this.albumChildren.add(
          new Container(
            height: 246.0 + 16.0,
            margin: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowChildren,
            ),
          ),
        );
        rowIndex = 0;
        rowChildren = List<Widget>();
      }
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
                  child: Image.memory(
                  collection.getAlbumArt(collection.artists.last.tracks.last.albumArtId),
                    fit: BoxFit.fill,
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
                    child: Image.memory(
                      collection.getAlbumArt(collection.artists[index].tracks.last.albumArtId),
                      fit: BoxFit.fill,
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
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowChildren,
            ),
          ),
        );
        rowIndex = 0;
        rowChildren = List<Widget>();
      }
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
              Image.memory(
                collection.getAlbumArt(collection.tracks.last.albumArtId),
                fit: BoxFit.fitWidth,
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
        ListTile(
          onTap: () {},
          dense: false,
          isThreeLine: true,
          leading: CircleAvatar(
            child: Text(collection.tracks[index].trackNumber),
            backgroundImage: MemoryImage(collection.getAlbumArt(collection.tracks[index].albumArtId)),
          ),
          title: Text(collection.tracks[index].trackName),
          subtitle: Text(
            collection.tracks[index].albumName + '\n' + 
            (collection.tracks[index].artistNames.length < 2 ? 
            collection.tracks[index].artistNames.join(', ') : 
            collection.tracks[index].artistNames.sublist(0, 2).join(', ')),
          ),
        ),
      );
    }
    this.setState(() {});
  }

  void refreshCollection(dynamic object) {
    this.refreshAlbums();
    this.refreshTracks();
    this.refreshArtists();
    this.setState(() {
      if (object is Album) this.children = this.albumChildren;
      else if (object is Track) this.children = this.trackChildren;
      else if (object is Artist) this.children = this.artistChildren;
    });
  }

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    this._controller = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
    );
    this._opacity = new Tween<double>(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
      parent: this._controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ));
    this._scrollController.addListener(() {
      if (this._scrollController.position.userScrollDirection == ScrollDirection.reverse && this._controller.isDismissed) {
        this._controller.forward();
      }
      else if (this._scrollController.position.userScrollDirection == ScrollDirection.forward  && this._controller.isCompleted) {
        this._controller.reverse();
      }
    });
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
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.brightness_medium, color: Theme.of(context).iconTheme.color),
              iconSize: Theme.of(context).iconTheme.size,
              splashRadius: Theme.of(context).iconTheme.size - 4,
              tooltip: Constants.STRING_SWITCH_THEME,
              onPressed: () {},
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
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: 56 + MediaQuery.of(context).padding.top, left: 56),
            height: 48,
            child: FadeTransition(
              opacity: this._opacity,
              child: TabBar(
                controller: this._tabController,
                indicatorColor: Theme.of(context).accentColor,
                isScrollable: true,
                onTap: (int index) {
                  this.setState(() {
                    if (index == 0) this.children = this.albumChildren;
                    else if (index == 1) this.children = this.trackChildren;
                    else if (index == 2) this.children = this.artistChildren;
                    this._tabController.animateTo(index);
                  });
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
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(this.children),
        ),
      ],
    );
  }
}
