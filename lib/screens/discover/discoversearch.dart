import 'package:flutter/material.dart';

import 'package:harmonoid/constants/constants.dart';


class DiscoverSearch extends StatefulWidget {
  final String keyword;
  final dynamic mode;
  DiscoverSearch({Key key, @required this.keyword, @required this.mode}) : super(key: key);
  DiscoverSearchState createState() => DiscoverSearchState();
}


class DiscoverSearchState extends State<DiscoverSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              iconSize: Theme.of(context).iconTheme.size,
              splashRadius: Theme.of(context).iconTheme.size - 8,
              onPressed: Navigator.of(context).pop,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(Constants.STRING_ALBUM),
            ),
            expandedHeight: 156.0,
            forceElevated: true,
          ),
        ],
      ),
    );
  }
}
