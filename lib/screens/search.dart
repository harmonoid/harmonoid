import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/constants/constants.dart';

class SearchBar extends StatefulWidget {

  SearchBar({Key key}) : super(key: key);
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  Animation<Offset> _offset;

  void show() => this._animationController.reverse();
  void hide() => this._animationController.forward();

  @override
  void initState() {
    super.initState();
    this._animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
    );
    this._offset = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, -0.76)
    ).animate(new CurvedAnimation(
      parent: this._animationController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: this._offset,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: MediaQuery.of(context).padding.top + 16),
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 400),
          closedElevation: 2,
          closedColor: Theme.of(context).scaffoldBackgroundColor,
          closedBuilder: (_, __) => Container(
            height: 56,
            width: MediaQuery.of(context).size.width - 32,
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  child: Icon(Icons.menu),
                ),
                Expanded(
                  child: Text(
                    Constants.STRING_SEARCH_HEADER,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                Container(
                  height: 56,
                  width: 56,
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
          openBuilder: (_, __) => Center(
            child: Text('Hello #1!')
          ),
        ),
      ),
    );
  }
}