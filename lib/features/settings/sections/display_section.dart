import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/features/settings/settings_section.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/color.dart';
import 'package:harmonoid/state/theme/models/theme_accent_color.dart';
import 'package:harmonoid/state/theme/theme_notifier.dart';
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
    ThemeNotifier.instance.update(animationDuration: animationDuration);
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
            final themeMode = await showSelection(
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
            if (themeMode == null) return;
            await Future.delayed(MaterialRoute.kDefaultTransitionDuration);
            await Configuration.instance.set(themeMode: themeMode);
            ThemeNotifier.instance.update(themeMode: themeMode);
          },
        ),
        ListItem(
          leading: CircleAvatar(
            child: Text(List.generate(Configuration.instance.themeMaterialStandard, (_) => 'I').join()),
          ),
          title: Localization.instance.MATERIAL_DESIGN,
          subtitle: Configuration.instance.themeMaterialStandard.toString(),
          onTap: () async {
            final materialStandard = await showSelection(
              context,
              Localization.instance.MATERIAL_DESIGN,
              [2, 3],
              Configuration.instance.themeMaterialStandard,
              (value) => value.toString(),
              actions: false,
            );
            if (materialStandard == null) return;
            final systemColorScheme = materialStandard == 3;
            final accentColor = materialStandard == 3 ? ThemeNotifier.kDefaultAccentColorM3 : ThemeNotifier.kDefaultAccentColorM2;
            await Future.delayed(MaterialRoute.kDefaultTransitionDuration);
            await Configuration.instance.set(themeMaterialStandard: materialStandard, themeSystemColorScheme: systemColorScheme, themeAccentColor: accentColor);
            ThemeNotifier.instance.update(materialStandard: materialStandard, systemColorScheme: systemColorScheme, accentColor: accentColor);
          },
        ),
        ListItem(
          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary),
          title: Localization.instance.ACCENT_COLOR,
          subtitle: Theme.of(context).colorScheme.primary.toHex(),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const _AccentColorDialog(),
            );
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
      ],
    );
  }
}

class _AccentColorDialog extends StatefulWidget {
  const _AccentColorDialog();

  @override
  State<_AccentColorDialog> createState() => _AccentColorDialogState();
}

class _AccentColorDialogState extends State<_AccentColorDialog> {
  late ThemeAccentColor _accentColor = ThemeNotifier.instance.accentColor;
  late bool _systemColorScheme = ThemeNotifier.instance.systemColorScheme;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    if (_timer?.isActive != true) return;
    _timer?.cancel();
    Future.microtask(_apply);
  }

  void _select(ThemeAccentColor? accentColor, bool systemColorScheme) {
    setState(() {
      if (accentColor != null) _accentColor = accentColor;
      _systemColorScheme = systemColorScheme;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), _apply);
  }

  Future<void> _apply() async {
    ThemeNotifier.instance.update(accentColor: _accentColor, systemColorScheme: _systemColorScheme);
    await Configuration.instance.set(themeAccentColor: _accentColor, themeSystemColorScheme: _systemColorScheme);
  }

  @override
  Widget build(BuildContext context) {
    final values = switch (Configuration.instance.themeMaterialStandard) {
      3 => ThemeNotifier.kColorsM3,
      2 => ThemeNotifier.kColorsM2,
      _ => throw UnimplementedError(),
    };
    const span = 4;
    const margin = 12.0;
    const padding = EdgeInsets.only(top: 12.0);
    final width = (MediaQuery.of(context).size.width - 80.0).clamp(0.0, 280.0);
    final tile = (width - (span + 1) * margin) / span;
    final rows = ((values.length + 1) / span).ceil();
    final height = rows * tile + (rows + 1) * margin;

    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
      contentPadding: EdgeInsets.zero,
      title: Text(Localization.instance.ACCENT_COLOR),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1.0),
          SizedBox(
            width: width,
            height: height,
            child: ScrollViewBuilder(
              span: span,
              margin: margin,
              padding: padding,
              displayHeaders: false,
              headerCount: 1,
              headerBuilder: (context, i, h) => const SizedBox.shrink(),
              headerHeight: 0.0,
              itemCounts: [1 + values.length],
              itemBuilder: (context, i, j, w, h) {
                if (j == 0) {
                  final themeNotifier = ThemeNotifier.instance;
                  final light = (themeNotifier.systemLightColorScheme?.primary ?? themeNotifier.systemLightColor)?.toARGB32();
                  final dark = (themeNotifier.systemDarkColorScheme?.primary ?? themeNotifier.systemDarkColor)?.toARGB32();
                  const gradient = [0xFFF44336, 0xFFFFC107, 0xFF4CAF50, 0xFF2196F3, 0xFF9C27B0];
                  final overlay = light == null || dark == null ? null : [light, dark];
                  return _Swatch(
                    key: const ValueKey<String>('accent-system'),
                    size: w,
                    selected: _systemColorScheme,
                    gradient: gradient,
                    overlay: overlay,
                    icon: isDesktop ? Icons.laptop : Icons.smartphone,
                    tooltip: Localization.instance.USE_SYSTEM_COLOR_SCHEME,
                    onTap: () => _select(null, true),
                  );
                }
                final color = values[j - 1];
                return _Swatch(
                  key: ValueKey<String>('accent-$j'),
                  size: w,
                  selected: !_systemColorScheme && color == _accentColor,
                  gradient: [color.light, color.dark],
                  onTap: () => _select(color, false),
                );
              },
              itemWidth: tile,
              itemHeight: tile,
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatefulWidget {
  final double size;
  final bool selected;
  final List<int> gradient;
  final List<int>? overlay;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback onTap;

  const _Swatch({
    super.key,
    required this.size,
    required this.selected,
    required this.gradient,
    this.overlay,
    this.icon,
    this.tooltip,
    required this.onTap,
  });

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> with SingleTickerProviderStateMixin {
  late final AnimationDuration? _duration = Theme.of(context).extension<AnimationDuration>();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.selected ? 1.0 : 0.0,
    duration: _duration?.slow ?? Duration.zero,
    reverseDuration: _duration?.fast ?? Duration.zero,
  );
  late final Animation<double> _morph = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeInOut),
    ),
  );
  late final Animation<double> _tilt = Tween<double>(begin: -pi / 4, end: 0.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutBack),
    ),
  );
  late final Animation<double> _ring = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.8, curve: Curves.linear),
    ),
  );

  @override
  void didUpdateWidget(covariant _Swatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.forward();
    } else if (!widget.selected && oldWidget.selected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final selected = widget.selected;
    final tile = GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: selected ? 1.06 : 1.0,
          duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final morph = _morph.value;
              final tilt = _tilt.value;
              final ring = _ring.value;
              final radius = BorderRadius.circular(lerpDouble(size / 2.0, 8.0, morph) ?? 0.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: tilt,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: widget.gradient.map(Color.new).toList(),
                        ),
                        borderRadius: radius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 3.0,
                            offset: const Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (widget.overlay != null)
                            Opacity(
                              opacity: morph,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: widget.overlay!.map(Color.new).toList(),
                                  ),
                                  borderRadius: radius,
                                ),
                              ),
                            ),
                          Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5],
                              ),
                              borderRadius: radius,
                            ),
                          ),
                          Opacity(
                            opacity: ring,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  borderRadius: radius - BorderRadius.circular(2.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: size * 0.36,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    return widget.tooltip == null ? tile : Tooltip(message: widget.tooltip, child: tile);
  }
}
