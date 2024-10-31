import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/ui/settings/sections/display_section.dart';
import 'package:harmonoid/ui/settings/sections/language_section.dart';
import 'package:harmonoid/ui/settings/sections/media_library_section.dart';
import 'package:harmonoid/ui/settings/sections/miscellaneous_section.dart';
import 'package:harmonoid/ui/settings/sections/now_playing_screen_section.dart';
import 'package:harmonoid/ui/settings/sections/stats_section.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Localization.instance.SETTINGS,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Consumer<MediaLibrary>(
          builder: (context, mediaLibrary, _) {
            if (!mediaLibrary.refreshing) return const SizedBox.shrink();
            return LinearProgressIndicator(
              value: mediaLibrary.current == null ? null : (mediaLibrary.current ?? 0) / (mediaLibrary.total == 0 ? 1 : mediaLibrary.total),
            );
          },
        ),
      ),
      actions: {
        Icons.info: (context) => context.push('/$kAboutPath'),
      },
      labels: {
        Icons.info: Localization.instance.ABOUT,
      },
      slivers: const [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SliverSpacer(),
              MediaLibrarySection(),
              StatsSection(),
              DisplaySection(),
              LanguageSection(),
              NowPlayingScreenSection(),
              MiscellaneousSection(),
              SliverSpacer(),
            ],
          ),
        ),
      ],
    );
  }
}
