import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// NOTE: Only used on desktop.

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  static const _kImageAsset = 'assets/vectors/project.svg';
  static const _kImageWidth = 196.0;
  static const _kImageHeight = 196.0;
  static const _kBackgroundColor = Color(0xFF6200EA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _kBackgroundColor,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SvgPicture.asset(
                  _kImageAsset,
                  height: _kImageHeight,
                  width: _kImageWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
