import 'dart:io';
import 'package:flutter/gestures.dart';
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
            scrollBehavior: const ScrollBehavior(),
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

class ScrollBehavior extends MaterialScrollBehavior {
  const ScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const ClampingScrollPhysics();
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        );
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices =>
      // Specifically for GNU/Linux & Android-x86 family, where touch isn't interpreted as a drag device by Flutter apparently.
      (Platform.isLinux || Platform.isAndroid)
          ? PointerDeviceKind.values.toSet()
          : super.dragDevices;
}
