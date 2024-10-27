import 'package:flutter/material.dart';

class NowPlayingColors {
  final Color? background;
  final Color? foreground;
  final Color? foregroundIcon;
  final Color? backgroundEnabledIcon;
  final Color? backgroundDisabledIcon;
  final Color? backgroundText;
  final Color? sliderForeground;
  final Color? sliderBackground;

  const NowPlayingColors({
    this.background,
    this.foreground,
    this.foregroundIcon,
    this.backgroundEnabledIcon,
    this.backgroundDisabledIcon,
    this.backgroundText,
    this.sliderForeground,
    this.sliderBackground,
  });

  // NOW PLAYING BAR

  factory NowPlayingColors.fromPalette(BuildContext context, List<Color>? palette) {
    final foreground = palette?.last ?? Theme.of(context).floatingActionButtonTheme.backgroundColor!;
    final background = palette?.first ?? Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface;
    final foregroundIcon = palette == null ? Theme.of(context).floatingActionButtonTheme.foregroundColor : (foreground.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    final backgroundEnabledIcon = palette == null ? Theme.of(context).colorScheme.onSurface : (background.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    final backgroundDisabledIcon = palette == null ? Theme.of(context).disabledColor : (background.computeLuminance() > 0.5 ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3));
    final backgroundText = palette == null ? null : (background.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    final sliderForeground = palette == null ? null : foreground;
    final sliderBackground = palette == null ? null : backgroundDisabledIcon;
    return NowPlayingColors(
      background: background,
      foreground: foreground,
      foregroundIcon: foregroundIcon,
      backgroundEnabledIcon: backgroundEnabledIcon,
      backgroundDisabledIcon: backgroundDisabledIcon,
      backgroundText: backgroundText,
      sliderForeground: sliderForeground,
      sliderBackground: sliderBackground,
    );
  }

  // NOW PLAYING SCREEN

  factory NowPlayingColors.of(BuildContext context) {
    const foreground = Colors.black;
    const background = Colors.transparent;
    const foregroundIcon = Colors.white;
    final backgroundEnabledIcon = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    final backgroundDisabledIcon = Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);
    final backgroundText = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    final sliderForeground = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    final sliderBackground = Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);
    return NowPlayingColors(
      background: background,
      foreground: foreground,
      foregroundIcon: foregroundIcon,
      backgroundEnabledIcon: backgroundEnabledIcon,
      backgroundDisabledIcon: backgroundDisabledIcon,
      backgroundText: backgroundText,
      sliderForeground: sliderForeground,
      sliderBackground: sliderBackground,
    );
  }
}
