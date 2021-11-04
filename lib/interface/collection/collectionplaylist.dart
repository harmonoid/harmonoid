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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionPlaylistTab extends StatelessWidget {
  final TextEditingController _textFieldController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => CustomListView(children: [
        Container(
          margin: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.PLAYLISTS,
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontSize: 24.0),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          language.PLAYLISTS_SUBHEADER,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                  PageStorage(
                    bucket: PageStorageBucket(),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        maintainState: false,
                        initiallyExpanded: false,
                        childrenPadding: EdgeInsets.only(
                            top: 12, bottom: 12, left: 16, right: 16),
                        leading: Icon(
                          FluentIcons.list_16_regular,
                          size: 20.0,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        trailing: Icon(
                          FluentIcons.add_12_regular,
                          size: 18.0,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          language.PLAYLISTS_CREATE,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      HotKeys.disableSpaceHotKey();
                                    } else {
                                      HotKeys.enableSpaceHotKey();
                                    }
                                  },
                                  child: Container(
                                    height: 45.0,
                                    child: TextField(
                                      controller: this._textFieldController,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                      cursorWidth: 1,
                                      autofocus: true,
                                      autocorrect: true,
                                      onSubmitted: (String value) async {
                                        if (value != '') {
                                          FocusScope.of(context).unfocus();
                                          await collection.playlistAdd(
                                              new Playlist(
                                                  playlistName: value));
                                          this._textFieldController.clear();
                                        }
                                      },
                                      cursorColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          onPressed: () async {
                                            if (this
                                                    ._textFieldController
                                                    .text !=
                                                '') {
                                              FocusScope.of(context).unfocus();
                                              await collection.playlistAdd(
                                                  new Playlist(
                                                      playlistName: this
                                                          ._textFieldController
                                                          .text));
                                              this._textFieldController.clear();
                                            }
                                          },
                                          icon: Transform.rotate(
                                            angle: pi / 2,
                                            child: Icon(
                                              FluentIcons.search_12_regular,
                                              size: 17.0,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.black87
                                                  : Colors.white
                                                      .withOpacity(0.87),
                                            ),
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(
                                            left: 10.0, bottom: 16.0),
                                        hintText:
                                            language.PLAYLISTS_TEXT_FIELD_HINT,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                        filled: true,
                                        fillColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Color(0xFF202020),
                                        hoverColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Color(0xFF202020),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.32),
                                            width: 0.6,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.32),
                                            width: 0.6,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.32),
                                            width: 0.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 16.0,
                  ),
                ] +
                collection.playlists
                    .map(
                      (Playlist playlist) => ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CollectionPlaylist(
                                playlist: playlist,
                              ),
                            ),
                          );
                        },
                        onLongPress: () => showDialog(
                          context: context,
                          builder: (subContext) => FractionallyScaledWidget(
                            child: AlertDialog(
                              title: Text(
                                language
                                    .COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_HEADER,
                                style: Theme.of(subContext).textTheme.headline1,
                              ),
                              content: Text(
                                language
                                    .COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_BODY,
                                style: Theme.of(subContext).textTheme.headline3,
                              ),
                              actions: [
                                MaterialButton(
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () async {
                                    await collection.playlistRemove(playlist);
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
                        ),
                        leading: playlist.tracks.length != 0
                            ? CircleAvatar(
                                backgroundImage:
                                    FileImage(playlist.tracks.last.albumArt),
                              )
                            : Icon(
                                FluentIcons.list_16_regular,
                                size: 20.0,
                                color: Theme.of(context).iconTheme.color,
                              ),
                        title: Text(
                          playlist.playlistName!,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        trailing: IconButton(
                          onPressed: () => Playback.play(
                            index: 0,
                            tracks: playlist.tracks,
                          ),
                          icon: Icon(
                            FluentIcons.play_circle_20_regular,
                            size: 20.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          iconSize: Theme.of(context).iconTheme.size!,
                          splashRadius: Theme.of(context).iconTheme.size! - 8,
                        ),
                      ),
                    )
                    .toList(),
          ),
        )
      ]),
    );
  }
}

class CollectionPlaylist extends StatelessWidget {
  final Playlist playlist;
  CollectionPlaylist({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56.0,
              color: configuration.acrylicEnabled!
                  ? Colors.transparent
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NavigatorPopButton(),
                  SizedBox(
                    width: 16.0,
                  ),
                  Text(
                    this.playlist.playlistName!,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Color(0xFF202020),
                child: this.playlist.tracks.isNotEmpty
                    ? CustomListView(
                        children: <Widget>[
                              SubHeader(language.PLAYLIST_TRACKS_SUBHEADER),
                            ] +
                            (this.playlist.tracks.map((Track track) {
                              return ListTile(
                                onTap: () => Playback.play(
                                  index: this.playlist.tracks.indexOf(track),
                                  tracks: this.playlist.tracks,
                                ),
                                isThreeLine: true,
                                leading: CircleAvatar(
                                  child: Text('${track.trackNumber ?? 1}'),
                                  backgroundImage: FileImage(track.albumArt),
                                ),
                                title: Text(track.trackName!),
                                subtitle: Text(
                                  track.albumName! +
                                      '\n' +
                                      (track.trackArtistNames!.length < 2
                                          ? track.trackArtistNames!.join(', ')
                                          : track.trackArtistNames!
                                              .sublist(0, 2)
                                              .join(', ')),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    collection.playlistRemoveTrack(
                                        this.playlist, track);
                                  },
                                  icon: Icon(
                                    FluentIcons.subtract_circle_20_regular,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  iconSize: 20.0,
                                  splashRadius:
                                      Theme.of(context).iconTheme.size! - 8,
                                ),
                              );
                            }).toList()),
                      )
                    : Center(
                        child: Text(
                          'This playlist is empty.',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
