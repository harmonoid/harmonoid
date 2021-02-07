import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/scripts/mediatype.dart';
import 'package:harmonoid/screens/discover/discoversearch.dart';
import 'package:harmonoid/language/constants.dart';


class DiscoverMusic extends StatefulWidget {
  DiscoverMusic({Key key}) : super(key: key);
  DiscoverMusicState createState() => DiscoverMusicState();
}

class DiscoverMusicState extends State<DiscoverMusic> with TickerProviderStateMixin {
  bool _init = true;
  int _searchMode = 0;
  List<dynamic> _recentSearches = <dynamic>[];
  // ignore: unused_field
  Animation<double> _menuButtonAnimation;
  AnimationController _menuButtonAnimationController;
  TextEditingController _textFieldController = new TextEditingController();
  AnimationController _searchBarAnimation;
  AnimationController _animationController;
  List<AnimationController> _searchModeAnimationScaleController = new List<AnimationController>(mediaTypes.length);
  List<Animation<Color>> _searchModeAnimationColor = new List<Animation<Color>>(mediaTypes.length);
  List<AnimationController> _searchModeAnimationColorController = new List<AnimationController>(mediaTypes.length);
  Animation<double> _searchBarHeight;
  Animation<Offset> _offset;
  bool _isBackButtonShowing = true;

  void show() => this._searchBarAnimation.reverse();

