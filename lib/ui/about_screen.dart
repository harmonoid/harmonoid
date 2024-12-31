import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/color.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _kImageAsset = 'assets/vectors/project.svg';
  static const _kGitHubSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>GitHub</title><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>';
  static const _kXSvg =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>X</title><path d="M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24H4.298Z"/></svg>';

  SvgPicture? _imagePicture;

  Color get _bgM3 {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? theme.colorScheme.inversePrimary : theme.colorScheme.primary;
  }

  Color get _fg0M3 {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;
  }

  Color get _fg1M3 {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.primaryContainer;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isMaterial3) {
        final result = await rootBundle.loadString(_kImageAsset);
        setState(() {
          _imagePicture = SvgPicture.string(
            result.replaceAll('white', _fg0M3.toHex()).replaceAll('#B388FF', _fg1M3.toHex()),
            fit: BoxFit.contain,
          );
        });
      } else {
        setState(() {
          _imagePicture = SvgPicture.asset(
            _kImageAsset,
            fit: BoxFit.contain,
          );
        });
      }
    });
  }

  Future<void> _open(String value) {
    return launchUrl(
      Uri.parse(value),
      mode: LaunchMode.externalApplication,
    );
  }

  EdgeInsets _headerPadding() {
    if (isDesktop) {
      if (isMaterial3) {
        return const EdgeInsets.symmetric(horizontal: 64.0);
      }
      if (isMaterial2) {
        return const EdgeInsets.symmetric(horizontal: 64.0);
      }
    }
    if (isMobile) {
      if (isMaterial3) {
        return const EdgeInsets.symmetric(horizontal: 16.0);
      }
      if (isMaterial2) {
        return const EdgeInsets.symmetric(horizontal: 16.0);
      }
    }
    return EdgeInsets.zero;
  }

  EdgeInsets _contentPadding() {
    if (isDesktop) {
      if (isMaterial3) {
        return const EdgeInsets.symmetric(horizontal: 48.0);
      }
      if (isMaterial2) {
        return const EdgeInsets.symmetric(horizontal: 64.0);
      }
    }
    if (isMobile) {
      if (isMaterial3) {
        return EdgeInsets.zero;
      }
      if (isMaterial2) {
        return const EdgeInsets.symmetric(horizontal: 16.0);
      }
    }
    return EdgeInsets.zero;
  }

  Widget _contentSpacer() {
    if (isDesktop) {
      if (isMaterial3) {
        return const SizedBox(height: 8.0);
      }
      if (isMaterial2) {
        return const SizedBox(height: 8.0);
      }
    }
    if (isMobile) {
      if (isMaterial3) {
        return const SizedBox.shrink();
      }
      if (isMaterial2) {
        return const SizedBox(height: 8.0);
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeader() {
    if (isMaterial3) {
      return Center(
        child: Container(
          padding: _headerPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: _bgM3,
            child: SizedBox(
              width: double.infinity,
              height: 96.0,
              child: Row(
                children: [
                  Container(
                    width: 112.0,
                    height: 96.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24.0),
                    child: _imagePicture,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: _fg0M3,
                              ),
                        ),
                        Text(
                          kVersion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _fg0M3,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (isMaterial2) {
      return Center(
        child: Container(
          padding: _headerPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Card(
            elevation: 0.0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.0,
                color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: double.infinity,
              height: 96.0,
              child: Row(
                children: [
                  Container(
                    width: 96.0,
                    height: 96.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24.0),
                    color: ThemeNotifier.kDefaultLightPrimaryColorM2,
                    child: _imagePicture,
                  ),
                  const SizedBox(width: 28.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          kVersion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    throw UnimplementedError();
  }

  Widget _buildItems0() {
    final children = [
      _contentSpacer(),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: SvgPicture.string(
            _kGitHubSvg,
            color: Theme.of(context).iconTheme.color,
            width: 24.0,
            height: 24.0,
          ),
        ),
        onTap: () => _open('https://github.com/harmonoid/harmonoid'),
        title: Text(Localization.instance.GITHUB),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.description_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        onTap: () => _open('https://github.com/harmonoid/harmonoid/blob/master/LICENSE'),
        title: Text(Localization.instance.LICENSE),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.lock,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        onTap: () => _open('https://github.com/harmonoid/harmonoid/wiki/Privacy'),
        title: Text(Localization.instance.PRIVACY),
      ),
      _contentSpacer(),
    ];
    if (isMaterial3) {
      return Center(
        child: Container(
          padding: _contentPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    }
    if (isMaterial2) {
      return Center(
        child: Container(
          padding: _contentPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Card(
            elevation: 0.0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.0,
                color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );
    }
    throw UnimplementedError();
  }

  Widget _buildItems1() {
    final children = [
      SubHeader(
        Localization.instance.DEVELOPER,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.person,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: const Text(kAuthor),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: SvgPicture.string(
            _kGitHubSvg,
            color: Theme.of(context).iconTheme.color,
            width: 24.0,
            height: 24.0,
          ),
        ),
        onTap: () => _open('https://github.com/alexmercerind'),
        title: Text(Localization.instance.FOLLOW_ON_X.replaceAll('"X"', Localization.instance.GITHUB)),
      ),
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: SvgPicture.string(
            _kXSvg,
            color: Theme.of(context).iconTheme.color,
            width: 24.0,
            height: 24.0,
          ),
        ),
        onTap: () => _open('https://x.com/alexmercerind'),
        title: Text(Localization.instance.FOLLOW_ON_X.replaceAll('"X"', Localization.instance.X)),
      ),
      _contentSpacer(),
    ];
    if (isMaterial3) {
      return Center(
        child: Container(
          padding: _contentPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    }
    if (isMaterial2) {
      return Center(
        child: Container(
          padding: _contentPadding(),
          width: kDesktopCenteredLayoutWidth,
          child: Card(
            elevation: 0.0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.0,
                color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Localization.instance.ABOUT,
      slivers: [
        SliverList.list(
          children: [
            const SliverSpacer(),
            _buildHeader(),
            const SizedBox(height: 16.0),
            _buildItems0(),
            const SizedBox(height: 16.0),
            _buildItems1(),
            const SliverSpacer(),
          ],
        ),
      ],
    );
  }
}
