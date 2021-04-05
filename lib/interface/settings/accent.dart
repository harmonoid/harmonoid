import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/settings/settings.dart';
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
      title: language!.STRING_SETTING_ACCENT_COLOR_TITLE,
      subtitle: language!.STRING_SETTING_ACCENT_COLOR_SUBTITLE,
      child: Consumer<Visuals>(
        builder: (context, visuals, _) => Column(
          children: [
            // TODO: Re-implement automatic accent colors using Provider.
            // SwitchListTile(
            //   value: configuration.automaticAccent!,
            //   onChanged: (bool isChecked) async {
            //     await configuration.save(
            //       automaticAccent: isChecked,
            //     );
            //     this.setState(() {});
            //   },
            //   title: Text(language!.STRING_SETTING_ACCENT_COLOR_AUTOMATIC),
            // ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: GridView.extent(
                maxCrossAxisExtent: 56.0 + 8.0,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                childAspectRatio: 1.0,
                children: accents.map(
                  (accent) {
                    this.animationControllers.add(
                      new AnimationController(
                        vsync: this,
                        duration: Duration(milliseconds: 200),
                        reverseDuration: Duration(milliseconds: 200),
                        lowerBound: 0.0,
                        upperBound: 1.0,
                      ),
                    );
                    if (accent == visuals.accent)
                      this.animationControllers.last.forward();
                    return Stack(
                      children: [
                        Container(
                          height: 56.0,
                          width: 56.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent!.light,
                                accent.dark,
                              ],
                              stops: [
                                0.2,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: () async {
                              this.animationControllers.asMap().forEach( 
                                (int controllerIndex, AnimationController controller) {
                                  if (accents.indexOf(accent) == controllerIndex) {
                                    this.animationControllers[controllerIndex].forward();
                                    visuals.update(
                                      accent: accent,
                                    );
                                  }
                                  else
                                    this.animationControllers[controllerIndex].reverse();
                                }
                              );
                            },
                            child: ScaleTransition(
                              scale: this.animationControllers.last,
                              alignment: Alignment.center,
                              child: Container(
                                child:
                                    Icon(Icons.check, color: Colors.white, size: 28.0),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ).toList(),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
            ),
          ],
        ),
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}
