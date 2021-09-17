import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionArtistTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow =
        (MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) ~/
            (156 + 8);
    double tileWidth =
        ((MediaQuery.of(context).size.width * (Platform.isLinux ? 0.75 : 1.0)) -
                16 -
                (elementsPerRow - 1) * 8) /
            elementsPerRow;
    double tileHeight = tileWidth + 36.0;

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? CustomListView(
              children: tileGridListWidgets(
                context: context,
                tileHeight: tileHeight,
                tileWidth: tileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: language!.STRING_LOCAL_OTHER_SUBHEADER_ARTIST,
                leadingSubHeader: language!.STRING_LOCAL_TOP_SUBHEADER_ARTIST,
                widgetCount: collection.artists.length,
                leadingWidget: LeadingCollectionArtistTile(
                  height: tileWidth,
                ),
                builder: (BuildContext context, int index) =>
                    CollectionArtistTile(
                  height: tileHeight,
                  width: tileWidth,
                  artist: collection.artists[index],
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 256.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language!.STRING_NO_COLLECTION_TITLE,
                subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class LeadingCollectionArtistTile extends StatelessWidget {
  final double height;
  const LeadingCollectionArtistTile({Key? key, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Container(
        margin: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          bottom: 4.0,
          top: 2.0,
        ),
        height: this.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: CollectionArtist(artist: collection.lastArtist),
                    ),
                  ),
                );
              },
              child: Container(
                height: this.height,
                width: (MediaQuery.of(context).size.width *
                        (Platform.isLinux ? 0.75 : 1.0)) -
                    16,
                child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'artist_art_${collection.lastArtist!.artistName}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(
                            image: FileImage(
                                collection.lastArtist!.tracks.last.albumArt),
                            fit: BoxFit.fill,
                            height: this.height,
                            width: this.height,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8, right: 8),
                        width: (MediaQuery.of(context).size.width *
                                (Platform.isLinux ? 0.75 : 1.0)) -
                            32 -
                            this.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              collection.lastArtist!.artistName!,
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
            ),
          ),
        ),
      ),
    );
  }
}

class CollectionArtistTile extends StatelessWidget {
  final double height;
  final double width;
  final Artist artist;
  const CollectionArtistTile(
      {Key? key,
      required this.height,
      required this.width,
      required this.artist})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: CollectionArtist(
                    artist: this.artist,
                  ),
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'artist_art_${this.artist.artistName!}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: FileImage(this.artist.tracks.last.albumArt),
                    fit: BoxFit.fill,
                    height: this.width,
                    width: this.width,
                  ),
                ),
              ),
              Container(
                height: 36.0,
                width: this.width,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  this.artist.artistName!,
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
}

