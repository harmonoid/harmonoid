import 'dart:async';
import 'dart:io';
import 'package:harmonoid/language/constants.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/discover.dart';
import 'package:harmonoid/scripts/download.dart';
import 'package:harmonoid/scripts/vars.dart';


class LeadingDiscoverTrackTile extends StatefulWidget {
  final Track track;
  LeadingDiscoverTrackTile({Key key, @required this.track}) : super(key: key);
  _LeadingDiscoverTrackTileState createState() => _LeadingDiscoverTrackTileState();
}

class _LeadingDiscoverTrackTileState extends State<LeadingDiscoverTrackTile> {
  bool _isDownloading = false;
  double _progress;
  bool _exists = false;
  bool _init = true;
  StreamSubscription<DownloadTask> _taskStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (this._init) {
      bool inDownloadQueue = false;
      for (DownloadTask task in download.tasks) {
        if (task.extras.trackId == widget.track.trackId) {
          inDownloadQueue = true;
          this._exists = task.isCompleted;
        }
      }
      if (!inDownloadQueue) {
        File locationFile = File(
          path.join(
            MUSIC_DIRECTORY,
            '${widget.track.trackArtistNames.join(', ')}_${widget.track.trackName}'.replaceAll(new RegExp(r'[^\s\w]'),'') + '.OGG',
        ));
        if (await locationFile.exists()) {
          this.setState(() => this._exists = true);
        }
      }
      this._taskStream = download.taskStream?.listen((DownloadTask task) {
        if (task.extras.trackId == widget.track.trackId) {
          try {
            this.setState(() {
              this._progress = task.progress;
              this._isDownloading = !task.isCompleted;
              this._exists = task.isCompleted;
            });
          }
          catch(exception) {}
        }
      });
      this._init = false;
    }
  }

  @override
  void dispose() { 
    this._taskStream?.cancel();
    super.dispose();
  }

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9 ? '${durationSeconds - (minutes * 60)}' : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 16.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.track.albumArtHigh,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.low,
              alignment: Alignment.topCenter,
              height: 156.0,
              width: MediaQuery.of(context).size.width - 16.0,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (this._isDownloading || this._exists) ? null: () {
                  this.setState(() => this._isDownloading = true);
                  discover.trackDownload(
                    widget.track,
                    onCompleted: () => this.setState(() {
                      this._isDownloading = false;
                      this._exists = true;
                    }),
                    onException: (DownloadException exception) {
                      if (exception.type == DownloadExceptionType.connection) {
                        showDialog(
                          context: context,
                          builder: (subContext) => AlertDialog(
                            title: Text(
                              Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE,
                              style: Theme.of(subContext).textTheme.headline1,
                            ),
                            content: Text(
                              Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE,
                              style: Theme.of(subContext).textTheme.headline5,
                            ),
                            actions: [
                              MaterialButton(
                                textColor: Theme.of(context).primaryColor,
                                onPressed: Navigator.of(subContext).pop,
                                child: Text(Constants.STRING_OK),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        showDialog(
                          context: context,
                          builder: (subContext) => AlertDialog(
                            title: Text(
                              Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE,
                              style: Theme.of(subContext).textTheme.headline1,
                            ),
                            content: Text(
                              Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE,
                              style: Theme.of(subContext).textTheme.headline5,
                            ),
                            actions: [
                              MaterialButton(
                                textColor: Theme.of(context).primaryColor,
                                onPressed: Navigator.of(subContext).pop,
                                child: Text(Constants.STRING_OK),
                              ),
                            ],
                          ),
                        );
                      }
                      this.setState(() {
                        this._isDownloading = false;
                      });
                    },
                    onProgress: (double progress) {
                      try {
                        this.setState(() => this._progress = progress);
                      }
                      catch (exception) {}
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        alignment: Alignment.center,
                        child: this._isDownloading ? CircularProgressIndicator(
                          value: this._progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ): CircleAvatar(
                          child: this._exists ? Icon(Icons.check) : Text('${widget.track.trackNumber ?? 1}'),
                          backgroundImage: NetworkImage(widget.track.albumArtLow),
                          foregroundColor: Colors.white,
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
                              widget.track.trackName,
                              style: Theme.of(context).textTheme.headline1,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                            ),
                            Text(
                              widget.track.albumName,
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                            ),
                            Text(
                              widget.track.trackArtistNames.length < 2 ? 
                              widget.track.trackArtistNames.join(', ') : 
                              widget.track.trackArtistNames.sublist(0, 2).join(', '),
                              style: Theme.of(context).textTheme.headline5,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20.0),
                        alignment: Alignment.center,
                        child: this._exists ? Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: Text(
                            Constants.STRING_SAVED,
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                          ) :Text(this._getDurationString(widget.track.trackDuration)),
                      ),
                    ],
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


class DiscoverTrackTile extends StatefulWidget {
  final Track track;
  DiscoverTrackTile({Key key, @required this.track}) : super(key: key);
  _DiscoverTrackTileState createState() => _DiscoverTrackTileState();
}

class _DiscoverTrackTileState extends State<DiscoverTrackTile> {
  bool _isDownloading = false;
  double _progress;
  bool _exists = false;
  bool _init = true;
  StreamSubscription<DownloadTask> _taskStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (this._init) {
      bool inDownloadQueue = false;
      for (DownloadTask task in download.tasks) {
        if (task.extras.trackId == widget.track.trackId) {
          inDownloadQueue = true;
          this._exists = task.isCompleted;
        }
      }
      if (!inDownloadQueue) {
        File locationFile = File(
          path.join(
            MUSIC_DIRECTORY,
            '${widget.track.trackArtistNames.join(', ')}_${widget.track.trackName}'.replaceAll(new RegExp(r'[^\s\w]'),'') + '.OGG',
        ));
        if (await locationFile.exists()) {
          this.setState(() => this._exists = true);
        }
      }
      this._taskStream = download.taskStream?.listen((DownloadTask task) {
        if (task.extras.trackId == widget.track.trackId) {
          try {
            this.setState(() {
              this._progress = task.progress;
              this._isDownloading = !task.isCompleted;
              this._exists = task.isCompleted;
            });
          }
          catch(exception) {}
        }
      });
      this._init = false;
    }
  }

  @override
  void dispose() { 
    this._taskStream?.cancel();
    super.dispose();
  }

  String _getDurationString(int durationSeconds) {
    int minutes = durationSeconds ~/ 60;
    String seconds = durationSeconds - (minutes * 60) > 9 ? '${durationSeconds - (minutes * 60)}' : '0${durationSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
        child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            if (!(this._isDownloading || this._exists)) {
              this.setState(() => this._isDownloading = true);
              discover.trackDownload(
                widget.track,
                onCompleted: () => this.setState(() {
                  this._isDownloading = false;
                  this._exists = true;
                }),
                onException: (DownloadException exception) {
                  if (exception.type == DownloadExceptionType.connection) {
                    showDialog(
                      context: context,
                      builder: (subContext) => AlertDialog(
                        title: Text(
                          Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE,
                          style: Theme.of(subContext).textTheme.headline1,
                        ),
                        content: Text(
                          Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE,
                          style: Theme.of(subContext).textTheme.headline5,
                        ),
                        actions: [
                          MaterialButton(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: Navigator.of(subContext).pop,
                            child: Text(Constants.STRING_OK),
                          ),
                        ],
                      ),
                    );
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (subContext) => AlertDialog(
                        title: Text(
                          Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE,
                          style: Theme.of(subContext).textTheme.headline1,
                        ),
                        content: Text(
                          Constants.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE,
                          style: Theme.of(subContext).textTheme.headline5,
                        ),
                        actions: [
                          MaterialButton(
                            textColor: Theme.of(context).primaryColor,
                            onPressed: Navigator.of(subContext).pop,
                            child: Text(Constants.STRING_OK),
                          ),
                        ],
                      ),
                    );
                  }
                  this.setState(() {
                    this._isDownloading = false;
                  });
                },
                onProgress: (double progress) {
                  try {
                    this.setState(() => this._progress = progress);
                  }
                  catch (exception) {}
                },
              );
            }
          },
          enabled: !(this._isDownloading || this._exists),
          title: Text(widget.track.trackName),
          subtitle: Text(widget.track.trackArtistNames.join(', ')),
          leading: this._isDownloading ? CircularProgressIndicator(
            value: this._progress,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
          ): CircleAvatar(
            child: this._exists ? Icon(Icons.check) : Text('${widget.track.trackNumber ?? 1}'),
            backgroundImage: NetworkImage(widget.track.albumArtLow),
            foregroundColor: Colors.white,
          ),
          trailing: this._exists ? Chip(
            avatar: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            label: Text(
              Constants.STRING_SAVED,
              style: TextStyle(
                color: Colors.white
              ),
            ),
            backgroundColor: Theme.of(context).accentColor,
            ) :Text(this._getDurationString(widget.track.trackDuration)),
        ),
      ),
    );
  }
}