import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/settings/sections/media_library_section.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Language.instance.SETTINGS,
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
            SizedBox(height: 16.0),
            MediaLibrarySection(),
            SizedBox(height: 16.0),
          ],
        ),
      ],
    );
  }
}
