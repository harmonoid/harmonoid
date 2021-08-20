import 'package:flutter/material.dart';
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
      builder: (context, collection, _) => ListView(children: [
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
                          language!.STRING_PLAYLISTS,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          language!.STRING_PLAYLISTS_SUBHEADER,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.9),
                            fontSize: 14.0,
                          ),
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
                          language!.STRING_PLAYLISTS_CREATE,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.9),
                            fontSize: 14.0,
                          ),
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: this._textFieldController,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.9),
                                    fontSize: 14.0,
                                  ),
                                  cursorWidth: 1,
                                  autofocus: true,
                                  autocorrect: true,
                                  onSubmitted: (String value) async {
                                    if (value != '') {
                                      FocusScope.of(context).unfocus();
                                      await collection.playlistAdd(
                                          new Playlist(playlistName: value));
                                      this._textFieldController.clear();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: language!
                                        .STRING_PLAYLISTS_TEXT_FIELD_LABEL,
                                    hintText: language!
                                        .STRING_PLAYLISTS_TEXT_FIELD_HINT,
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(0.9),
                                      fontSize: 14.0,
                                    ),
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).accentColor),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 1)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 1)),
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
                                      await collection.playlistAdd(new Playlist(
                                          playlistName:
                                              this._textFieldController.text));
                                      this._textFieldController.clear();
                                    }
                                  },
                                  icon: Icon(
                                    FluentIcons.checkmark_12_regular,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  iconSize: 24.0,
                                  splashRadius: 20,
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
                          builder: (subContext) => AlertDialog(
                            title: Text(
                              language!
                                  .STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER,
                              style: Theme.of(subContext).textTheme.headline1,
                            ),
                            content: Text(
                              language!
                                  .STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY,
                              style: Theme.of(subContext).textTheme.headline5,
                            ),
                            actions: [
                              MaterialButton(
                                textColor: Theme.of(context).primaryColor,
                                onPressed: () async {
                                  await collection.playlistRemove(playlist);
                                  Navigator.of(subContext).pop();
                                },
                                child: Text(language!.STRING_YES),
                              ),
                              MaterialButton(
                                textColor: Theme.of(context).primaryColor,
                                onPressed: Navigator.of(subContext).pop,
                                child: Text(language!.STRING_NO),
                              ),
                            ],
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
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.9),
                            fontSize: 14.0,
                          ),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NavigatorPopButton(),
                  SizedBox(
                    width: 24.0,
                  ),
                  Text(
                    this.playlist.playlistName!,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                      SubHeader(language!.STRING_PLAYLIST_TRACKS_SUBHEADER),
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
                          splashRadius: Theme.of(context).iconTheme.size! - 8,
                        ),
                      );
                    }).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
