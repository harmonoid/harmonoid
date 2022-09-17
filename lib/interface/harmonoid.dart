import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/constants/language.dart';

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Visuals(
        light: kPrimaryLightColor,
        dark: kPrimaryDarkColor,
        themeMode: Configuration.instance.themeMode,
        context: context,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MultiProvider(
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: visuals.theme,
            darkTheme: visuals.darkTheme,
            themeMode: visuals.themeMode,
            home: Home(),
          ),
          providers: [
            ChangeNotifierProvider(
              create: (context) => Language.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => Playback.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => Lyrics.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => NowPlayingColorPalette.instance,
            ),
          ],
        ),
      ),
    );
  }
}
