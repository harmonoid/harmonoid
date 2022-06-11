import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/state/visuals.dart';
import 'package:harmonoid/state/lyrics.dart';

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Visuals(
        accent: Configuration.instance.accent,
        themeMode: Configuration.instance.themeMode,
        context: context,
      ),
      builder: (_, __) => Consumer<Visuals>(
        builder: (_, visuals, __) => MultiProvider(
          builder: (_, __) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: visuals.theme,
            darkTheme: visuals.darkTheme,
            themeMode: visuals.themeMode,
            home: Home(),
          ),
          providers: [
            ChangeNotifierProvider(create: (_) => Playback.instance),
            ChangeNotifierProvider(create: (_) => Lyrics.instance),
          ],
        ),
      ),
    );
  }
}
