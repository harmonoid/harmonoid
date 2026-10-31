import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';
import 'package:system_fonts/system_fonts.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/localization/models/language.dart';
import 'package:harmonoid/mappers/color.dart';
import 'package:harmonoid/mappers/text_align.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class LyricsSection extends StatefulWidget {
  const LyricsSection({super.key});

  @override
  State<LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<LyricsSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_LYRICS_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_LYRICS_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        if ( /* ONLY DESKTOP */ isDesktop)
          ListItem(
            leading: const CircleAvatar(child: Icon(Icons.text_format)),
            trailing: Switch(
              value: LyricsNotifier.instance.desktopNowPlayingLyricsGlobal,
              onChanged: (value) async {
                await LyricsNotifier.instance.setDesktopNowPlayingLyricsGlobal(value);
                setState(() {});
              },
            ),
            title: Localization.instance.LYRICS,
            onTap: () async {
              await LyricsNotifier.instance.setDesktopNowPlayingLyricsGlobal(!LyricsNotifier.instance.desktopNowPlayingLyricsGlobal);
              setState(() {});
            },
          ),
        SubscriptionReveal(
          blur: false,
          child: Consumer<SubscriptionNotifier>(
            builder: (context, subscriptionNotifier, _) {
              final selected = LyricsNotifier.instance.translationLanguageGlobal;
              final subtitle = subscriptionNotifier.state is! SubscriptionValid || selected.code.isEmpty ? Localization.instance.OFF : selected.name;
              return ListItem(
                leading: const CircleAvatar(child: Icon(Icons.translate)),
                title: Localization.instance.LYRICS_TRANSLATION,
                subtitle: subtitle,
                onTap: () async {
                  final notifier = LyricsNotifier.instance;
                  final languages = notifier.translationLanguages;
                  final values = [Language(code: '', name: Localization.instance.OFF), ...languages];
                  final selected = notifier.translationLanguageGlobal;
                  final result = await showSelection(
                    context,
                    Localization.instance.TRANSLATION,
                    values,
                    selected,
                    (language) => language.name,
                  );
                  if (result == null) return;
                  await notifier.setTranslationLanguageGlobal(result);
                  setState(() {});
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${Localization.instance.LYRICS_SIZE} ${Configuration.instance.lyricsViewUnfocusedFontSize.toInt()}/${Configuration.instance.lyricsViewFocusedFontSize.toInt()}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 64.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ScrollableSlider(
            min: 12.0,
            max: 128.0,
            interval: 1.0,
            stepSize: 1.0,
            showLabels: true,
            labelFormatterCallback: (value, _) {
              return switch ((value, isDesktop, isMobile)) {
                (12.0 || 28.0 || 64.0 || 128.0, true, false) => '${value.toInt()}',
                (12.0 || 24.0 || 48.0 || 128.0, false, true) => '${value.toInt()}',
                _ => '',
              };
            },
            values: [
              Configuration.instance.lyricsViewUnfocusedFontSize.clamp(12.0, 128.0),
              Configuration.instance.lyricsViewFocusedFontSize.clamp(12.0, 128.0),
            ],
            onChanged: (value) async {
              await Configuration.instance.set(
                lyricsViewUnfocusedFontSize: value[0],
                lyricsViewFocusedFontSize: value[1],
              );
              setState(() {});
            },
          ),
        ),
        ListItem(
          leading: CircleAvatar(
            child: Icon(Configuration.instance.lyricsViewTextAlign.toIcon()),
          ),
          title: Localization.instance.LYRICS_ALIGNMENT,
          subtitle: Configuration.instance.lyricsViewTextAlign.toLabel(),
          onTap: () async {
            const values = [TextAlign.start, TextAlign.center, TextAlign.end];
            final result = await showSelection(
              context,
              Localization.instance.LYRICS_ALIGNMENT,
              values.toList(),
              Configuration.instance.lyricsViewTextAlign,
              (value) => value.toLabel(),
            );
            if (result == null) return;
            await Configuration.instance.set(lyricsViewTextAlign: result);
            setState(() {});
          },
        ),
        if ( /* ONLY DESKTOP */ isDesktop)
          ListItem(
            leading: const CircleAvatar(child: Icon(Icons.font_download)),
            title: Localization.instance.LYRICS_FONT_FAMILY,
            subtitle: Configuration.instance.lyricsViewFontFamily.nullIfBlank() ?? Localization.instance.DEFAULT,
            onTap: () async {
              final fonts = [''] + SystemFonts().getFontList();
              fonts.sortBy((e) => e.toLowerCase());
              final result = await showSelection(
                context,
                Localization.instance.LYRICS_FONT_FAMILY,
                fonts.toList(),
                Configuration.instance.lyricsViewFontFamily,
                (value) => value.nullIfBlank() ?? Localization.instance.DEFAULT,
              );
              if (result == null) return;
              await Configuration.instance.set(lyricsViewFontFamily: result);
              setState(() {});
            },
          ),
        ListItem(
          leading: CircleAvatar(
            backgroundColor: Configuration.instance.lyricsViewColor,
          ),
          title: Localization.instance.LYRICS_COLOR,
          subtitle: Configuration.instance.lyricsViewColor.toHex(),
          onTap: () async {
            final result = await showColorPicker(
              context,
              Localization.instance.LYRICS_COLOR,
              Configuration.instance.lyricsViewColor,
            );
            if (result == null) return;
            await Configuration.instance.set(lyricsViewColor: result);
            setState(() {});
          },
        ),
        ListItem(
          leading: CircleAvatar(
            backgroundColor: Configuration.instance.lyricsViewBorderColor,
          ),
          title: Localization.instance.LYRICS_BORDER_COLOR,
          subtitle: Configuration.instance.lyricsViewBorderColor.toHex(),
          onTap: () async {
            final result = await showColorPicker(
              context,
              Localization.instance.LYRICS_BORDER_COLOR,
              Configuration.instance.lyricsViewBorderColor,
            );
            if (result == null) return;
            await Configuration.instance.set(lyricsViewBorderColor: result);
            setState(() {});
          },
        ),
      ],
    );
  }
}
