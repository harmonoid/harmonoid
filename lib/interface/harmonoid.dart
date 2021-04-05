import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/methods.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';

class Harmonoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Visuals>(
      create: (context) => Visuals(
        accent: configuration.accent,
        themeMode: configuration.themeMode,
        platform: configuration.platform,
      ),
      builder: (context, _) => Consumer<Visuals>(
        builder: (context, visuals, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: visuals.theme,
          darkTheme: visuals.darkTheme,
          themeMode: visuals.themeMode,
          home: ChangeNotifierProvider<Server>(
            create: (context) => Server(
              homeAddress: configuration.homeAddress,
            ),
            builder: (context, _) => Consumer<Server>(
              builder: (context, _, __) => Home(),
            ),
          ),
          builder: (context, child) {
            if (Methods.isDesktop) {
              return Column(children: [
                WindowTitleBarBox(
                  child: Container(
                    color: Theme.of(context).accentColor,
                    child: Row(children: [
                      Expanded(child: MoveWindow()),
                      WindowButtons(),
                    ]),
                  ),
                ),
                if (child != null) Expanded(child: child),
              ]);
            }
            return child ?? SizedBox();
          },
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Colors.white60,
      iconMouseOver: Colors.white70,
      iconMouseDown: Colors.white,
      mouseOver: Theme.of(context).hoverColor,
      mouseDown: Theme.of(context).splashColor,
    );
    final closeButtonColors = WindowButtonColors(
      mouseOver: Color(0xFFD32F2F),
      mouseDown: Color(0xFFB71C1C),
      iconNormal: Colors.white60,
      iconMouseOver: Colors.white,
    );
    return Row(children: [
      MinimizeWindowButton(colors: buttonColors),
      MaximizeWindowButton(colors: buttonColors, animate: true),
      CloseWindowButton(colors: closeButtonColors),
    ]);
  }
}
