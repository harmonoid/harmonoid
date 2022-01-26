import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/change_notifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';

GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Visuals>(
      create: (context) => Visuals(
        accent: configuration.accent,
        themeMode: configuration.themeMode,
        context: context,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: visuals.theme,
          darkTheme: visuals.darkTheme,
          themeMode: visuals.themeMode!,
          navigatorKey: key,
          home: Home(),
        ),
      ),
    );
  }
}
