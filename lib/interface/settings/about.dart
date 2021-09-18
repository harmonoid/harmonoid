import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/interface/settings/about/aboutpage.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 400),
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      closedElevation: 0.0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      openElevation: 0.0,
      closedBuilder: (context, open) => ClosedTile(
        open: open,
        title: language!.STRING_ABOUT_TITLE,
        subtitle: language!.STRING_ABOUT_SUBTITLE,
      ),
      openBuilder: (context, _) => AboutPage(),
    );
  }
}
