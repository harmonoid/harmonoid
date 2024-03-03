// DO NOT IMPORT ANYTHING FROM package:harmonoid IN THIS FILE.

import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExceptionApp extends StatelessWidget {
  final Object exception;
  final StackTrace stacktrace;
  const ExceptionApp({super.key, required this.exception, required this.stacktrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: createM2Theme(
        context: context,
        color: Colors.red.shade800,
        mode: ThemeMode.light,
      ),
      themeMode: ThemeMode.light,
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
  ExceptionScreenState createState() => ExceptionScreenState();
}

class ExceptionScreenState extends State<ExceptionScreen> {
  final ScrollController _controller = ScrollController();
  final ValueNotifier<EdgeInsetsDirectional> _padding = ValueNotifier(const EdgeInsetsDirectional.only(
    start: 16.0,
    bottom: 48.0,
  ));

  void listener() {
    setState(() {
      _padding.value = EdgeInsetsDirectional.only(
        start: 16.0,
        bottom: (48.0 * (1 - _controller.offset / (expandedHeight - kToolbarHeight - MediaQuery.of(context).padding.top))).clamp(
          16.0,
          48.0,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(listener);
    _controller.dispose();
  }

  double get toolbarHeight {
    double captionHeight;
    try {
      captionHeight = WindowPlus.instance.captionHeight;
    } catch (_) {
      captionHeight = 0.0;
    }
    return kToolbarHeight + captionHeight;
  }

  double get collapsedHeight {
    double captionHeight;
    try {
      captionHeight = WindowPlus.instance.captionHeight;
    } catch (_) {
      captionHeight = 0.0;
    }
    return kToolbarHeight + captionHeight;
  }

  double get expandedHeight => 192.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _controller,
            slivers: [
              SliverAppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                ),
                toolbarHeight: toolbarHeight,
                collapsedHeight: collapsedHeight,
                expandedHeight: expandedHeight,
                pinned: true,
                snap: false,
                forceElevated: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: ValueListenableBuilder<EdgeInsetsDirectional>(
                  valueListenable: _padding,
                  builder: (context, padding, _) => FlexibleSpaceBar(
                    title: Text(
                      _kError,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).extension<TextColors>()?.darkPrimary,
                          ),
                    ),
                    titlePadding: padding,
                    background: Stack(
                      children: [
                        Positioned(
                          bottom: 32.0,
                          right: 32.0,
                          child: Icon(
                            Icons.warning,
                            color: Theme.of(context).extension<IconColors>()?.lightDisabled,
                            size: 128.0,
                          ),
                        ),
                        Positioned(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                          child: Text(
                            widget.exception.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).extension<TextColors>()?.darkSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kCallStack,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8.0),
                            SelectableText(
                              widget.stacktrace.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DesktopCaptionBar(
            color: Theme.of(context).colorScheme.primary,
            caption: _kCaption,
          ),
        ],
      ),
    );
  }

  static const String _kCaption = 'Harmonoid Music';
  static const String _kCallStack = 'Call Stack';
  static const String _kError = 'Error';
}
