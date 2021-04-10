import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';


class CollectionPlaylistTab extends StatelessWidget {
  final TextEditingController _textFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, _) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
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
                              Text(language!.STRING_PLAYLISTS, style: Theme.of(context).textTheme.headline1),
                              Text(language!.STRING_PLAYLISTS_SUBHEADER, style: Theme.of(context).textTheme.headline5),
                            ],
                          ),
                        ),
                        PageStorage(
                          bucket: PageStorageBucket(),
                          child: ExpansionTile(
                            maintainState: false,
                            initiallyExpanded: false,
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
                            title: Text(language!.STRING_PLAYLISTS_CREATE, style: Theme.of(context).textTheme.headline2),
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
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: language!.STRING_PLAYLISTS_TEXT_FIELD_LABEL,
                                        hintText: language!.STRING_PLAYLISTS_TEXT_FIELD_HINT,
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
                        ),
                      ] + collection.playlists.map(
                        (Playlist playlist) =>ListTile(
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
                                language!.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER,
                                style: Theme.of(subContext).textTheme.headline1,
                              ),
                              content: Text(
                                language!.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY,
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
                          leading: playlist.tracks.length != 0 ? CircleAvatar(
                            backgroundImage: FileImage(playlist.tracks.last.albumArt),
                          ) : Icon(
                            Icons.queue_music,
                            size: Theme.of(context).iconTheme.size,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          title: Text(playlist.playlistName!),
                          trailing: IconButton(
                            onPressed: () => Playback.play(
                              index: 0,
                              tracks: playlist.tracks,
                            ),
                            icon: Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            iconSize: Theme.of(context).iconTheme.size!,
                            splashRadius: Theme.of(context).iconTheme.size! - 8,
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                )
              ]
            ),
          ),
        ],
      ),
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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            iconSize: Theme.of(context).iconTheme.size!,
            splashRadius: Theme.of(context).iconTheme.size! - 8,
            onPressed: Navigator.of(context).pop,
          ),
          title: Text(this.playlist.playlistName!),
        ),
        body: ListView(
          children: <Widget>[
            SubHeader(language!.STRING_PLAYLIST_TRACKS_SUBHEADER),
          ] + (this.playlist.tracks.map((Track track) {
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
                track.albumName! + '\n' + 
                (track.trackArtistNames!.length < 2 ? 
                track.trackArtistNames!.join(', ') : 
                track.trackArtistNames!.sublist(0, 2).join(', ')),
              ),
              trailing: IconButton(
                onPressed: () {
                  collection.playlistRemoveTrack(this.playlist, track);
                },
                icon: Icon(
                  Icons.remove,
                  color: Theme.of(context).iconTheme.color,
                ),
                iconSize: Theme.of(context).iconTheme.size!,
                splashRadius: Theme.of(context).iconTheme.size! - 8,
              ),
            );
          }).toList()),
        ),
      ),
    );
  }
}
