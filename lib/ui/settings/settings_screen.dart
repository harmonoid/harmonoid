import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/sections/display_section.dart';
import 'package:harmonoid/ui/settings/sections/language_section.dart';
import 'package:harmonoid/ui/settings/sections/media_library_section.dart';
import 'package:harmonoid/ui/settings/sections/now_playing_screen_section.dart';
import 'package:harmonoid/ui/settings/sections/stats_section.dart';
import 'package:harmonoid/ui/settings/settings_spacer.dart';
import 'package:harmonoid/utils/constants.dart';

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
      slivers: [
        SliverList.list(
          children: const [
            SettingsSpacer(),
            MediaLibrarySection(),
            StatsSection(),
            DisplaySection(),
            LanguageSection(),
            NowPlayingScreenSection(),
            SettingsSpacer(),
          ],
        ),
      ],
    );
  }
}
