import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/screens/collection/collectionalbum.dart';
import 'package:harmonoid/screens/collection/collectiontrack.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/widgets.dart';
import 'package:harmonoid/constants/constants.dart';


class CollectionSearch extends StatefulWidget {
  CollectionSearch({Key key}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}


class CollectionSearchState extends State<CollectionSearch> {
  int _elementsPerRow = 2;
  bool _init = true;
  double _tileWidth;
  double _tileHeight;
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
      this._elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
      this._tileWidth = (MediaQuery.of(context).size.width - 16 - (this._elementsPerRow - 1) * 8) / this._elementsPerRow;
      this._tileHeight = this._tileWidth * 242 / 156;
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
                  height: this._tileHeight,
                  width: this._tileWidth,
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
      States.refreshMusicSearch = this._refresh;
    }
    this._init = false;
  }

  @override
  void dispose() {
    States.refreshMusicSearch = () {};
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
          splashRadius: Theme.of(context).iconTheme.size - 8,
          onPressed: Navigator.of(context).pop,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
            iconSize: Theme.of(context).iconTheme.size,
            splashRadius: Theme.of(context).iconTheme.size - 8,
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
                  style: Theme.of(context).textTheme.headline5,
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
                  style: Theme.of(context).textTheme.headline5,
                )
              ],
            ),
          ) : Container(),
          this.noAlbums() ? Container(): SubHeader(Constants.STRING_LOCAL_SEARCH_ALBUM_SUBHEADER),
          this.noAlbums() ? Container(): Container(
            margin: EdgeInsets.only(left: 8.0),
            height: this._tileHeight + 16.0,
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
