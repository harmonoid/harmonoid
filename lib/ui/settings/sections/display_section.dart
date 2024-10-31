import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class DisplaySection extends StatefulWidget {
  const DisplaySection({super.key});

  @override
  State<DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends State<DisplaySection> {
  Future<void> setAnimationDuration(int value) async {
    final animationDuration = AnimationDuration(
      fast: Duration(milliseconds: (value * 1 / 2).round()),
      medium: Duration(milliseconds: (value * 1 / 1).round()),
      slow: Duration(milliseconds: (value * 3 / 2).round()),
    );
    await Configuration.instance.set(themeAnimationDuration: animationDuration);
    await ThemeNotifier.instance.update(animationDuration: animationDuration);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeModeIcon = switch (Configuration.instance.themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
    final themeModeSubtitle = switch (Configuration.instance.themeMode) {
      ThemeMode.system => Localization.instance.THEME_MODE_SYSTEM,
      ThemeMode.light => Localization.instance.THEME_MODE_LIGHT,
      ThemeMode.dark => Localization.instance.THEME_MODE_DARK,
    };

    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_DISPLAY_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_DISPLAY_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          leading: CircleAvatar(
            child: Icon(themeModeIcon),
          ),
          title: Localization.instance.THEME,
          subtitle: themeModeSubtitle,
          onTap: () async {
            final result = await showSelection(
              context,
              Localization.instance.THEME,
              ThemeMode.values,
              Configuration.instance.themeMode,
              (value) => switch (value) {
                ThemeMode.system => Localization.instance.THEME_MODE_SYSTEM,
                ThemeMode.light => Localization.instance.THEME_MODE_LIGHT,
                ThemeMode.dark => Localization.instance.THEME_MODE_DARK,
              },
              actions: false,
            );
            if (result != null) {
              await Configuration.instance.set(themeMode: result);
              await ThemeNotifier.instance.update(themeMode: result);
              setState(() {});
            }
          },
        ),
        ListItem(
          leading: CircleAvatar(
            child: Text(List.generate(Configuration.instance.themeMaterialStandard, (_) => 'I').join()),
          ),
          title: Localization.instance.MATERIAL_DESIGN,
          subtitle: Configuration.instance.themeMaterialStandard.toString(),
          onTap: () async {
            final result = await showSelection(
              context,
              Localization.instance.MATERIAL_DESIGN,
              [2, 3],
              Configuration.instance.themeMaterialStandard,
              (value) => value.toString(),
              actions: false,
            );
            if (result != null) {
              await Configuration.instance.set(themeMaterialStandard: result);
              await ThemeNotifier.instance.update(materialStandard: result);
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${Localization.instance.ANIMATION_SPEED} ${Configuration.instance.themeAnimationDuration.medium.inMilliseconds}ms',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 64.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ScrollableSlider(
            min: 50.0,
            max: 1000.0,
            interval: 50.0,
            stepSize: 50.0,
            showLabels: true,
            labelFormatterCallback: (value, _) {
              return switch (value) {
                50.0 || 300.0 || 1000.0 => '${value ~/ 1}ms',
                _ => '',
              };
            },
            value: Configuration.instance.themeAnimationDuration.medium.inMilliseconds.toDouble().clamp(50.0, 1000.0),
            onChanged: Configuration.instance.themeAnimationDuration.medium > Duration.zero ? (value) => setAnimationDuration(value.round()) : null,
          ),
        ),
        const SizedBox(height: 16.0),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.themeAnimationDuration.medium > Duration.zero,
            onChanged: (value) => setAnimationDuration(value ? 300 : 0),
          ),
          title: Localization.instance.ENABLE_ANIMATION_EFFECTS,
          onTap: () => setAnimationDuration(Configuration.instance.themeAnimationDuration.medium > Duration.zero ? 0 : 300),
        ),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.themeSystemColorScheme,
            onChanged: (value) async {
              await Configuration.instance.set(themeSystemColorScheme: value);
              await ThemeNotifier.instance.update(systemColorScheme: value);
              setState(() {});
            },
          ),
          title: Localization.instance.USE_SYSTEM_COLOR_SCHEME,
          onTap: () async {
            final value = Configuration.instance.themeSystemColorScheme;
            await Configuration.instance.set(themeSystemColorScheme: !value);
            await ThemeNotifier.instance.update(systemColorScheme: !value);
            setState(() {});
          },
        ),
      ],
    );
  }
}
