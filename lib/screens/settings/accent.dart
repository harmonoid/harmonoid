import 'package:flutter/material.dart';

import 'package:harmonoid/screens/settings/settings.dart';
import 'package:harmonoid/scripts/configuration.dart';
import 'package:harmonoid/scripts/states.dart';
import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/scripts/vars.dart';


class AccentSetting extends StatefulWidget {
  AccentSetting({Key key}) : super(key: key);
  AccentState createState() => AccentState();
}


class AccentState extends State<AccentSetting> with TickerProviderStateMixin {
  bool _init = true;
  Widget _widget = Container();
  List<AnimationController> _animationControllers = new List<AnimationController>(ACCENT_COLORS.length); 
  List<Animation<double>> _animations = new List<Animation<double>>(ACCENT_COLORS.length);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._init) {
      List<Widget> children = <Widget>[];
      ACCENT_COLORS.asMap().forEach((int index, List<Color> accentColor) {
        int accentColorIndex = index;
        this._animationControllers[accentColorIndex] = new AnimationController(
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
          lowerBound: 0.0,
          upperBound: 1.0,
          vsync: this,
        );
        this._animations[accentColorIndex] = new Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(this._animationControllers[accentColorIndex]);
        if (accentColorIndex == configuration.accentColor) this._animationControllers[accentColorIndex].forward();
        children.add(
          new ClipRRect(
            borderRadius: BorderRadius.all(
              new Radius.circular(4.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Container(
                  height: 56.0,
                  width: 56.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor[0],
                        accentColor[1],
                      ],
                      stops: [
                        0.2,
                        1.0,
                      ]
                    )
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      this._animationControllers.asMap().forEach((int controllerIndex, AnimationController controller) {
                        if (accentColorIndex == controllerIndex) this._animationControllers[controllerIndex].forward();
                        else this._animationControllers[controllerIndex].reverse();
                      });
                      configuration.save(
                        accentColor: accentColorIndex,
                      );
                      Future.delayed(Duration(milliseconds: 200), () {
                        States?.refreshThemeData();
                      });
                    },
                    child: ScaleTransition(
                      scale: this._animations[accentColorIndex],
                      alignment: Alignment.center,
                      child: Container(
                        child: Icon(Icons.check, color: Colors.white, size: 28.0),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
      this._widget = new Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: GridView.extent(
          maxCrossAxisExtent: 56.0 + 8.0,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          childAspectRatio: 1.0,
          children: children,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
      );
      this._init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Constants.STRING_SETTING_ACCENT_COLOR_TITLE,
      subtitle: Constants.STRING_SETTING_ACCENT_COLOR_SUBTITLE,
      child: Column(
        children: [
          CheckboxListTile(
            value: configuration.automaticAccent,
            onChanged: (bool isChecked) async {
              await configuration.save(
                automaticAccent: isChecked,
              );
              this.setState(() {});
            },
            title: Text('Automatic Accent'),
          ),
          this._widget,
        ],
      ),
      margin: EdgeInsets.only(bottom: 16.0),
    );
  }
}
