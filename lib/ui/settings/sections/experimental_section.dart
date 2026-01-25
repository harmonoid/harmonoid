import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/widgets.dart';

class ExperimentalSection extends StatefulWidget {
  const ExperimentalSection({super.key});

  @override
  State<ExperimentalSection> createState() => _ExperimentalSectionState();
}

class _ExperimentalSectionState extends State<ExperimentalSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_EXPERIMENTAL_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_EXPERIMENTAL_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          trailing: Switch(
            value: Configuration.instance.mediaLibraryTagReaderFallback,
            onChanged: (value) async {
              await Configuration.instance.set(mediaLibraryTagReaderFallback: value);
              setState(() {});
            },
          ),
          title: Localization.instance.IMPROVE_METADATA_COMPATIBILITY,
          onTap: () async {
            await Configuration.instance.set(mediaLibraryTagReaderFallback: !Configuration.instance.mediaLibraryTagReaderFallback);
            setState(() {});
          },
        ),
      ],
    );
  }
}