class CollectionArtist extends StatelessWidget {
  final Artist? artist;
  const CollectionArtist({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double tileWidth = 156.0;
    double tileHeight = 260.0;

    return Consumer<Collection>(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.04),
        ),
        height: MediaQuery.of(context).size.height,
        width: (MediaQuery.of(context).size.width *
                (Platform.isLinux ? 0.75 : 1.0)) /
            3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                NavigatorPopButton(),
                SizedBox(
                  width: 24.0,
                ),
                Text(
                  language!.STRING_ARTIST_SINGLE,
                  style: Theme.of(context).textTheme.headline1,
                )
              ],
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 256.0,
                            maxHeight: 256.0,
                          ),
                          child: Hero(
                            tag: 'artist_art_${this.artist!.artistName}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                this.artist!.tracks.last.albumArt,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.0),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            this.artist!.artistName!,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '${this.artist!.tracks.length} tracks & ${this.artist!.albums.length} albums.',
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Play Now',
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Add to Now Playing',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      builder: (context, collection, child) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            height: MediaQuery.of(context).size.height,
            width: (MediaQuery.of(context).size.width *
                (Platform.isLinux ? 0.75 : 1.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                constraints.maxWidth > HORIZONTAL_BREAKPOINT
                    ? child!
                    : Container(),
                Expanded(
                  child: CustomListView(
                    shrinkWrap: true,
                    children: <Widget>[
                          constraints.maxWidth > HORIZONTAL_BREAKPOINT
                              ? Container()
                              : child!,
                          SubHeader(
                            language!.STRING_ALBUMS_FROM_ARTIST,
                          ),
                          Container(
                            height: tileHeight + 16.0,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Scrollbar(
                              child: CustomListView(
                                scrollDirection: Axis.horizontal,
                                children: this
                                    .artist!
                                    .albums
                                    .map(
                                      (album) => Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 8.0,
                                        ),
                                        child: CollectionAlbumTile(
                                          album: album,
                                          height: tileHeight,
                                          width: tileWidth,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          SubHeader(
                            language!.STRING_TRACKS_FROM_ARTIST,
                          ),
                        ] +
                        this
                            .artist!
                            .tracks
                            .map(
                              (Track track) => Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: new Material(
                                  color: Colors.transparent,
                                  child: new ListTile(
                                    onTap: () async {
                                      await Playback.play(
                                        index:
                                            this.artist!.tracks.indexOf(track),
                                        tracks: this.artist!.tracks,
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
                                          FileImage(track.albumArt),
                                    ),
                                    trailing: ContextMenuButton(
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor,
                                      elevation: 0,
                                      onSelected: (dynamic index) {
                                        switch (index) {
                                          case 0:
                                            {
                                              showDialog(
                                                context: context,
                                                builder: (subContext) =>
                                                    FractionallyScaledWidget(
                                                  child: AlertDialog(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .appBarTheme
                                                            .backgroundColor,
                                                    title: Text(
                                                      language!
                                                          .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline1,
                                                    ),
                                                    content: Text(
                                                      language!
                                                          .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline5,
                                                    ),
                                                    actions: [
                                                      MaterialButton(
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: () async {
                                                          Navigator.of(
                                                                  subContext)
                                                              .pop();
                                                          await collection
                                                              .delete(track);
                                                          if (this
                                                              .artist!
                                                              .tracks
                                                              .isEmpty) {
                                                            while (Navigator.of(
                                                                    context)
                                                                .canPop())
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                          }
                                                        },
                                                        child: Text(language!
                                                            .STRING_YES),
                                                      ),
                                                      MaterialButton(
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: Navigator.of(
                                                                subContext)
                                                            .pop,
                                                        child: Text(language!
                                                            .STRING_NO),
                                                      ),
                                                    ],
                                                  ),
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
                                                builder: (subContext) =>
                                                    FractionallyScaledWidget(
                                                  child: AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    actionsPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      language!
                                                          .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                                      style:
                                                          Theme.of(subContext)
                                                              .textTheme
                                                              .headline1,
                                                    ),
                                                    content: Container(
                                                      height: 280,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 24,
                                                                    top: 8,
                                                                    bottom: 16),
                                                            child: Text(
                                                              language!
                                                                  .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                                              style: Theme.of(
                                                                      subContext)
                                                                  .textTheme
                                                                  .headline5,
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 236,
                                                            width: 280,
                                                            decoration:
                                                                BoxDecoration(
                                                                    border:
                                                                        Border(
                                                              top: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor,
                                                                  width: 1),
                                                              bottom: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor,
                                                                  width: 1),
                                                            )),
                                                            child: ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  collection
                                                                      .playlists
                                                                      .length,
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
                                                                  Icons
                                                                      .queue_music,
                                                                  size: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .size,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .color,
                                                                ),
                                                                onTap:
                                                                    () async {
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
                                                        textColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        onPressed: Navigator.of(
                                                                subContext)
                                                            .pop,
                                                        child: Text(language!
                                                            .STRING_CANCEL),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            break;
                                          case 3:
                                            Playback.add(
                                              [
                                                track,
                                              ],
                                            );
                                            break;
                                        }
                                      },
                                      icon: Icon(
                                        FluentIcons.more_vertical_20_regular,
                                        color:
                                            Theme.of(context).iconTheme.color,
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
                                        PopupMenuItem(
                                          value: 3,
                                          child: Text(
                                            language!.STRING_ADD_TO_NOW_PLAYING,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
