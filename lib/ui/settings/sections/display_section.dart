import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
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
      ThemeMode.system => Language.instance.THEME_MODE_SYSTEM,
      ThemeMode.light => Language.instance.THEME_MODE_LIGHT,
      ThemeMode.dark => Language.instance.THEME_MODE_DARK,
    };

    return SettingsSection(
      title: Language.instance.SETTINGS_SECTION_DISPLAY_TITLE,
      subtitle: Language.instance.SETTINGS_SECTION_DISPLAY_SUBTITLE,
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        ListItem(
          leading: CircleAvatar(
            child: Icon(themeModeIcon),
          ),
          title: Language.instance.THEME,
          subtitle: themeModeSubtitle,
          onTap: () async {
            final result = await showSelection(
              context,
              Language.instance.THEME,
              ThemeMode.values,
              Configuration.instance.themeMode,
              (value) => switch (value) {
                ThemeMode.system => Language.instance.THEME_MODE_SYSTEM,
                ThemeMode.light => Language.instance.THEME_MODE_LIGHT,
                ThemeMode.dark => Language.instance.THEME_MODE_DARK,
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
          title: Language.instance.MATERIAL_DESIGN,
          subtitle: Configuration.instance.themeMaterialStandard.toString(),
          onTap: () async {
            final result = await showSelection(
              context,
              Language.instance.MATERIAL_DESIGN,
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            Language.instance.ANIMATION_SPEED,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 64.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Stack(
            children: [
              ScrollableSlider(
                min: 50,
                max: 1000,
                value: Configuration.instance.themeAnimationDuration.medium.inMilliseconds.toDouble().clamp(50.0, 1000.0),
                enabled: Configuration.instance.themeAnimationDuration.medium > Duration.zero,
                onChanged: (value) => setAnimationDuration(value.round()),
              ),
              Positioned(
                left: 0.0,
                bottom: 0.0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setAnimationDuration(50),
                    child: const Text('50ms'),
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 4.0,
                bottom: 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(flex: (300 - 50)),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setAnimationDuration(300),
                        child: const Column(
                          children: [
                            Spacer(),
                            Text('300ms'),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 1000 - (300 - 50)),
                  ],
                ),
              ),
              Positioned(
                right: 0.0,
                bottom: 0.0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setAnimationDuration(1000),
                    child: const Text('1000ms'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        ListItem(
          trailing: Switch(
            value: Configuration.instance.themeAnimationDuration.medium > Duration.zero,
            onChanged: (value) => setAnimationDuration(value ? 300 : 0),
          ),
          title: Language.instance.ENABLE_ANIMATION_EFFECTS,
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
          title: Language.instance.USE_SYSTEM_COLOR_SCHEME,
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
