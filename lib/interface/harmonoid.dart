import 'dart:io';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';

GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Visuals>(
      create: (context) => Visuals(
        accent: configuration.accent,
        themeMode: Hive.box('configuration').get('themeMode') ?? defaultThemeMode,
        context: context,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: visuals.theme,
          darkTheme: visuals.darkTheme,
          themeMode: ThemeMode.values[Hive.box('configuration').get('themeMode') ?? defaultThemeMode],
          navigatorKey: key,
          builder: (context, child) {
            if (Platform.isAndroid)
              return ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: child!,
              );
            return child!;
          },
          home: FractionallyScaledWidget(
            child: Home(),
          ),
        ),
      ),
    );
  }
}
