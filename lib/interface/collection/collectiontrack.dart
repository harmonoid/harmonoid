/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:share_plus/share_plus.dart';

class CollectionTrackTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? CustomListView(
              children: () {
                List<Widget> children = <Widget>[];
                // children.addAll([
                //   SubHeader(language.COLLECTION_TOP_SUBHEADER_TRACK),
                //   LeadingCollectionTrackTile(),
                //   SubHeader(language.COLLECTION_OTHER_SUBHEADER_TRACK)
                // ]);
                collection.tracks.asMap().forEach((int index, _) {
                  children.add(
                    CollectionTrackTile(
                      track: collection.tracks[index],
                      index: index,
                    ),
                  );
                });
                return children;
              }(),
            )
          : Center(
              child: ExceptionWidget(
                height: 256.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language.NO_COLLECTION_TITLE,
                subtitle: language.NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionTrackTile extends StatefulWidget {
  final Track track;
  final int? index;
  CollectionTrackTile({Key? key, required this.track, this.index});

  CollectionTrackTileState createState() => CollectionTrackTileState();
}

class CollectionTrackTileState extends State<CollectionTrackTile> {
  bool shouldReact = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Material(
        color: Colors.transparent,
        child: Listener(
          onPointerDown: (e) {
            shouldReact = e.kind == PointerDeviceKind.mouse &&
                e.buttons == kSecondaryMouseButton;
          },
          onPointerUp: (e) async {
            if (!shouldReact) return;
            final RenderObject? overlay =
                Overlay.of(context)!.context.findRenderObject();
            shouldReact = false;
            int? result = await showMenu(
              elevation: 4.0,
              context: context,
              position: RelativeRect.fromRect(
                Offset(e.position.dx, e.position.dy - 20.0) & Size.zero,
                overlay!.semanticBounds,
              ),
              items: [
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  value: 0,
                  child: ListTile(
                    leading: Icon(FluentIcons.delete_16_regular),
                    title: Text(
                      language.DELETE,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  value: 1,
                  child: ListTile(
                    leading: Icon(FluentIcons.share_16_regular),
                    title: Text(
                      language.SHARE,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  value: 2,
                  child: ListTile(
                    leading: Icon(FluentIcons.list_16_regular),
                    title: Text(
                      language.ADD_TO_PLAYLIST,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  value: 3,
                  child: ListTile(
                    leading: Icon(FluentIcons.music_note_2_16_regular),
                    title: Text(
                      language.ADD_TO_NOW_PLAYING,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
              ],
            );
            if (result != null) {
              switch (result) {
                case 0:
                  showDialog(
                    context: context,
                    builder: (subContext) => FractionallyScaledWidget(
                      child: AlertDialog(
                        title: Text(
                          language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER,
                          style: Theme.of(subContext).textTheme.headline1,
                        ),
                        content: Text(
                          language.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY,
                          style: Theme.of(subContext).textTheme.headline3,
                        ),
                        actions: [
                          MaterialButton(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: () async {
                              await collection.delete(widget.track);
                              Navigator.of(subContext).pop();
                            },
                            child: Text(language.YES),
                          ),
                          MaterialButton(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: Navigator.of(subContext).pop,
                            child: Text(language.NO),
                          ),
                        ],
                      ),
                    ),
                  );
                  break;
                case 1:
                  Share.shareFiles(
                    [widget.track.filePath!],
                    subject:
                        '${widget.track.trackName} • ${widget.track.albumName}. Shared using Harmonoid!',
                  );
                  break;
                case 2:
                  showDialog(
                    context: context,
                    builder: (subContext) => FractionallyScaledWidget(
                      child: AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        actionsPadding: EdgeInsets.zero,
                        title: Text(
                          language.PLAYLIST_ADD_DIALOG_TITLE,
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
                                padding: EdgeInsets.fromLTRB(24, 8, 0, 16),
                                child: Text(
                                  language.PLAYLIST_ADD_DIALOG_BODY,
                                  style:
                                      Theme.of(subContext).textTheme.headline3,
                                ),
                              ),
                              Container(
                                height: 236,
                                width: 280,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: collection.playlists.length,
                                  itemBuilder: (context, playlistIndex) {
                                    return ListTile(
                                      title: Text(
                                        collection.playlists[playlistIndex]
                                            .playlistName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      leading: Icon(
                                        Icons.queue_music,
                                        size: Theme.of(context).iconTheme.size,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      onTap: () async {
                                        await collection.playlistAddTrack(
                                          collection.playlists[playlistIndex],
                                          widget.track,
                                        );
                                        Navigator.of(subContext).pop();
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
                            textColor: Theme.of(context).primaryColor,
                            onPressed: Navigator.of(subContext).pop,
                            child: Text(language.CANCEL),
                          ),
                        ],
                      ),
                    ),
                  );
                  break;
                case 3:
                  Playback.add(
                    [
                      widget.track,
                    ],
                  );
                  break;
              }
            }
          },
          child: ListTile(
            onTap: () => widget.index != null
                ? Playback.play(
                    index: widget.index!,
                    tracks: collection.tracks,
                  )
                : Playback.play(
                    index: 0,
                    tracks: <Track>[widget.track],
                  ),
            dense: false,
            leading: CircleAvatar(
              child: Text(
                '${widget.track.trackNumber ?? 1}',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundImage: FileImage(widget.track.albumArt),
            ),
            title: Text(
              widget.track.trackName!,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
            subtitle: Text(
              (widget.track.trackDuration != null
                      ? (Duration(milliseconds: widget.track.trackDuration!)
                              .label +
                          ' • ')
                      : '0:00 • ') +
                  widget.track.albumName! +
                  ' • ' +
                  widget.track.trackArtistNames!.take(2).join(', '),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
            trailing: (Platform.isAndroid || Platform.isIOS)
                ? CollectionTrackContextMenu(
                    track: widget.track,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class LeadingCollectionTrackTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Provider.of<Collection>(context, listen: false).lastTrack == null)
      return Container();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: Consumer<Collection>(
        builder: (context, collection, _) => InkWell(
          onTap: () async => await Playback.play(
            index: 0,
            tracks: [collection.lastTrack!],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.file(
                collection.lastTrack!.albumArt,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                height: 156.0,
                width: MediaQuery.of(context).size.width.normalized - 16.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        child: Text(
                          '${collection.lastTrack!.trackNumber ?? 1}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundImage: FileImage(
                          collection.lastTrack!.albumArt,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Divider(
                            color: Colors.transparent,
                            height: 8.0,
                          ),
                          Text(
                            collection.lastTrack!.trackName!,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          Text(
                            collection.lastTrack!.albumName!,
                            style: Theme.of(context).textTheme.headline3,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                          Text(
                            collection.lastTrack!.trackArtistNames!.length < 2
                                ? collection.lastTrack!.trackArtistNames!
                                    .join(', ')
                                : collection.lastTrack!.trackArtistNames!
                                    .sublist(0, 2)
                                    .join(', '),
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28.0,
                        ),
                        onPressed: null,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
