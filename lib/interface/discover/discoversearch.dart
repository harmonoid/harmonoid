import 'package:flutter/material.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/discover.dart';
import 'package:harmonoid/interface/discover/discoveralbum.dart';
import 'package:harmonoid/interface/discover/discovertrack.dart';
import 'package:harmonoid/utils/methods.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';


class DiscoverSearch extends StatefulWidget {
  final String keyword;
  final MediaType mode;
  DiscoverSearch({Key? key, required this.keyword, required this.mode}) : super(key: key);
  DiscoverSearchState createState() => DiscoverSearchState();
}


class DiscoverSearchState extends State<DiscoverSearch> {
  late int _elementsPerRow;
  late double _tileWidth;
  late double _tileHeight;
  bool _init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
      this._tileWidth = (MediaQuery.of(context).size.width - 16 - (this._elementsPerRow - 1) * 8) / this._elementsPerRow;
      this._tileHeight = this._tileWidth * 242 / 156;
    }
    this._init = false;
  }

  Widget get result {
    if (widget.mode is Album)
      return FadeFutureBuilder(
        future: () async => await discover.search(widget.keyword, widget.mode),
        initialWidgetBuilder: (BuildContext context) => FakeLinearProgressIndicator(
          label: language!.STRING_SEARCH_RESULT_LOADER_LABEL,
          duration: Duration(seconds: 10),
          width: 148.0,
          margin: EdgeInsets.only(top: 196.0),
        ),
        finalWidgetBuilder: (BuildContext context, Object? data) => Column(
          children: tileGridListWidgets(
            context: context,
            tileHeight: this._tileHeight,
            tileWidth: this._tileWidth,
            elementsPerRow: this._elementsPerRow,
            leadingSubHeader: language!.STRING_SEARCH_RESULT_TOP_SUBHEADER_ALBUM,
            subHeader: language!.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ALBUM,
            leadingWidget: LeadingDiscoverAlbumTile(
              height: this._tileWidth,
              album: (data as List<dynamic>).first,
            ),
            widgetCount: data.length,
            builder: (BuildContext context, int index) => DiscoverAlbumTile(
              album: data[index],
              height: this._tileHeight,
              width: this._tileWidth,
            )
          ),
        ),
        errorWidgetBuilder: (_, Object exception) => ExceptionWidget(
          margin: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          height: 156.0,
          assetImage: 'assets/images/exception.jpg',
          title: language!.STRING_NO_INTERNET_TITLE,
          subtitle: language!.STRING_NO_INTERNET_SUBTITLE,
        ),
        transitionDuration: Duration(milliseconds: 400),
      );
    else if (widget.mode is Track)
      return FadeFutureBuilder(
        future: () async => await discover.search(widget.keyword, widget.mode),
        initialWidgetBuilder: (BuildContext context) => FakeLinearProgressIndicator(
          label: language!.STRING_SEARCH_RESULT_LOADER_LABEL,
          duration: Duration(seconds: 10),
          width: 148.0,
          margin: EdgeInsets.only(top: 196.0),
        ),
        finalWidgetBuilder: (BuildContext context, Object? data) => Column(
          children: <Widget>[
            SubHeader(language!.STRING_SEARCH_RESULT_TOP_SUBHEADER_TRACK),
            LeadingDiscoverTrackTile(
              track: (data as List<dynamic>)[0],
            ),
            SubHeader(language!.STRING_SEARCH_RESULT_OTHER_SUBHEADER_TRACK)
          ] + data.map(
            (dynamic track) => DiscoverTrackTile(
              track: track,
            ),
          ).toList(),
        ),
        errorWidgetBuilder: (_, Object exception) => ExceptionWidget(
          margin: EdgeInsets.only(top: 56.0, left: 8.0, right: 8.0),
          height: 156.0,
          assetImage: 'assets/images/exception.jpg',
          title: language!.STRING_NO_INTERNET_TITLE,
          subtitle: language!.STRING_NO_INTERNET_SUBTITLE,
        ),
        transitionDuration: Duration(milliseconds: 400),
      );
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            snap: false,
            pinned: false,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              iconSize: Theme.of(context).iconTheme.size!,
              splashRadius: Theme.of(context).iconTheme.size! - 8,
              onPressed: Navigator.of(context).pop,
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).accentColor: Theme.of(context).appBarTheme.color,
            brightness: Brightness.dark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                Methods.mediaTypeToLanguage(widget.mode)!,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              background: Image.asset(
                'assets/images/discover-${widget.mode.type!.toLowerCase()}s.jpg',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            expandedHeight: 148.0,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                this.result,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
