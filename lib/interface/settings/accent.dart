/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/constants/language.dart';

class AccentSetting extends StatefulWidget {
  AccentSetting({Key? key}) : super(key: key);
  AccentState createState() => AccentState();
}

class AccentState extends State<AccentSetting> with TickerProviderStateMixin {
  List<AnimationController> animationControllers = <AnimationController>[];

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: Language.instance.SETTING_ACCENT_COLOR_TITLE,
      subtitle: Language.instance.SETTING_ACCENT_COLOR_SUBTITLE,
      child: Consumer<Visuals>(
        builder: (context, visuals, _) => Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: GridView.extent(
                maxCrossAxisExtent: 56.0 + 8.0,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                childAspectRatio: 1.0,
                children: kAccents.map((accent) {
                  animationControllers.add(
                    AnimationController(
                      vsync: this,
                      duration: Duration(milliseconds: 200),
                      reverseDuration: Duration(milliseconds: 200),
                      lowerBound: 0.0,
                      upperBound: 1.0,
                    ),
                  );
                  if (accent == visuals.accent)
                    animationControllers.last.forward();
                  return Container(
                    height: 56.0,
                    width: 56.0,
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
                                accent.light,
                                accent.dark,
                              ],
                              stops: [
                                0.2,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 56.0,
                          width: 56.0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                animationControllers.asMap().forEach(
                                    (int controllerIndex,
                                        AnimationController controller) {
                                  if (kAccents.indexOf(accent) ==
                                      controllerIndex) {
                                    animationControllers[controllerIndex]
                                        .forward();
                                    visuals.update(
                                      accent: accent,
                                    );
                                  } else
                                    animationControllers[controllerIndex]
                                        .reverse();
                                });
                              },
                              child: ScaleTransition(
                                scale: animationControllers.last,
                                alignment: Alignment.center,
                                child: Container(
                                  child: Icon(
                                      FluentIcons.checkmark_circle_48_regular,
                                      color: Colors.white,
                                      size: 28.0),
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
            ),
          ],
        ),
      ),
      margin: EdgeInsets.only(bottom: 16.0),
    );
  }
}
