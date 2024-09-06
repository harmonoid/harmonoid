import 'package:flutter/material.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';

class NowPlayingScreenSection extends StatelessWidget {
  const NowPlayingScreenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_NOW_PLAYING_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_NOW_PLAYING_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [],
    );
  }
}
