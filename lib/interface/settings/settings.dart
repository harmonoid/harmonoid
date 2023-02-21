/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_plus/window_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/interface/settings/stats.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/interface/settings/display.dart';
import 'package:harmonoid/interface/settings/indexing.dart';
import 'package:harmonoid/interface/settings/language.dart';
import 'package:harmonoid/interface/settings/experimental.dart';
import 'package:harmonoid/interface/settings/miscellaneous.dart';
import 'package:harmonoid/interface/settings/now_playing_screen.dart';
import 'package:harmonoid/interface/settings/android_permissions.dart';
import 'package:harmonoid/state/collection_refresh.dart';
import 'package:harmonoid/constants/language.dart';

class Settings extends StatelessWidget {
  Future<void> open(String url) => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDesktop
          ? Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: WindowPlus.instance.captionHeight +
                        kDesktopAppBarHeight,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: kCenterLayoutWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IndexingSetting(),
                            StatsSetting(),
                            DisplaySetting(),
                            LanguageSetting(),
                            NowPlayingScreenSetting(),
                            MiscellaneousSetting(),
                            ExperimentalSetting(),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                DesktopAppBar(
                  title: Language.instance.SETTING,
                  actions: [
                    Tooltip(
                      message: Label.github,
                      child: InkWell(
                        onTap: () => open(URL.github),
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          alignment: Alignment.center,
                          child: SvgPicture.string(
                            SVG.github,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                ?.color,
                            height: 20.0,
                            width: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: Label.become_a_patreon,
                      child: InkWell(
                        onTap: () => open(URL.patreon),
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          alignment: Alignment.center,
                          child: SvgPicture.string(
                            SVG.patreon,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                ?.color,
                            height: 18.0,
                            width: 18.0,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: Language.instance.ABOUT_TITLE,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialRoute(
                              builder: (context) => AboutPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          child: Icon(
                            Icons.info,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                ?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : NowPlayingBarScrollHideNotifier(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: Container(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(height: 8.0),
                          IconButton(
                            onPressed: Navigator.of(context).maybePop,
                            icon: const Icon(Icons.arrow_back),
                            color:
                                Theme.of(context).appBarTheme.iconTheme?.color,
                            splashRadius: 24.0,
                          ),
                        ],
                      ),
                    ),
                    floating: false,
                    pinned: true,
                    snap: false,
                    stretch: false,
                    stretchTriggerOffset: 100.0,
                    toolbarHeight:
                        LargeScrollUnderFlexibleConfig.collapsedHeight,
                    collapsedHeight:
                        LargeScrollUnderFlexibleConfig.collapsedHeight,
                    expandedHeight:
                        LargeScrollUnderFlexibleConfig.expandedHeight,
                    flexibleSpace: ScrollUnderFlexibleSpace(
                      title: Text(Language.instance.SETTING),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.0),
                      child: MobileIndexingProgressIndicator(),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 16.0),
                        IndexingSetting(),
                        const Divider(thickness: 1.0),
                        StatsSetting(),
                        const Divider(thickness: 1.0),
                        DisplaySetting(),
                        const Divider(thickness: 1.0),
                        LanguageSetting(),
                        const Divider(thickness: 1.0),
                        if (StorageRetriever.instance.version >= 33) ...[
                          AndroidPermissionsSetting(),
                          const Divider(thickness: 1.0),
                        ],
                        MiscellaneousSetting(),
                        const Divider(thickness: 1.0),
                        ExperimentalSetting(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsets? margin;
  final List<Widget>? actions;

  const SettingsTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isDesktop
          ? EdgeInsets.symmetric(
              horizontal: 8.0,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          if (isMobile)
            SubHeader(
              title,
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          Container(
            margin: margin ?? EdgeInsets.zero,
            child: child,
          ),
          if (actions != null) ...[
            ButtonBar(
              alignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

class MobileIndexingProgressIndicator extends StatelessWidget {
  const MobileIndexingProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionRefresh>(
      builder: (context, controller, _) {
        if (controller.progress != controller.total) {
          return Container(
            height: 4.0,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: controller.progress == null
                  ? null
                  : controller.progress! / controller.total,
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
