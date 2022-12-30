/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/main.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:window_plus/window_plus.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    if (isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!Configuration.instance.stickyMiniplayer)
          MobileNowPlayingController.instance.hide();
      });
    }
  }

  Future<void> open(String url) => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    final content = CustomScrollView(
      slivers: [
        if (isMobile)
          SliverAppBar(
            title: Text(
              Label.about,
            ),
            snap: true,
            pinned: true,
            floating: true,
            forceElevated: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ??
                        Theme.of(context).dividerColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 96.0,
                            width: 96.0,
                            alignment: Alignment.center,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/project.png',
                                height: 56.0,
                                width: 56.0,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontSize: 24.0,
                                    ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                [
                                  kVersion,
                                ].join(' • '),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(
                        height: 1.0,
                        thickness: 1.0,
                      ),
                      ListTile(
                        onTap: () => open(URL.github),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.github,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.github,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.discord),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.discord,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.talk_on_discord,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.patreon),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.patreon,
                            height: 20.0,
                            width: 20.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.become_a_patreon,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.paypal),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.paypal,
                            height: 20.0,
                            width: 20.0,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.donate_with_paypal,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.license),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: Icon(
                            Icons.description_outlined,
                            size: 26.0,
                          ),
                        ),
                        title: Text(
                          Label.license,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.translate),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: Icon(
                            Icons.translate_outlined,
                            size: 26.0,
                          ),
                        ),
                        title: Text(
                          Label.translate,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      if (Platform.isAndroid)
                        ListTile(
                          onTap: () => open(URL.privacy),
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Theme.of(context).iconTheme.color,
                            child: Icon(
                              Icons.lock_outlined,
                              size: 26.0,
                            ),
                          ),
                          title: Text(
                            Label.privacy,
                            style: isDesktop
                                ? Theme.of(context).textTheme.headlineMedium
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ??
                        Theme.of(context).dividerColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SubHeader(Label.developer),
                      ListTile(
                        onTap: () => open(URL.alexmercerind),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: Icon(
                            Icons.person_outline,
                            size: 26.0,
                          ),
                        ),
                        title: Text(
                          Label.alexmercerind,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.alexmercerind_github),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.github,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.follow_on_github,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                      ListTile(
                        onTap: () => open(URL.alexmercerind_twitter),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).iconTheme.color,
                          child: SvgPicture.string(
                            SVG.twitter,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        title: Text(
                          Label.follow_on_twitter,
                          style: isDesktop
                              ? Theme.of(context).textTheme.headlineMedium
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMobile &&
                  Configuration.instance.stickyMiniplayer &&
                  !MobileNowPlayingController.instance.isHidden)
                SizedBox(
                  height: kMobileNowPlayingBarHeight,
                ),
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isDesktop
          ? Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: WindowPlus.instance.captionHeight +
                        kDesktopAppBarHeight,
                  ),
                  child: content,
                ),
                DesktopAppBar(
                  title: Label.about,
                ),
              ],
            )
          : NowPlayingBarScrollHideNotifier(
              child: content,
            ),
    );
  }
}

abstract class Label {
  static const about = 'About';
  static const github = 'GitHub';
  static const talk_on_discord = 'Talk on Discord';
  static const become_a_patreon = 'Become a Patreon';
  static const donate_with_paypal = 'Donate with PayPal';
  static const license = 'License';
  static const translate = 'Translate';
  static const privacy = 'Privacy';
  static const developer = 'Developer';
  static const alexmercerind = 'Hitesh Kumar Saini';
  static const follow_on_github = 'Follow on GitHub';
  static const follow_on_twitter = 'Follow on Twitter';
}

abstract class SVG {
  static const github =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>GitHub</title><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>';
  static const discord =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Discord</title><path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/></svg>';
  static const patreon =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Patreon</title><path d="M0 .48v23.04h4.22V.48zm15.385 0c-4.764 0-8.641 3.88-8.641 8.65 0 4.755 3.877 8.623 8.641 8.623 4.75 0 8.615-3.868 8.615-8.623C24 4.36 20.136.48 15.385.48z"/></svg>';
  static const paypal =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>PayPal</title><path d="M7.076 21.337H2.47a.641.641 0 0 1-.633-.74L4.944.901C5.026.382 5.474 0 5.998 0h7.46c2.57 0 4.578.543 5.69 1.81 1.01 1.15 1.304 2.42 1.012 4.287-.023.143-.047.288-.077.437-.983 5.05-4.349 6.797-8.647 6.797h-2.19c-.524 0-.968.382-1.05.9l-1.12 7.106zm14.146-14.42a3.35 3.35 0 0 0-.607-.541c-.013.076-.026.175-.041.254-.93 4.778-4.005 7.201-9.138 7.201h-2.19a.563.563 0 0 0-.556.479l-1.187 7.527h-.506l-.24 1.516a.56.56 0 0 0 .554.647h3.882c.46 0 .85-.334.922-.788.06-.26.76-4.852.816-5.09a.932.932 0 0 1 .923-.788h.58c3.76 0 6.705-1.528 7.565-5.946.36-1.847.174-3.388-.777-4.471z"/></svg>';
  static const twitter =
      '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Twitter</title><path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/></svg>';
}

abstract class URL {
  static const github = 'https://github.com/harmonoid/harmonoid';
  static const discord = 'https://discord.gg/2Rc3edFWd8';
  static const patreon = 'https://www.patreon.com/harmonoid';
  static const paypal = 'https://www.paypal.me/alexmercerind';
  static const license =
      'https://github.com/harmonoid/harmonoid/tree/master/EULA.txt?raw=true';
  static const translate = 'https://github.com/harmonoid/translations.git';
  static const privacy =
      'https://github.com/harmonoid/harmonoid/wiki/Privacy-Policy-%5BPlay-Store%5D';
  static const alexmercerind = 'https://alexmercerind.github.io';
  static const alexmercerind_github = 'https://github.com/alexmercerind';
  static const alexmercerind_twitter = 'https://twitter.com/alexmercerind';
}
