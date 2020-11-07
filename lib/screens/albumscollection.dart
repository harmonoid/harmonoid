import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:harmonoid/constants/constants.dart';
import 'package:harmonoid/scripts/collection.dart';


class SubHeader extends StatelessWidget {

  final String text;
  SubHeader(this.text, {Key key}) : super(key: key);
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 36,
      margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}


class AlbumsCollection extends StatefulWidget {

  final Function showSearchBar;
  final Function hideSearchBar;
  AlbumsCollection({Key key, @required this.showSearchBar, @required this.hideSearchBar}) : super(key: key);
  AlbumsCollectionState createState() => AlbumsCollectionState();
}

class AlbumsCollectionState extends State<AlbumsCollection> {

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    this._scrollController.addListener(() {
      if (this._scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        widget.hideSearchBar();
      }
      else if (this._scrollController.position.userScrollDirection == ScrollDirection.forward) {
        widget.showSearchBar();
      }
    });
  }

  @override
  void dispose() {
    this._scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: ListView(
            controller: this._scrollController,
            padding: EdgeInsets.only(top: 56 + 32 + MediaQuery.of(context).padding.top),
            children: [
              SubHeader(Constants.STRING_LOCAL_TOP_SUBHEADER_ALBUM),
              Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                child: Container(
                  height: 156,
                  width: MediaQuery.of(context).size.width - 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.memory(
                        collection.getAlbumArt(collection.albums[collection.albums.length - 1].albumArtId),
                        fit: BoxFit.fill,
                        height: 156,
                        width: 156,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8, right: 8),
                        width: MediaQuery.of(context).size.width - 48 - 156,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Divider(
                              color: Colors.transparent,
                              height: 8,
                            ),
                            Container(
                              height: 38,
                              child: Text(
                                collection.albums[collection.albums.length - 1].albumName,
                                style: Theme.of(context).textTheme.headline1,
                                textAlign: TextAlign.start,
                                maxLines: 2,
                              ),
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 8,
                              thickness: 8,
                            ),
                            Text(
                              collection.albums[collection.albums.length - 1].artistNames.length < 2 ? 
                              collection.albums[collection.albums.length - 1].artistNames.join(', ') : 
                              collection.albums[collection.albums.length - 1].artistNames.sublist(0, 2).join(', '),
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '(${2012})',
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 4,
                              thickness: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SubHeader(Constants.STRING_LOCAL_OTHER_SUBHEADER_ALBUM),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: MediaQuery.of(context).size.width - 2 * (156 + 16),
                  mainAxisSpacing: 20,
                  childAspectRatio: 156 / 246,
                ),
                itemCount: collection.albums.length,
                itemBuilder: (_, int index) => Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  child: Container(
                    height: 246,
                    width: 156,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.memory(
                          collection.getAlbumArt(collection.albums[index].albumArtId),
                          fit: BoxFit.fill,
                          height: 156,
                          width: 156,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2, right: 2),
                          child: Column(
                            children: [
                              Divider(
                                color: Colors.transparent,
                                height: 8,
                              ),
                              Container(
                                height: 38,
                                child: Text(
                                  collection.albums[index].albumName,
                                  style: Theme.of(context).textTheme.headline2,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                              Divider(
                                color: Colors.transparent,
                                height: 8,
                                thickness: 8,
                              ),
                              Text(
                                collection.albums[index].artistNames.length < 2 ? 
                                collection.albums[index].artistNames.join(', ') : 
                                collection.albums[index].artistNames.sublist(0, 2).join(', '),
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '(${2012})',
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                              Divider(
                                color: Colors.transparent,
                                height: 4,
                                thickness: 4,
                              ),
                            ],
                          ),
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
