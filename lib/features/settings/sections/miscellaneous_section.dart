import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MiscellaneousSection extends StatefulWidget {
  const MiscellaneousSection({super.key});

  @override
  State<MiscellaneousSection> createState() => _MiscellaneousSectionState();
}

class _MiscellaneousSectionState extends State<MiscellaneousSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_MISCELLANEOUS_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_MISCELLANEOUS_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        Consumer<FileSystemMediaLibrary>(
          builder: (context, mediaLibrary, _) {
            return ListItem(
              trailing: Switch(
                value: mediaLibrary.hideSecondaryArtists,
                onChanged: (value) async {
                  await mediaLibrary.setHideSecondaryArtists(value);
                  await Configuration.instance.set(mediaLibraryHideSecondaryArtists: value);
                },
              ),
              title: Localization.instance.HIDE_SECONDARY_ARTISTS,
              onTap: () async {
                await mediaLibrary.setHideSecondaryArtists(!mediaLibrary.hideSecondaryArtists);
                await Configuration.instance.set(mediaLibraryHideSecondaryArtists: !Configuration.instance.mediaLibraryHideSecondaryArtists);
              },
            );
          },
        ),
        if ( /* MOBILE */ isMobile)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.notificationLyrics,
              onChanged: (value) async {
                await Configuration.instance.set(notificationLyrics: value);
                setState(() {});
              },
            ),
            title: Localization.instance.ENABLE_NOTIFICATION_LYRICS,
            onTap: () async {
              await Configuration.instance.set(notificationLyrics: !Configuration.instance.notificationLyrics);
              setState(() {});
            },
          ),
        if ( /* DESKTOP */ isDesktop)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.lrcFromDirectory,
              onChanged: (value) async {
                await Configuration.instance.set(lrcFromDirectory: value);
                setState(() {});
              },
            ),
            title: Localization.instance.LOOKUP_FOR_LRC_IN_DIRECTORY,
            onTap: () async {
              await Configuration.instance.set(lrcFromDirectory: !Configuration.instance.lrcFromDirectory);
              setState(() {});
            },
          ),
        if ( /* WINDOWS */ Platform.isWindows)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.windowsTaskbarProgress,
              onChanged: (value) async {
                await Configuration.instance.set(windowsTaskbarProgress: value);
                setState(() {});
              },
            ),
            title: Localization.instance.DISPLAY_PROGRESS_ON_TASKBAR,
            onTap: () async {
              await Configuration.instance.set(windowsTaskbarProgress: !Configuration.instance.windowsTaskbarProgress);
              setState(() {});
            },
          ),
        if ( /* DESKTOP */ isDesktop)
          ListItem(
            trailing: Switch(
              value: Configuration.instance.discordRpc,
              onChanged: (value) async {
                await Configuration.instance.set(discordRpc: value);
                setState(() {});
              },
            ),
            title: Localization.instance.ENABLE_DISCORD_RPC,
            onTap: () async {
              await Configuration.instance.set(discordRpc: !Configuration.instance.discordRpc);
              setState(() {});
            },
          ),
      ],
    );
  }
}
