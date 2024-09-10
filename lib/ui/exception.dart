// DO NOT IMPORT ANYTHING FROM package:harmonoid IN THIS FILE.

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionApp({super.key, required this.exception, required this.stacktrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.light),
      darkTheme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.dark),
      themeMode: ThemeMode.dark,
      home: ExceptionScreen(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}

class ExceptionScreen extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionScreen({super.key, required this.exception, required this.stacktrace});

  Widget spacer(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    if (variant == LayoutVariant.desktop) {
      return const SizedBox(height: 32.0);
    }
    if (variant == LayoutVariant.tablet) {
      throw UnimplementedError();
    }
    if (variant == LayoutVariant.mobile) {
      return const SizedBox(height: 16.0);
    }
    throw UnimplementedError();
  }

  EdgeInsets padding(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    if (variant == LayoutVariant.desktop) {
      return const EdgeInsets.symmetric(horizontal: 64.0);
    }
    if (variant == LayoutVariant.tablet) {
      throw UnimplementedError();
    }
    if (variant == LayoutVariant.mobile) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: kError,
      slivers: [
        SliverList.list(
          children: [
            // Ref: lib/ui/settings/settings_section.dart
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 832.0,
                padding: padding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    spacer(context),
                    Text(
                      kException,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      exception.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    spacer(context),
                    Text(
                      kStackTrace,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      stacktrace.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    spacer(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String kCaption = 'Harmonoid Music';
const String kError = 'Error';
const String kException = 'Exception';
const String kStackTrace = 'Stack trace';