  void hide() => this._searchBarAnimation.forward();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      this._menuButtonAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      );

      this._menuButtonAnimation = CurvedAnimation(
        curve: Curves.linear,
        parent: this._menuButtonAnimationController,
      );
      this._animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 200),
      );
      this._searchBarHeight = Tween<double>(
        begin: 56.0,
        end: 56.0 + 3 * 56.0 + 2.0,
      ).animate(new CurvedAnimation(
        parent: this._animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));
      this._searchBarAnimation = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 200),
      );
      this._offset = Tween<Offset>(
        begin: Offset(0.0, 0.0),
        end: Offset(0.0, -0.76),
      ).animate(new CurvedAnimation(
        parent: this._searchBarAnimation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ));
      for (int index = 0; index < mediaTypes.length; index++) {
        this._searchModeAnimationScaleController[index] = new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
          lowerBound: 1.0,
          upperBound: 1.4,
        );
        this._searchModeAnimationColorController[index] = new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        );
        this._searchModeAnimationColor[index] = new Tween<Color>(
          begin: Theme.of(context).iconTheme.color,
          end: Theme.of(context).primaryColor,
        ).animate(this._searchModeAnimationColorController[index]);
      }
      this._changeSearchMode(0);
      this._init = false;
      this._recentSearches = configuration.discoverSearchRecent;
      this.setState(() {});
    }
  }

  void _changeSearchMode(int selectedIndex) {
    this._searchMode = selectedIndex;
    for (int index = 0; index < mediaTypes.length; index++) {
      if (index == selectedIndex) {
        this._searchModeAnimationScaleController[index].forward();
        this._searchModeAnimationColorController[index].forward();
      }
      else {
        this._searchModeAnimationScaleController[index].reverse();
        this._searchModeAnimationColorController[index].reverse();
      }
    }
  }

  void _search({String keyword, MediaType mode}) {
    if (this._textFieldController.text != '' || (keyword != null && mode != null)) {
      Navigator.of(context).push(new PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => DiscoverSearch(
          keyword: keyword ?? this._textFieldController.text,
          mode: mode ?? mediaTypes[this._searchMode],
        ),
      ));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0.0,
        elevation: 0.0,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SlideTransition(
            position: this._offset,
            child: Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: Card(
                elevation: 2.0,
                clipBehavior: Clip.antiAlias,
                child: AnimatedBuilder(
                  animation: this._searchBarHeight,
                  child: Material(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              child: IconButton(
                                icon: AnimatedIcon(
                                progress: this._menuButtonAnimationController,
                                  icon: AnimatedIcons.menu_arrow,
                                  size: Theme.of(context).iconTheme.size,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                splashRadius: Theme.of(context).iconTheme.size - 8,
                                onPressed: () {
                                  if (!this._isBackButtonShowing) {
                                    this._animationController.reverse();
                                    if (this._menuButtonAnimationController.isDismissed) this._menuButtonAnimationController.forward();
                                    if (this._menuButtonAnimationController.isCompleted) this._menuButtonAnimationController.reverse();
                                    this.setState(() => _isBackButtonShowing = true);
                                  }
                                },
                              ),
                              margin: EdgeInsets.only(right: 16.0),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  this._animationController.forward();
                                  if (this._menuButtonAnimationController.isDismissed) this._menuButtonAnimationController.forward();
                                  if (this._menuButtonAnimationController.isCompleted) this._menuButtonAnimationController.reverse();
                                  this.setState(() => _isBackButtonShowing = false);
                                },
                                child: this._isBackButtonShowing ? Text(
                                  Constants.STRING_SEARCH_HEADER,
                                  style: Theme.of(context).textTheme.headline3
                                ) : TextField(
                                  autofocus: true,
                                  controller: this._textFieldController,
                                  cursorWidth: 1.0,
                                  onEditingComplete: () => this._search(),
                                  decoration: InputDecoration.collapsed(hintText: Constants.STRING_SEARCH_HEADER),
                                ),
                              ),
                            ),
                            Container(
                              height: 56,
                              width: 56,
                              child: IconButton(
                                icon: Icon(Icons.search),
                                splashRadius: Theme.of(context).iconTheme.size - 8,
                                onPressed: () => this._search(),
                              ),
                            ),
                          ],
                        ),
                        this._isBackButtonShowing ? Container(): Divider(
                          height: 2.0,
                          thickness: 1.0,
                          color: Theme.of(context).dividerColor,
                        ),
                        this._isBackButtonShowing ? Container(): ListTile(
                          leading: ScaleTransition(
                            scale: this._searchModeAnimationScaleController[0],
                            child: AnimatedBuilder(
                              animation: this._searchModeAnimationColor[0],
                              builder: (BuildContext context, _) => Icon(Icons.album, color: this._searchModeAnimationColor[0].value),
                            ),
                          ),
                          title: Text(Constants.STRING_ALBUM,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          onTap: () => _changeSearchMode(0),
                        ),
                        this._isBackButtonShowing ? Container(): ListTile(
                          leading: ScaleTransition(
                            scale: this._searchModeAnimationScaleController[1],
                            child: AnimatedBuilder(
                              animation: this._searchModeAnimationColor[1],
                              builder: (BuildContext context, _) => Icon(Icons.music_note, color: this._searchModeAnimationColor[1].value),
                            ),
                          ),
                          title: Text(Constants.STRING_TRACK,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          trailing: Text('[WIP]'),
                          onTap: () => _changeSearchMode(1),
                        ),
                        this._isBackButtonShowing ? Container(): ListTile(
                          leading: ScaleTransition(
                            scale: this._searchModeAnimationScaleController[2],
                            child: AnimatedBuilder(
                              animation: this._searchModeAnimationColor[2],
                              builder: (BuildContext context, _) => Icon(Icons.person, color: this._searchModeAnimationColor[2].value),
                            ),
                          ),
                          title: Text(Constants.STRING_ARTIST,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          trailing: Text('[WIP]'),
                          onTap: () => _changeSearchMode(2),
                        ),
                      ],
                    ),
                  ),
                  builder: (BuildContext context, Widget child) {
                    return Container(
                      height: this._searchBarHeight.value,
                      width: MediaQuery.of(context).size.width - 16.0,
                      color: Theme.of(context).cardColor,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
          this._recentSearches.isNotEmpty ? Container(
            margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Card(
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: this._recentSearches.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  leading: Icon(Icons.history),
                  dense: true,
                  title: Text(this._recentSearches[index][0],
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  subtitle: Text(this._recentSearches[index][1],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  onTap: () => this._search(
                    keyword: this._recentSearches[index][0],
                    mode: {
                      'Album': new Album(),
                      'Track': new Track(),
                      'Artist': new Artist(),
                    }[this._recentSearches[index][1]],
                  ),
                ),
              ),
            )
          ) : Container(
            margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Card(
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      Constants.STRING_SEARCH_NO_RECENT_SEARCHES,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}
