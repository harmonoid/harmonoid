import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:harmonoid/mappers/splash_config.dart';
import 'package:harmonoid/state/splash_config_notifier.dart';

const Color kDefaultSplashBackgroundColor = Color(0xFF6200EA);

// NOTE: Only used on desktop.

class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  static const _kImageAsset = 'assets/vectors/project.svg';
  static const _kImageWidth = 196.0;
  static const _kImageHeight = 196.0;

  @override
  void initState() {
    super.initState();
    unawaited(SplashConfigNotifier.instance.load());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: ListenableBuilder(
        listenable: SplashConfigNotifier.instance,
        builder: (context, _) {
          final file = SplashConfigNotifier.instance.file;
          final config = SplashConfigNotifier.instance.config;
          final background = config?.toBackgroundColor();
          return Scaffold(
            backgroundColor: kDefaultSplashBackgroundColor,
            body: Stack(
              children: [
                if (file != null && config != null)
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, opacity, _) => Stack(
                        children: [
                          if (background != null)
                            Positioned.fill(
                              child: Opacity(
                                opacity: opacity,
                                child: ColoredBox(color: background),
                              ),
                            ),
                          Positioned.fill(
                            child: Opacity(
                              opacity: opacity,
                              child: Image.file(
                                file,
                                fit: config.toBoxFit(),
                                alignment: config.toAlignment(),
                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          );
        },
      ),
    );
  }
}
