import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_LANGUAGE_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_LANGUAGE_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        Consumer<Localization>(
          builder: (context, localization, _) {
            return ListItem(
              leading: const CircleAvatar(
                child: Icon(Icons.language),
              ),
              title: localization.current.name,
              subtitle: localization.current.country,
              onTap: () async {
                final values = await Localization.instance.values;
                final result = await showSelection(
                  context,
                  Localization.instance.SETTINGS_SECTION_LANGUAGE_TITLE,
                  values.toList(),
                  Localization.instance.current,
                  (value) => value.name,
                );
                if (result == null) return;
                await Configuration.instance.set(localization: result);
                await Localization.instance.set(value: result);
                context.pop();
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info, size: 16.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: TappableText(
                  text: [
                    TappableTextData(
                      onTap: () => launchUrl(Uri.parse('https://github.com/harmonoid/localizations')),
                      text: Localization.instance.SETTINGS_SECTION_LANGUAGE_INFO,
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
