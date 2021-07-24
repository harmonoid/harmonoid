import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionAlbumTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    double tileWidth =
        (MediaQuery.of(context).size.width - 16 - (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeight = tileWidth * 242 / 156;

    return Consumer<Collection>(
      builder: (context, collection, _) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              collection.tracks.isNotEmpty
                  ? tileGridListWidgets(
                      context: context,
                      tileHeight: tileHeight,
                      tileWidth: tileWidth,
                      elementsPerRow: elementsPerRow,
                      subHeader: language!.STRING_LOCAL_OTHER_SUBHEADER_ALBUM,
                      leadingSubHeader:
                          language!.STRING_LOCAL_TOP_SUBHEADER_ALBUM,
                      widgetCount: collection.albums.length,
                      leadingWidget: LeadingCollectionALbumTile(
                        height: tileWidth,
                      ),
                      builder: (BuildContext context, int index) =>
                          CollectionAlbumTile(
                        height: tileHeight,
                        width: tileWidth,
                        album: collection.albums[index],
                      ),
                    )
                  : <Widget>[
                      ExceptionWidget(
                        margin: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.height -
                                  (MediaQuery.of(context).padding.top +
                                      MediaQuery.of(context).padding.bottom +
                                      tileWidth +
                                      256.0)) /
                              2,
                          left: 8.0,
                          right: 8.0,
                        ),
                        height: tileWidth,
                        assetImage: 'assets/images/collection-album.jpg',
                        title: language!.STRING_NO_COLLECTION_TITLE,
                        subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
                        large: true,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionAlbumTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Album album;

  const CollectionAlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedElevation: 2,
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (_, open) => Container(
        height: this.height,
        width: this.width,
        child: InkWell(
          onTap: open,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Ink.image(
                image: FileImage(this.album.albumArt),
                fit: BoxFit.fill,
                height: this.width,
                width: this.width,
              ),
              Container(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                height: this.height! - this.width!,
                width: this.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        this.album.albumName!,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '${this.album.albumArtistName}\n(${this.album.year ?? 'Unknown Year'})',
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
      ),
      openBuilder: (_, __) => CollectionAlbum(
        album: this.album,
      ),
    );
  }
}

class LeadingCollectionALbumTile extends StatelessWidget {
  final double height;

  const LeadingCollectionALbumTile({Key? key, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 4.0),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 400),
        closedElevation: 2,
        closedColor: Theme.of(context).cardColor,
        openColor: Theme.of(context).scaffoldBackgroundColor,
        closedBuilder: (_, open) => InkWell(
          onTap: open,
          child: Container(
            height: this.height,
            width: MediaQuery.of(context).size.width - 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Ink.image(
                  image: FileImage(
                      Provider.of<Collection>(context, listen: false)
                          .lastAlbum!
                          .albumArt),
                  fit: BoxFit.fill,
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
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumName!,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      Text(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumArtistName!,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      Text(
                        '(${Provider.of<Collection>(context, listen: false).lastAlbum!.year ?? 'Unknown Year'})',
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
        ),
        openBuilder: (_, __) => CollectionAlbum(
          album: Provider.of<Collection>(context, listen: false).lastAlbum,
        ),
      ),
    );
  }
}

class CollectionAlbum extends StatelessWidget {
  final Album? album;
  const CollectionAlbum({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double wh;
    if (Platform.isWindows || Platform.isLinux) {
      wh = MediaQuery.of(context).size.width / 5;
    } else {
      wh = MediaQuery.of(context).size.width;
    }
    return Consumer<Collection>(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.file(
            this.album!.albumArt,
            fit: BoxFit.fill,
            width: wh,
            height: wh,
            filterQuality: FilterQuality.low,
          ),
          Container(
            width: wh,
            height: wh,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        ],
      ),
      builder: (context, collection, child) => Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            child!,
            ListView(
              children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: wh * 2,
                          height: wh * 2,
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
                                ]),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          color: Theme.of(context).cardColor,
                          margin: EdgeInsets.only(
                              left: 16, right: 16, top: 0, bottom: 8.0),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.file(
                                  this.album!.albumArt,
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.low,
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(left: 16.0, right: 16.0),
                                  width: MediaQuery.of(context).size.width -
                                      16 -
                                      16 -
                                      140,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        this.album!.albumName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                      ),
                                      Divider(
                                        color: Colors.transparent,
                                        height: 2,
                                      ),
                                      Text(
                                        this.album!.albumArtistName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                      ),
                                      Divider(
                                        color: Colors.transparent,
                                        height: 2,
                                      ),
                                      Text(
                                        '${this.album!.year ?? 'Unknown Year'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      Divider(
                                        color: Colors.transparent,
                                        height: 2,
                                      ),
                                      Text(
                                        '${this.album!.tracks.length}' +
                                            ' ' +
                                            language!.STRING_TRACK
                                                .toLowerCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
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
                      ],
                    ),
                    SubHeader(
                        language!.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER),
                  ] +
                  this
                      .album!
                      .tracks
                      .map(
                        (Track track) => Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: new Material(
                            color: Colors.transparent,
                            child: new ListTile(
                              onTap: () async {
                                await Playback.play(
                                  index: this.album!.tracks.indexOf(track),
                                  tracks: this.album!.tracks,
                                );
                              },
                              title: Text(
                                track.trackName!,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              subtitle: Text(
                                track.trackArtistNames!.join(', '),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              leading: CircleAvatar(
                                child: Text('${track.trackNumber ?? 1}'),
                                backgroundImage:
                                    FileImage(this.album!.albumArt),
                              ),
                              trailing: PopupMenuButton(
                                color: Theme.of(context).appBarTheme.color,
                                elevation: 2,
                                onSelected: (dynamic index) {
                                  switch (index) {
                                    case 0:
                                      {
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
                                                  Navigator.of(subContext)
                                                      .pop();
                                                  await collection
                                                      .delete(track);
                                                  if (album!.tracks.isEmpty) {
                                                    while (Navigator.of(context)
                                                        .canPop())
                                                      Navigator.of(context)
                                                          .pop();
                                                  }
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
                                      }
                                      break;
                                    case 1:
                                      {
                                        Share.shareFiles(
                                          [track.filePath!],
                                          subject:
                                              '${track.trackName} - ${track.albumName}.',
                                        );
                                      }
                                      break;
                                    case 2:
                                      {
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
                                                    padding: EdgeInsets.only(
                                                        left: 24,
                                                        top: 8,
                                                        bottom: 16),
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
                                                        border: Border(
                                                      top: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor,
                                                          width: 1),
                                                      bottom: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor,
                                                          width: 1),
                                                    )),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: collection
                                                          .playlists.length,
                                                      itemBuilder: (BuildContext
                                                                  context,
                                                              int playlistIndex) =>
                                                          ListTile(
                                                        title: Text(
                                                            collection
                                                                .playlists[
                                                                    playlistIndex]
                                                                .playlistName!,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline2),
                                                        leading: Icon(
                                                          Icons.queue_music,
                                                          size:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .size,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color,
                                                        ),
                                                        onTap: () async {
                                                          await collection
                                                              .playlistAddTrack(
                                                            collection
                                                                    .playlists[
                                                                playlistIndex],
                                                            track,
                                                          );
                                                          Navigator.of(
                                                                  subContext)
                                                              .pop();
                                                        },
                                                      ),
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
                                      }
                                      break;
                                  }
                                },
                                icon: Icon(Icons.more_vert,
                                    color: Theme.of(context).iconTheme.color,
                                    size: Theme.of(context).iconTheme.size),
                                tooltip: language!.STRING_OPTIONS,
                                itemBuilder: (_) => <PopupMenuEntry>[
                                  PopupMenuItem(
                                    value: 0,
                                    child: Text(language!.STRING_DELETE),
                                  ),
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(language!.STRING_SHARE),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child:
                                        Text(language!.STRING_ADD_TO_PLAYLIST),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      )),
    );
  }
}
