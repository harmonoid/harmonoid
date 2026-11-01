// DO NOT IMPORT ANYTHING FROM package:harmonoid IN THIS FILE.

import 'dart:io';

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:safe_local_storage/file_system.dart';

import 'package:harmonoid/core/configuration/configuration.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionApp({super.key, required this.exception, required this.stacktrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.light),
      darkTheme: createM2Theme(context: context, color: Colors.white, mode: ThemeMode.dark),
      home: ExceptionScreen(
        exception: exception,
        stacktrace: stacktrace,
      ),
    );
  }
}

class ExceptionScreen extends StatefulWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionScreen({super.key, required this.exception, required this.stacktrace});

  @override
  State<ExceptionScreen> createState() => _ExceptionScreenState();
}

class _ExceptionScreenState extends State<ExceptionScreen> {
  bool _isClearing = false;

  Future<void> _onClearCachePressed(BuildContext context) async {
    if (_isClearing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(kClearCacheConfirmTitle),
        content: const Text(kClearCacheConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(kClearCacheConfirmPositiveAction),
          ),
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text(kClearCacheConfirmNegativeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isClearing = true);
    try {
      await getDefaultDirectory().then((directory) => Directory(directory).delete_());
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    try {
      await getLegacyDefaultDirectory().then((directory) => Directory(directory).delete_());
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    } finally {
      setState(() => _isClearing = false);
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(kClearCacheDoneTitle),
        content: const Text(kClearCacheDoneContent),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text(kClearCacheDoneAction),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    return switch (variant) {
      LayoutVariant.desktop => const EdgeInsets.symmetric(horizontal: 64.0),
      LayoutVariant.mobile => const EdgeInsets.symmetric(horizontal: 16.0),
      LayoutVariant.tablet => throw UnimplementedError(),
      null => throw UnimplementedError(),
    };
  }

  Widget _getSpacer(BuildContext context) {
    final variant = Theme.of(context).extension<LayoutVariantThemeExtension>()?.value;
    return switch (variant) {
      LayoutVariant.desktop => const SizedBox(height: 32.0),
      LayoutVariant.mobile => const SizedBox(height: 16.0),
      LayoutVariant.tablet => throw UnimplementedError(),
      null => throw UnimplementedError(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      implyBackButton: false,
      caption: kExceptionCaption,
      title: kExceptionTitle,
      slivers: [
        SliverList.list(
          children: [
            // Ref: lib/features/settings/settings_section.dart
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: _getPadding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getSpacer(context),
                    Text(
                      kExceptionHeading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.exception.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _getSpacer(context),
                    Text(
                      kExceptionStackTraceHeading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.stacktrace.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _getSpacer(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isClearing ? null : () => _onClearCachePressed(context),
        icon: _isClearing ? const SizedBox.square(dimension: 24.0, child: CircularProgressIndicator(strokeWidth: 2.0)) : const Icon(Icons.delete),
        label: const Text(kClearCacheButtonLabel),
        shape: const StadiumBorder(),
      ),
    );
  }
}

const String kExceptionCaption = 'Harmonoid Music';
const String kExceptionTitle = 'Error';
const String kExceptionHeading = 'Exception';
const String kExceptionStackTraceHeading = 'Stack trace';
const String kClearCacheButtonLabel = 'Clear cache?';
const String kClearCacheConfirmTitle = 'Clear cache?';
const String kClearCacheConfirmContent = 'Are you sure you want to clear the cache? You will lose all your settings & cached data.';
const String kClearCacheConfirmPositiveAction = 'Clear';
const String kClearCacheConfirmNegativeAction = 'Cancel';
const String kClearCacheDoneTitle = 'Done';
const String kClearCacheDoneContent = 'Please restart the app';
const String kClearCacheDoneAction = 'OK';
