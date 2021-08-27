import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionSearch extends StatefulWidget {
  CollectionSearch({Key? key}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}

class CollectionSearchState extends State<CollectionSearch> {
  int elementsPerRow = 2;
  TextEditingController textFieldController = new TextEditingController();
  String query = '';
  bool get search =>
      _albums.length == 0 &&
      _tracks.length == 0 &&
      _artists.length == 0 &&
      query == '';
  bool get result =>
      _albums.length == 0 &&
      _tracks.length == 0 &&
      _artists.length == 0 &&
      query != '';
  bool get albums => _albums.length == 0;
  bool get tracks => _tracks.length == 0;
  bool get artists => _artists.length == 0;
  List<Widget> _albums = <Widget>[];
  List<Widget> _tracks = <Widget>[];
  List<Widget> _artists = <Widget>[];
  int globalIndex = 0;

  @override
  Widget build(BuildContext context) {
    /// TODO: These elements get added to a [List] for rendering.
    /// But their dimensions do not get recalculated because they are now part of mutable list.
    /// Thus, overflow happens if someone resizes the window. Unlike other tabs.
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidthAlbum =
        (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeightAlbum = tileWidthAlbum * 260.0 / 156;
    double tileWidthArtist = tileWidthAlbum;
    double tileHeightArtist = tileWidthArtist + 36.0;
    return Consumer<Collection>(
      builder: (context, collection, _) => Scaffold(
        body: Column(
          children: [
            Container(
              height: 56.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24.0,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: textFieldController,
                      cursorWidth: 1.0,
                      style: Theme.of(context).textTheme.headline4,
                      onChanged: (String query) async {
                        int localIndex = globalIndex;
                        globalIndex++;
                        List<dynamic> resultCollection =
                            await collection.search(query);
                        List<Widget> albums = <Widget>[];
                        List<Widget> tracks = <Widget>[];
                        List<Widget> artists = <Widget>[];
                        for (dynamic collectionItem in resultCollection) {
                          if (collectionItem is Album) {
                            albums.add(
                              Container(
                                margin: EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, right: 8.0),
                                child: CollectionAlbumTile(
                                  height: tileHeightAlbum,
                                  width: tileWidthAlbum,
                                  album: collectionItem,
                                ),
                              ),
                            );
                          }
                          if (collectionItem is Artist) {
                            artists.add(
                              Container(
                                margin: EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, right: 8.0),
                                child: CollectionArtistTile(
                                  height: tileHeightArtist,
                                  width: tileWidthArtist,
                                  artist: collectionItem,
                                ),
                              ),
                            );
                          } else if (collectionItem is Track) {
                            tracks.add(
                              CollectionTrackTile(
                                track: collectionItem,
                                popupMenuButton: ContextMenuButton(
                                  elevation: 0,
                                  onSelected: (index) {
                                    switch (index) {
                                      case 0:
                                        showDialog(
                                          context: context,
                                          builder: (subContext) => AlertDialog(
                                            title: Text(
                                              language!
                                                  .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                              style: Theme.of(subContext)
                                                  .textTheme
                                                  .headline1,
                                            ),
                                            content: Text(
                                              language!
                                                  .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                              style: Theme.of(subContext)
                                                  .textTheme
                                                  .headline5,
                                            ),
                                            actions: [
                                              MaterialButton(
                                                textColor: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () async {
                                                  await collection.delete(
                                                      collection.tracks[index]);
                                                  Navigator.of(subContext)
                                                      .pop();
                                                },
                                                child:
                                                    Text(language!.STRING_YES),
                                              ),
                                              MaterialButton(
                                                textColor: Theme.of(context)
                                                    .primaryColor,
                                                onPressed:
                                                    Navigator.of(subContext)
                                                        .pop,
                                                child:
                                                    Text(language!.STRING_NO),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                      case 1:
                                        Share.shareFiles([
                                          collection.tracks[index].filePath!
                                        ]);
                                        break;
                                      case 2:
                                        showDialog(
                                          context: context,
                                          builder: (subContext) => AlertDialog(
                                            contentPadding: EdgeInsets.zero,
                                            actionsPadding: EdgeInsets.zero,
                                            title: Text(
                                              language!
                                                  .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                              style: Theme.of(subContext)
                                                  .textTheme
                                                  .headline1,
                                            ),
                                            content: Container(
                                              height: 280,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            24, 8, 0, 16),
                                                    child: Text(
                                                      language!
                                                          .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline5,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 236,
                                                    width: 280,
                                                    decoration: BoxDecoration(
                                                      border: Border.symmetric(
                                                        vertical: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: collection
                                                          .playlists.length,
                                                      itemBuilder: (context,
                                                          playlistIndex) {
                                                        return ListTile(
                                                          title: Text(
                                                            collection
                                                                .playlists[
                                                                    playlistIndex]
                                                                .playlistName!,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline2,
                                                          ),
                                                          leading: Icon(
                                                            Icons.queue_music,
                                                            size: Theme.of(
                                                                    context)
                                                                .iconTheme
                                                                .size,
                                                            color: Theme.of(
                                                                    context)
                                                                .iconTheme
                                                                .color,
                                                          ),
                                                          onTap: () async {
                                                            await collection
                                                                .playlistAddTrack(
                                                              collection
                                                                      .playlists[
                                                                  playlistIndex],
                                                              collection.tracks[
                                                                  index],
                                                            );
                                                            Navigator.of(
                                                                    subContext)
                                                                .pop();
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              MaterialButton(
                                                textColor: Theme.of(context)
                                                    .primaryColor,
                                                onPressed:
                                                    Navigator.of(subContext)
                                                        .pop,
                                                child: Text(
                                                    language!.STRING_CANCEL),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                    }
                                  },
                                  icon: Icon(
                                    FluentIcons.more_vertical_20_regular,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 20.0,
                                  ),
                                  tooltip: language!.STRING_OPTIONS,
                                  itemBuilder: (_) => <PopupMenuEntry>[
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text(
                                        language!.STRING_DELETE,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text(
                                        language!.STRING_SHARE,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child: Text(
                                        language!.STRING_ADD_TO_PLAYLIST,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        if (localIndex == globalIndex - 1) {
                          _albums = albums;
                          _artists = artists;
                          _tracks = tracks;
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration.collapsed(
                        hintText:
                            'Enter something to lookup in your collection.',
                        hintStyle: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: <Widget>[
                      search
                          ? Container(
                              margin: EdgeInsets.only(top: 56),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Icon(FluentIcons.search_20_regular,
                                      size: 72,
                                      color: Theme.of(context).iconTheme.color),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  Text(
                                    language!.STRING_LOCAL_SEARCH_WELCOME,
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      result
                          ? Container(
                              margin: EdgeInsets.only(top: 56),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Icon(FluentIcons.emoji_sad_20_regular,
                                      size: 72,
                                      color: Theme.of(context).iconTheme.color),
                                  Divider(
                                    color: Colors.transparent,
                                    height: 8,
                                  ),
                                  Text(
                                    language!.STRING_LOCAL_SEARCH_NO_RESULTS,
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      albums ? Container() : SubHeader(language!.STRING_ALBUM),
                      albums
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(left: 8.0),
                              height: tileHeightAlbum + 16.0,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _albums,
                              ),
                            ),
                      artists
                          ? Container()
                          : SubHeader(language!.STRING_ARTIST),
                      artists
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(left: 8.0),
                              height: tileHeightArtist + 16.0,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _artists,
                              ),
                            ),
                      tracks ? Container() : SubHeader(language!.STRING_TRACK),
                    ] +
                    (tracks ? [Container()] : _tracks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
