import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/constants/language.dart';

class DiscoverMusic extends StatefulWidget {
  const DiscoverMusic({Key? key}) : super(key: key);
  DiscoverMusicState createState() => DiscoverMusicState();
}

class DiscoverMusicState extends State<DiscoverMusic> {
  Widget? child;
  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoverController>(
      builder: (context, discover, _) => Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(8.0),
                height: 56.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
                width: MediaQuery.of(context).size.width - 16,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24.0,
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        cursorWidth: 1.0,
                        style: Theme.of(context).textTheme.headline4,
                        onSubmitted: (String query) async {
                          this.setState(() {
                            this.child = Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          });
                          List<Track> tracks =
                              await discover.instance.search(query);
                          this.child = tracks.isNotEmpty
                              ? ListView(
                                  children: tracks
                                      .map(
                                        (track) => ListTile(
                                          onTap: () => Playback.play(
                                            index: 0,
                                            tracks: [
                                              track,
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                track.networkAlbumArt!),
                                          ),
                                          title: Text(track.trackName!),
                                          subtitle: Text(track.trackArtistNames!
                                              .join(', ')),
                                          trailing: IconButton(
                                            onPressed: () => Playback.play(
                                              index: 0,
                                              tracks: [
                                                track,
                                              ],
                                            ),
                                            icon: Icon(
                                              FluentIcons
                                                  .play_circle_20_regular,
                                              size: 20.0,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                            iconSize: Theme.of(context)
                                                .iconTheme
                                                .size!,
                                            splashRadius: Theme.of(context)
                                                    .iconTheme
                                                    .size! -
                                                8,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Center(
                                  child: Text(
                                    language!.STRING_DISCOVER_NO_RESULTS,
                                  ),
                                );
                          this.setState(() {});
                        },
                        decoration: InputDecoration.collapsed(
                          hintText: language!.STRING_SEARCH,
                          hintStyle: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24.0,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: child ??
                    Center(
                      child: Text(
                        language!.STRING_DISCOVER_WELCOME,
                      ),
                    ),
              ),
            ],
          ),
          discover.state != ''
              ? Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF242424),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.all(16.0),
                  height: 56.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        discover.state,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
