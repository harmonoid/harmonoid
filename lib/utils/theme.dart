/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

// DO NOT IMPORT ANYTHING FROM `package:harmonoid` IN THIS FILE.

/// Typography
/// ----------
///
/// Defaults:
///   independent text: bodyLarge              [default][primary-text-color]
///   subtitle text: bodyMedium                [default][secondary-text-color]
///
/// Headings:
///   largest: titleLarge                      [desktop] e.g. [SettingsTile]
///   medium: titleMedium                      [default] e.g. [ListTile], [NowPlayingBar]
///   small: titleSmall                        [desktop] e.g. [AlbumTile]
///
/// ListTile:
///   title: titleMedium                       [default]
///   subtitle: bodyMedium                     [default]
///   title: bodyLarge                         [desktop][no-subtitle]
///
/// AlbumTile:
///   title: titleSmall                        [desktop]
///   subtitle: bodySmall                      [desktop]
///   title: titleMedium + 18 + w700           [mobile][normal]
///   title: titleMedium + 14 + w400           [mobile][dense]
///   subtitle: bodyMedium                     [mobile]
///
/// ArtistTile:
///   title: titleSmall                        [desktop]
///   title: bodyLarge                         [mobile][normal]
///   title: bodyLarge + 14                    [mobile][dense]
///
/// SettingsTile:
///   title: titleLarge                        [desktop]
///   subtitle: bodyMedium                     [desktop]
///   title: SubHeader                         [mobile]
///
/// NowPlayingBar:
///   title: titleMedium                       [desktop]
///   subtitle: bodyMedium                     [desktop]
///
/// SubHeader:
///   text: titleSmall + onSurfaceVariant      [M2]
///   text: titleSmall + onSurface             [M3]
///
/// Dialogs:
///   title: titleLarge                        [default]
///   subtitle: bodyMedium                     [default]
///
/// AlbumScreen/ArtistScreen/GenreScreen/PlaylistScreen:
///   title: headlineSmall                     [desktop]
///   subtitle: bodyMedium                     [desktop]
///   title: headlineSmall                     [mobile]
///   subtitle: bodyMedium + 16                [mobile]
///

import 'dart:io';
import 'dart:ui';

import 'typography_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Creates consistent & strictly implemented Material Design 3 [ThemeData] based on the provided [colorScheme] and [mode].
ThemeData createM3Theme({
  required ColorScheme colorScheme,
  required ThemeMode mode,
  AnimationDuration animationDuration = const AnimationDuration(),
}) {
  // TODO(@alexmercerind): WIP
  final isLightMode = mode == ThemeMode.light;
  final isDesktopPlatform =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // TYPOGRAPHY

  // Material Design 2021 typography.
  final typography = TypographyBuilder.material2021(colorScheme);

  // Apply the modifications to the original Material Design 2021 typography.
  final textColors = TextColors(
    colorScheme.onSurface,
    colorScheme.onSurfaceVariant,
    colorScheme.onSurface,
    colorScheme.onSurfaceVariant,
  );
  final primaryTextColor =
      isLightMode ? textColors.lightPrimary : textColors.darkPrimary;
  final secondaryTextColor =
      isLightMode ? textColors.lightSecondary : textColors.darkSecondary;
  // Enforce `Inter` font family on GNU/Linux.
  final fontFamily = Platform.isLinux ? 'Inter' : null;
  final theme = typography.englishLike
      .merge(mode == ThemeMode.light ? typography.black : typography.white)
      // Manually set the color for various text styles.
      // Here, I'm coloring text as primary or secondary.
      // On desktop, the two colors are black(1.0)/white(1.0) & black(0.87)/white(0.87).
      // On mobile, the two colors are black(0.87)/white(0.87) & black(0.54)/white(0.70).
      .merge(
        TextTheme(
          displayLarge: TextStyle(color: primaryTextColor),
          displayMedium: TextStyle(color: primaryTextColor),
          displaySmall: TextStyle(color: primaryTextColor),
          headlineLarge: TextStyle(color: primaryTextColor),
          headlineMedium: TextStyle(color: primaryTextColor),
          headlineSmall: TextStyle(color: primaryTextColor),
          titleLarge: TextStyle(color: primaryTextColor),
          titleMedium: TextStyle(color: primaryTextColor),
          titleSmall: TextStyle(color: primaryTextColor),
          bodyLarge: TextStyle(color: primaryTextColor),
          bodyMedium: TextStyle(color: secondaryTextColor),
          bodySmall: TextStyle(color: secondaryTextColor),
          labelLarge: TextStyle(color: primaryTextColor),
          labelMedium: TextStyle(color: primaryTextColor),
          labelSmall: TextStyle(color: primaryTextColor),
        ),
      )
      // Other modifications.
      .merge(
        TextTheme(
          bodyLarge: TextStyle(
            fontSize: 14.0, // Default: `16.0`
          ),
        ),
      )
      .apply(fontFamily: fontFamily);

  // COLORS

  final iconColors = IconColors(
    Color.lerp(Colors.white, colorScheme.primary, 0.54)!,
    Color.lerp(Colors.black, colorScheme.primary, 0.54)!,
    colorScheme.onSurface,
    colorScheme.onSurface,
    colorScheme.onSurfaceVariant,
    colorScheme.onSurfaceVariant,
    Color.lerp(Colors.white, Colors.black, 0.38)!,
    Color.lerp(Colors.black, Colors.white, 0.38)!,
  );

  final cardColor = Color.lerp(
    colorScheme.surface,
    colorScheme.surfaceTint,
    0.05,
  )!;
  final searchBarColor = Color.lerp(
    colorScheme.surface,
    colorScheme.surfaceTint,
    0.08,
  )!;
  final navigationBarColor = Color.lerp(
    colorScheme.surface,
    colorScheme.surfaceTint,
    0.08,
  )!;
  final dividerColor = colorScheme.outlineVariant;
  final dialogBackgroundColor = Color.lerp(
    colorScheme.surface,
    colorScheme.surfaceTint,
    0.11,
  );

  final searchBarTheme = SearchBarThemeData(
    borderRadius: BorderRadius.circular(28.0),
    accentColor: colorScheme.primary,
    backgroundColor: searchBarColor,
    shadowColor: colorScheme.shadow,
    elevation: 0.0,
    hintStyle: typography.englishLike.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    queryStyle: typography.englishLike.bodyLarge?.copyWith(
      color: colorScheme.onSurface,
    ),
  );
  // For access inside page route transitions.
  MaterialRoute.animationDuration = animationDuration;

  // NOTE: We are manually composing the resulting color of surfaces e.g. [Card] using
  // [ColorScheme.surface] & [ColorScheme.surfaceTint], because many external packages
  // aren't ready for the Material 3 specification & cannot separately handle the
  // tint / surface colors.
  // _ElevationOpacity(0.0, 0.0),   // Elevation level 0
  // _ElevationOpacity(1.0, 0.05),  // Elevation level 1
  // _ElevationOpacity(3.0, 0.08),  // Elevation level 2
  // _ElevationOpacity(6.0, 0.11),  // Elevation level 3
  // _ElevationOpacity(8.0, 0.12),  // Elevation level 4
  // _ElevationOpacity(12.0, 0.14), // Elevation level 5

  return ThemeData(
    useMaterial3: true, // REMOVE ONCE MATERIAL 3 IS RELEASED.

    // TYPOGRAPHY

    textTheme: theme,
    primaryTextTheme: theme,
    fontFamily: fontFamily,
    typography: typography,

    // COLORS

    colorScheme: colorScheme,
    dividerColor: dividerColor,
    iconTheme: IconThemeData(
      color: isLightMode ? iconColors.light : iconColors.dark,
      size: 24.0,
    ),

    // DIVIDER

    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1.0,
      indent: 0.0,
      endIndent: 0.0,
    ),

    // CARD

    cardTheme: CardTheme(
      elevation: 0.0,
      color: cardColor,
      surfaceTintColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),

    // FAB

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    ),

    // NAVIGATION BAR

    navigationBarTheme: NavigationBarThemeData(
      // https://m3.material.io/components/navigation-bar/specs.
      elevation: 0.0,
      backgroundColor: navigationBarColor,
      surfaceTintColor: navigationBarColor,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected) ||
            states.contains(MaterialState.focused)) {
          return theme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
          );
        }
        return theme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected) ||
            states.contains(MaterialState.focused)) {
          return IconThemeData(
            color: colorScheme.onSecondaryContainer,
          );
        }
        return IconThemeData(
          color: colorScheme.onSurfaceVariant,
        );
      }),
    ),

    // SCROLLBAR

    // Modify the default scrollbar theme on desktop.
    // This scrollbar feels more "Material" than the default one.
    // Thanks to @HrX03 for the this: https://github.com/PotatoProject/Leaflet/blob/11f87a85c8b49192a31fb069066bf9fdfdd755b0/lib/internal/theme/data.dart#L138-L154.
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: MaterialStatePropertyAll(true),
      thickness: MaterialStatePropertyAll(8.0),
      trackBorderColor: MaterialStatePropertyAll(
        isLightMode ? Colors.black12 : Colors.white24,
      ),
      trackColor: MaterialStatePropertyAll(
        isLightMode ? Colors.black12 : Colors.white24,
      ),
      crossAxisMargin: 0.0,
      radius: Radius.zero,
      minThumbLength: 96.0,
      thumbColor: MaterialStateProperty.resolveWith(
        (states) {
          if ([
            MaterialState.hovered,
            MaterialState.dragged,
            MaterialState.focused,
            MaterialState.pressed,
          ].fold(false, (val, el) => val || states.contains(el))) {
            return isLightMode ? Colors.black54 : Colors.white54;
          } else {
            return isLightMode ? Colors.black26 : Colors.white24;
          }
        },
      ),
    ),

    // DIALOG

    dialogTheme: DialogTheme(
      alignment: Alignment.center,
      elevation: 0.0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      backgroundColor: dialogBackgroundColor,
      titleTextStyle: theme.headlineSmall?.copyWith(color: primaryTextColor),
      contentTextStyle: theme.bodyMedium?.copyWith(color: secondaryTextColor),
      actionsPadding: EdgeInsets.zero.add(const EdgeInsets.all(8.0)),
    ),

    // APP BAR

    appBarTheme: AppBarTheme(
      elevation: 0.0,
      shadowColor: Colors.transparent,
      foregroundColor: primaryTextColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light,
      ),
      iconTheme: IconThemeData(
        color: isLightMode ? iconColors.appBarLight : iconColors.appBarDark,
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: isLightMode
            ? iconColors.appBarActionLight
            : iconColors.appBarActionDark,
        size: 24.0,
      ),
    ),

    // TOOLTIP

    // Modify default tooltip theme on desktop.
    tooltipTheme: isDesktopPlatform
        ? TooltipThemeData(
            textStyle: TextStyle(
              fontSize: 12.0,
              color: isLightMode ? Colors.white : Colors.black,
              fontFamily: fontFamily,
            ),
            decoration: BoxDecoration(
              color: isLightMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: null,
            verticalOffset: 36.0,
            preferBelow: true,
            waitDuration: const Duration(seconds: 1),
          )
        : null,

    // EXTENSIONS

    extensions: {
      iconColors,
      textColors,
      searchBarTheme,
      animationDuration,
      const MaterialStandard(3),
    },
  );
}

/// Creates consistent & strictly implemented Material Design 2 [ThemeData] based on the provided [color] and [mode].
ThemeData createM2Theme({
  required Color color,
  required ThemeMode mode,
  AnimationDuration animationDuration = const AnimationDuration(),
}) {
  final isLightMode = mode == ThemeMode.light;
  final isDesktopPlatform =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // TYPOGRAPHY

  // Material Design 2014 typography.

  final typography = TypographyBuilder.material2014();

  // Apply the modifications to the original Material Design 2014 typography.
  final textColors = TextColors(
    isDesktopPlatform ? Colors.black : Colors.black.withOpacity(0.87),
    isDesktopPlatform ? Colors.white : Colors.white.withOpacity(1.00),
    isDesktopPlatform
        ? Colors.black.withOpacity(0.87)
        : Colors.black.withOpacity(0.54),
    isDesktopPlatform
        ? Colors.white.withOpacity(0.87)
        : Colors.white.withOpacity(0.87),
  );
  final primaryTextColor =
      isLightMode ? textColors.lightPrimary : textColors.darkPrimary;
  final secondaryTextColor =
      isLightMode ? textColors.lightSecondary : textColors.darkSecondary;
  // Enforce `Inter` font family on GNU/Linux.
  final fontFamily = Platform.isLinux ? 'Inter' : null;
  final theme = typography.englishLike
      .merge(mode == ThemeMode.light ? typography.black : typography.white)
      // Manually set the color for various text styles.
      // Here, I'm coloring text as primary or secondary.
      // On desktop, the two colors are black(1.0)/white(1.0) & black(0.87)/white(0.87).
      // On mobile, the two colors are black(0.87)/white(0.87) & black(0.54)/white(0.70).
      .merge(
        TextTheme(
          displayLarge: TextStyle(color: primaryTextColor),
          displayMedium: TextStyle(color: primaryTextColor),
          displaySmall: TextStyle(color: primaryTextColor),
          headlineLarge: TextStyle(color: primaryTextColor),
          headlineMedium: TextStyle(color: primaryTextColor),
          headlineSmall: TextStyle(color: primaryTextColor),
          titleLarge: TextStyle(color: primaryTextColor),
          titleMedium: TextStyle(color: primaryTextColor),
          titleSmall: TextStyle(color: primaryTextColor),
          bodyLarge: TextStyle(color: primaryTextColor),
          bodyMedium: TextStyle(color: secondaryTextColor),
          bodySmall: TextStyle(color: secondaryTextColor),
          labelLarge: TextStyle(color: primaryTextColor),
          labelMedium: TextStyle(color: primaryTextColor),
          labelSmall: TextStyle(color: primaryTextColor),
        ),
      )
      // Other modifications.
      .merge(
        TextTheme(
          headlineLarge: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : FontWeight.w500, // Default: `FontWeight.w400`
          ),
          headlineMedium: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : FontWeight.w500, // Default: `FontWeight.w400`
          ),
          headlineSmall: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : FontWeight.w500, // Default: `FontWeight.w400`
          ),
          titleLarge: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : FontWeight.w500, // Default: `FontWeight.w500`
          ),
          titleMedium: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : null, // Default: `FontWeight.w400`
          ),
          titleSmall: TextStyle(
            fontWeight: isDesktopPlatform
                ? FontWeight.w600
                : FontWeight.w500, // Default: `FontWeight.w500`
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400, // Default: `FontWeight.w500`
          ),
          labelLarge: TextStyle(
            letterSpacing: isDesktopPlatform ? 1.0 : 0.0, // Default: `0.0`,
          ),
        ),
      )
      .apply(fontFamily: fontFamily);

  // COLORS

  // Material Design 2 color scheme based on single primary color.
  final colorScheme = ColorScheme(
    brightness: isLightMode ? Brightness.light : Brightness.dark,
    // Assign all these fucks to the primary color.
    primary: color,
    onPrimary: color.computeLuminance() > 0.7 ? Colors.black : Colors.white,
    secondary: color,
    onSecondary: color.computeLuminance() > 0.7 ? Colors.black : Colors.white,
    tertiary: color,
    onTertiary: color.computeLuminance() > 0.7 ? Colors.black : Colors.white,
    error: Colors.red.shade800,
    onError: Colors.white,
    background: isLightMode ? Colors.white : Colors.black,
    onBackground: primaryTextColor,
    // [Card] color.
    surface: isLightMode ? Colors.white : const Color(0xFF222222),
    onSurface: primaryTextColor,
    surfaceVariant: isLightMode
        ? Color.lerp(Colors.white, Colors.black, 0.04)
        : Color.lerp(Colors.black, Colors.white, 0.12),
    onSurfaceVariant: isLightMode
        ? Color.lerp(Colors.white, Colors.black, 0.54)
        : Color.lerp(Colors.black, Colors.white, 0.54),
    // Remove the fucking tint from popup menus, bottom sheets etc.
    surfaceTint: Colors.transparent,
    // Keep the Material Design 2 shadow.
    shadow: Colors.black,
    secondaryContainer: isLightMode ? Colors.white : const Color(0xFF222222),
    onSecondaryContainer: secondaryTextColor,
  );
  // Additional colors based on official Material Design 2 guidelines.
  final iconColors = IconColors(
    Color.lerp(Colors.white, Colors.black, 0.54)!,
    Color.lerp(Colors.black, Colors.white, 0.54)!,
    Color.lerp(Colors.white, Colors.black, 0.70)!,
    Color.lerp(Colors.black, Colors.white, 1.00)!,
    Color.lerp(Colors.white, Colors.black, 0.70)!,
    Color.lerp(Colors.black, Colors.white, 1.00)!,
    Color.lerp(Colors.white, Colors.black, 0.38)!,
    Color.lerp(Colors.black, Colors.white, 0.38)!,
  );
  final focusColor = isLightMode
      ? Colors.black.withOpacity(0.12)
      : Colors.white.withOpacity(0.12);
  final hoverColor = isLightMode
      ? Colors.black.withOpacity(0.04)
      : Colors.white.withOpacity(0.04);
  final splashColor = isLightMode ? const Color(0x40CCCCCC) : Color(0x40CCCCCC);
  final disabledColor =
      isLightMode ? iconColors.lightDisabled : iconColors.darkDisabled;
  // Keep the Material Design 2 shadow.
  final shadowColor = Colors.black;
  final highlightColor = isDesktopPlatform
      ? isLightMode
          ? const Color(0x66BCBCBC)
          : const Color(0x40CCCCCC)
      :
      // Disable highlight on mobile devices.
      Colors.transparent;
  final cardColor = isLightMode ? Colors.white : const Color(0xFF222222);
  final scaffoldBackgroundColor = isLightMode ? Colors.white : Colors.black;
  final dialogBackgroundColor =
      isLightMode ? Colors.white : const Color(0xFF202020);
  final unselectedWidgetColor = isLightMode ? Colors.black54 : Colors.white70;
  final popupMenuColor = isLightMode ? Colors.white : const Color(0xFF282828);
  final snackBarColor = isLightMode ? Colors.white : const Color(0xFF282828);

  final searchBarTheme = SearchBarThemeData(
    borderRadius: BorderRadius.circular(4.0),
    accentColor: color,
    backgroundColor: cardColor,
    shadowColor: Colors.black,
    elevation: 4.0,
    hintStyle: TextStyle(
      fontSize: 16.0,
      color: colorScheme.onSurfaceVariant,
    ),
    queryStyle: TextStyle(
      fontSize: 16.0,
      color: colorScheme.onSurface,
    ),
  );
  // For access inside page route transitions.
  MaterialRoute.animationDuration = animationDuration;

  return ThemeData(
    useMaterial3: false, // REMOVE ONCE MATERIAL 3 IS RELEASED.

    // TYPOGRAPHY

    textTheme: theme,
    primaryTextTheme: theme,
    fontFamily: fontFamily,
    typography: typography,

    // COLORS

    primaryColor: color,

    colorScheme: colorScheme,

    focusColor: focusColor,
    hoverColor: hoverColor,
    splashColor: splashColor,
    disabledColor: disabledColor,
    shadowColor: shadowColor,
    highlightColor: highlightColor,
    cardColor: cardColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    dialogBackgroundColor: dialogBackgroundColor,
    unselectedWidgetColor: unselectedWidgetColor,

    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(
      color: isLightMode ? iconColors.light : iconColors.dark,
      size: 24.0,
    ),

    // BUTTONS

    // Keep FABs circular as in Material Design 2.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 6,
      focusElevation: 6,
      hoverElevation: 8,
      highlightElevation: 12,
      enableFeedback: true,
      sizeConstraints: const BoxConstraints.tightFor(
        width: 56.0,
        height: 56.0,
      ),
      smallSizeConstraints: const BoxConstraints.tightFor(
        width: 40.0,
        height: 40.0,
      ),
      largeSizeConstraints: const BoxConstraints.tightFor(
        width: 96.0,
        height: 96.0,
      ),
      extendedSizeConstraints: const BoxConstraints.tightFor(
        height: 48.0,
      ),
      extendedIconLabelSpacing: 8.0,
      foregroundColor: colorScheme.onSecondary,
      backgroundColor: colorScheme.secondary,
      // NOTE: [FloatingActionButton.extended] have stadium border & needs to be handled separately.
      shape: CircleBorder(),
      iconSize: 24.0,
      extendedPadding: EdgeInsetsDirectional.only(start: 16.0, end: 20.0),
      extendedTextStyle: theme.labelLarge?.copyWith(letterSpacing: 1.2),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        // Keep the Material Design 2 color.
        backgroundColor: MaterialStatePropertyAll(Colors.transparent),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.38);
          }
          return colorScheme.primary;
        }),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.primary.withOpacity(0.04);
          }
          if (states.contains(MaterialState.focused)) {
            return colorScheme.primary.withOpacity(0.12);
          }
          if (states.contains(MaterialState.pressed)) {
            return colorScheme.primary.withOpacity(0.12);
          }
          return null;
        }),
        // Keep the Material Design 2 side.
        side: MaterialStatePropertyAll(BorderSide.none),
        // Keep the Material Design 2 rounded rectangle shape.
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        padding: MaterialStatePropertyAll(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.all(8),
            const EdgeInsets.symmetric(horizontal: 8),
            const EdgeInsets.symmetric(horizontal: 4),
            window.textScaleFactor,
          ),
        ),
        // Keep the Material Design 2 shadow.
        shadowColor: const MaterialStatePropertyAll(Colors.transparent),
        elevation: const MaterialStatePropertyAll(0.0),
        minimumSize: MaterialStatePropertyAll(const Size(64.0, 36.0)),
        fixedSize: null,
        maximumSize: MaterialStatePropertyAll(Size.infinite),
        alignment: Alignment.center,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        // Keep the Material Design 2 color.
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.12);
          }
          return colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.38);
          }
          return colorScheme.onPrimary;
        }),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.onPrimary.withOpacity(0.08);
          }
          if (states.contains(MaterialState.focused)) {
            return colorScheme.onPrimary.withOpacity(0.24);
          }
          if (states.contains(MaterialState.pressed)) {
            return colorScheme.onPrimary.withOpacity(0.24);
          }
          return null;
        }),
        // Keep the Material Design 2 shadow.
        shadowColor: const MaterialStatePropertyAll(Colors.black),
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return 0.0;
          }
          if (states.contains(MaterialState.hovered)) {
            return 4.0;
          }
          if (states.contains(MaterialState.focused)) {
            return 4.0;
          }
          if (states.contains(MaterialState.pressed)) {
            return 8.0;
          }
          return 2.0;
        }),
        // Keep the Material Design 2 side.
        side: MaterialStatePropertyAll(BorderSide.none),
        // Keep the Material Design 2 rounded rectangle shape.
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        padding: MaterialStatePropertyAll(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.symmetric(horizontal: 16),
            const EdgeInsets.symmetric(horizontal: 8),
            const EdgeInsets.symmetric(horizontal: 4),
            window.textScaleFactor,
          ),
        ),
        minimumSize: MaterialStatePropertyAll(const Size(64.0, 36.0)),
        fixedSize: null,
        maximumSize: MaterialStatePropertyAll(Size.infinite),
        alignment: Alignment.center,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        // Keep the Material Design 2 color.
        backgroundColor: MaterialStatePropertyAll(Colors.transparent),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.38);
          }
          return colorScheme.primary;
        }),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.primary.withOpacity(0.04);
          }
          if (states.contains(MaterialState.focused)) {
            return colorScheme.primary.withOpacity(0.12);
          }
          if (states.contains(MaterialState.pressed)) {
            return colorScheme.primary.withOpacity(0.12);
          }
          return null;
        }),
        // Keep the Material Design 2 side.
        side: MaterialStatePropertyAll(
          BorderSide(
            width: 1,
            color: colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
        // Keep the Material Design 2 rounded rectangle shape.
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        padding: MaterialStatePropertyAll(
          ButtonStyleButton.scaledPadding(
            const EdgeInsets.all(8),
            const EdgeInsets.symmetric(horizontal: 8),
            const EdgeInsets.symmetric(horizontal: 4),
            window.textScaleFactor,
          ),
        ),
        shadowColor: const MaterialStatePropertyAll(Colors.transparent),
        elevation: const MaterialStatePropertyAll(0.0),
        minimumSize: MaterialStatePropertyAll(const Size(64.0, 36.0)),
        fixedSize: null,
        maximumSize: MaterialStatePropertyAll(Size.infinite),
        alignment: Alignment.center,
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isDesktopPlatform
          ? isLightMode
              ? Colors.black
              : Colors.white
          : colorScheme.primary,
      selectionHandleColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withOpacity(0.2),
    ),

    // PROGRESS INDICATORS

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primary.withOpacity(0.2),
      circularTrackColor: Colors.transparent,
    ),

    // DATA TABLES

    dataTableTheme: DataTableThemeData(
      headingRowHeight: 48.0,
      dataRowHeight: 48.0,
      headingTextStyle: theme.titleSmall,
      dataTextStyle: theme.bodyLarge,
    ),

    // CARD, POPUP MENU & APP BAR

    cardTheme: CardTheme(
      elevation: 4.0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 4.0,
      color: popupMenuColor,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    appBarTheme: AppBarTheme(
      // Keep the Material Design 2 shadow.
      shadowColor: Colors.black,
      backgroundColor: isDesktopPlatform
          ? isLightMode
              ? Colors.white
              : const Color(0xFF272727)
          : isLightMode
              ? Colors.white
              : const Color(0xFF202020),
      foregroundColor: primaryTextColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: isLightMode ? Colors.white12 : Colors.black12,
        statusBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light,
      ),
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: isLightMode ? iconColors.appBarLight : iconColors.appBarDark,
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: isLightMode
            ? iconColors.appBarActionLight
            : iconColors.appBarActionDark,
        size: 24.0,
      ),
    ),

    // PAGE TRANSITIONS

    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(
          allowEnterRouteSnapshotting: false,
        ),
        TargetPlatform.android: ZoomPageTransitionsBuilder(
         allowEnterRouteSnapshotting: false,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    // DIVIDER

    dividerTheme: DividerThemeData(
      color: isLightMode ? Colors.black12 : Colors.white24,
      thickness: 1.0,
      indent: 0.0,
      endIndent: 0.0,
    ),

    // RADIO BUTTON

    radioTheme: () {
      final fillColor = MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledColor;
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary;
          }
          return unselectedWidgetColor;
        },
      );
      return RadioThemeData(
        fillColor: fillColor,
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return fillColor.resolve(states).withAlpha(0x1F);
            }
            if (states.contains(MaterialState.focused)) {
              return focusColor;
            }
            if (states.contains(MaterialState.hovered)) {
              return hoverColor;
            }
            return null;
          },
        ),
      );
    }(),

    // CHECKBOX

    checkboxTheme: () {
      final fillColor = MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledColor;
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary;
          }
          return unselectedWidgetColor;
        },
      );
      return CheckboxThemeData(
        fillColor: fillColor,
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return fillColor.resolve(states).withAlpha(0x1F);
            }
            if (states.contains(MaterialState.focused)) {
              return focusColor;
            }
            if (states.contains(MaterialState.hovered)) {
              return hoverColor;
            }
            return null;
          },
        ),
      );
    }(),

    // LISTTILE

    // Revert https://github.com/flutter/flutter/pull/117965 to keep Material Design 2.
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      minLeadingWidth: 40.0,
      minVerticalPadding: 4.0,
      shape: const Border(),
      tileColor: Colors.transparent,
      titleTextStyle: theme.titleMedium,
      subtitleTextStyle: theme.bodyMedium,
      leadingAndTrailingTextStyle: theme.bodyMedium,
      selectedColor: colorScheme.primary,
      iconColor: isLightMode ? iconColors.light : iconColors.dark,
    ),

    // DIALOG

    // [DialogTheme] is extensively different in Material Design 2.
    dialogTheme: DialogTheme(
      alignment: Alignment.center,
      // Keep the Material Design 2 shadow.
      elevation: 24.0,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      backgroundColor: dialogBackgroundColor,
      // In MD3, the title text is [headlineSmall] & the content text is [bodyMedium].
      // This results in a mismatch when enforcing the Material Design 2 style.
      titleTextStyle: theme.titleLarge?.copyWith(color: primaryTextColor),
      contentTextStyle: theme.bodyMedium?.copyWith(color: secondaryTextColor),
      actionsPadding: EdgeInsets.zero.add(const EdgeInsets.all(8.0)),
    ),

    // BOTTOM SHEET

    bottomSheetTheme: BottomSheetThemeData(
      // Keep the Material Design 2 shadow.
      elevation: 24.0,
      shape: RoundedRectangleBorder(
        // Disable rounded corners as in Material Design 2.
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: isLightMode ? Colors.white : const Color(0xFF202020),
    ),

    // SCROLLBAR

    // Modify the default scrollbar theme on desktop.
    // This scrollbar feels more "Material" than the default one.
    // Thanks to @HrX03 for the this: https://github.com/PotatoProject/Leaflet/blob/11f87a85c8b49192a31fb069066bf9fdfdd755b0/lib/internal/theme/data.dart#L138-L154.
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: MaterialStatePropertyAll(true),
      thickness: MaterialStatePropertyAll(8.0),
      trackBorderColor: MaterialStatePropertyAll(
          isLightMode ? Colors.black12 : Colors.white24),
      trackColor: MaterialStatePropertyAll(
          isLightMode ? Colors.black12 : Colors.white24),
      crossAxisMargin: 0.0,
      radius: Radius.zero,
      minThumbLength: 96.0,
      thumbColor: MaterialStateProperty.resolveWith(
        (states) {
          if ([
            MaterialState.hovered,
            MaterialState.dragged,
            MaterialState.focused,
            MaterialState.pressed,
          ].fold(false, (val, el) => val || states.contains(el))) {
            return isLightMode ? Colors.black54 : Colors.white54;
          } else {
            return isLightMode ? Colors.black26 : Colors.white24;
          }
        },
      ),
    ),

    // TOOLTIP

    // Modify default tooltip theme on desktop.
    tooltipTheme: isDesktopPlatform
        ? TooltipThemeData(
            textStyle: TextStyle(
              fontSize: 12.0,
              color: isLightMode ? Colors.white : Colors.black,
              fontFamily: fontFamily,
            ),
            decoration: BoxDecoration(
              color: isLightMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: null,
            verticalOffset: 36.0,
            preferBelow: true,
            waitDuration: const Duration(seconds: 1),
          )
        : null,

    // TAB BAR & BOTTOM NAVIGATION BAR

    tabBarTheme: TabBarTheme(
      // Use the color as selected label color on non-desktop platforms.
      labelColor: colorScheme.primary,
      unselectedLabelColor: secondaryTextColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.primary,
      selectedItemColor: color.computeLuminance() > 0.7
          ? Colors.black.withOpacity(0.87)
          : Colors.white.withOpacity(0.87),
      unselectedItemColor: color.computeLuminance() > 0.7
          ? Colors.black.withOpacity(0.54)
          : Colors.white.withOpacity(0.54),
    ),

    // MAY NEED REVIEW

    snackBarTheme: SnackBarThemeData(
      backgroundColor: snackBarColor,
      actionTextColor: colorScheme.primary,
    ),

    // EXTENSIONS

    extensions: {
      iconColors,
      textColors,
      searchBarTheme,
      animationDuration,
      const MaterialStandard(2),
    },
  );
}

class MaterialRoute extends MaterialPageRoute {
  MaterialRoute({required WidgetBuilder builder}) : super(builder: builder);

  /// Reference to the [AnimationDuration] instance registered in the [ThemeData] as [ThemeExtension].
  static AnimationDuration? animationDuration;

  /// Default transition duration for the [MaterialRoute].
  static const kDefaultTransitionDuration = Duration(milliseconds: 300);

  @override
  Duration get transitionDuration =>
      animationDuration?.medium ?? kDefaultTransitionDuration;
}

/// Theme extension for providing style for the search bar used on mobile devices.
class SearchBarThemeData extends ThemeExtension<SearchBarThemeData> {
  final BorderRadius borderRadius;
  final Color accentColor;
  final Color backgroundColor;
  final Color shadowColor;
  final double elevation;
  final TextStyle? hintStyle;
  final TextStyle? queryStyle;

  SearchBarThemeData({
    required this.borderRadius,
    required this.accentColor,
    required this.backgroundColor,
    required this.shadowColor,
    required this.elevation,
    required this.hintStyle,
    required this.queryStyle,
  });

  @override
  ThemeExtension<SearchBarThemeData> copyWith({
    BorderRadius? borderRadius,
    Color? accentColor,
    Color? backgroundColor,
    Color? shadowColor,
    double? elevation,
    TextStyle? hintStyle,
    TextStyle? queryStyle,
  }) {
    return SearchBarThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      hintStyle: hintStyle ?? this.hintStyle,
      queryStyle: queryStyle ?? this.queryStyle,
    );
  }

  @override
  ThemeExtension<SearchBarThemeData> lerp(
    ThemeExtension<SearchBarThemeData>? other,
    double t,
  ) {
    if (other is! SearchBarThemeData) {
      return this;
    }
    return SearchBarThemeData(
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t)!,
      queryStyle: TextStyle.lerp(queryStyle, other.queryStyle, t)!,
    );
  }
}

/// Theme extension for providing the current Material Design standard e.g.
/// Material Design 2 or Material Design 3.
class MaterialStandard extends ThemeExtension<MaterialStandard> {
  final int value;

  const MaterialStandard(this.value);

  @override
  ThemeExtension<MaterialStandard> copyWith({int? value}) {
    return MaterialStandard(value ?? this.value);
  }

  @override
  ThemeExtension<MaterialStandard> lerp(
    ThemeExtension<MaterialStandard>? other,
    double t,
  ) {
    if (other is! MaterialStandard) {
      return this;
    }
    return MaterialStandard(other.value);
  }
}

/// Theme extension for providing various animation durations.
/// This is used to change the speed of animations in the app (or disabling them completely).
class AnimationDuration extends ThemeExtension<AnimationDuration> {
  final Duration fast;
  final Duration medium;
  final Duration slow;

  const AnimationDuration({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 300),
    this.slow = const Duration(milliseconds: 450),
  });

  factory AnimationDuration.fromJson(Map<String, dynamic> json) {
    return AnimationDuration(
      fast: Duration(milliseconds: json['fast'] as int),
      medium: Duration(milliseconds: json['medium'] as int),
      slow: Duration(milliseconds: json['slow'] as int),
    );
  }

  factory AnimationDuration.disabled() {
    return AnimationDuration(
      fast: Duration.zero,
      medium: Duration.zero,
      slow: Duration.zero,
    );
  }

  @override
  ThemeExtension<AnimationDuration> copyWith({
    bool? enabled,
    Duration? fast,
    Duration? medium,
    Duration? slow,
  }) {
    return AnimationDuration(
      fast: fast ?? this.fast,
      medium: medium ?? this.medium,
      slow: slow ?? this.slow,
    );
  }

  @override
  ThemeExtension<AnimationDuration> lerp(
    ThemeExtension<AnimationDuration>? other,
    double t,
  ) {
    if (other is! AnimationDuration) {
      return this;
    }
    return AnimationDuration(
      fast: fast * (1 - t) + other.fast * t,
      medium: medium * (1 - t) + other.medium * t,
      slow: slow * (1 - t) + other.slow * t,
    );
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimationDuration &&
        other.fast == fast &&
        other.medium == medium &&
        other.slow == slow;
  }

  @override
  int get hashCode => fast.hashCode ^ medium.hashCode ^ slow.hashCode;

  @override
  String toString() {
    return 'AnimationDuration(fast: $fast, medium: $medium, slow: $slow)';
  }

  Map<String, int> toJson() {
    return {
      'fast': fast.inMilliseconds,
      'medium': medium.inMilliseconds,
      'slow': slow.inMilliseconds,
    };
  }
}

/// Theme extension for providing various text colors independent of the the current [Brightness].
class TextColors extends ThemeExtension<TextColors> {
  final Color lightPrimary;
  final Color darkPrimary;
  final Color lightSecondary;
  final Color darkSecondary;

  const TextColors(
    this.lightPrimary,
    this.darkPrimary,
    this.lightSecondary,
    this.darkSecondary,
  );

  @override
  ThemeExtension<TextColors> copyWith({
    Color? lightPrimary,
    Color? darkPrimary,
    Color? lightSecondary,
    Color? darkSecondary,
  }) {
    return TextColors(
      lightPrimary ?? this.lightPrimary,
      darkPrimary ?? this.darkPrimary,
      lightSecondary ?? this.lightSecondary,
      darkSecondary ?? this.darkSecondary,
    );
  }

  @override
  ThemeExtension<TextColors> lerp(
    ThemeExtension<TextColors>? other,
    double t,
  ) {
    if (other is! TextColors) {
      return this;
    }
    return TextColors(
      Color.lerp(
            lightPrimary,
            other.lightPrimary,
            t,
          ) ??
          lightPrimary,
      Color.lerp(
            darkPrimary,
            other.darkPrimary,
            t,
          ) ??
          darkPrimary,
      Color.lerp(
            lightSecondary,
            other.lightSecondary,
            t,
          ) ??
          lightSecondary,
      Color.lerp(
            darkSecondary,
            other.darkSecondary,
            t,
          ) ??
          darkSecondary,
    );
  }
}

/// Theme extension for providing various icon colors independent of the the current [Brightness] e.g.
/// Default icon colors, [AppBar] leading button & action buttons icons.
class IconColors extends ThemeExtension<IconColors> {
  final Color light;
  final Color dark;
  final Color appBarLight;
  final Color appBarDark;
  final Color appBarActionLight;
  final Color appBarActionDark;
  final Color lightDisabled;
  final Color darkDisabled;

  const IconColors(
    this.light,
    this.dark,
    this.appBarLight,
    this.appBarDark,
    this.appBarActionLight,
    this.appBarActionDark,
    this.lightDisabled,
    this.darkDisabled,
  );

  @override
  ThemeExtension<IconColors> copyWith({
    Color? light,
    Color? dark,
    Color? appBarLight,
    Color? appBarDark,
    Color? appBarActionLight,
    Color? appBarActionDark,
    Color? lightDisabled,
    Color? darkDisabled,
  }) {
    return IconColors(
      light ?? this.light,
      dark ?? this.dark,
      appBarLight ?? this.appBarLight,
      appBarDark ?? this.appBarDark,
      appBarActionLight ?? this.appBarActionLight,
      appBarActionDark ?? this.appBarActionDark,
      lightDisabled ?? this.lightDisabled,
      darkDisabled ?? this.darkDisabled,
    );
  }

  @override
  ThemeExtension<IconColors> lerp(ThemeExtension<IconColors>? other, double t) {
    if (other is! IconColors) {
      return this;
    }
    return IconColors(
      Color.lerp(
            light,
            other.light,
            t,
          ) ??
          light,
      Color.lerp(
            dark,
            other.dark,
            t,
          ) ??
          dark,
      Color.lerp(
            appBarLight,
            other.appBarLight,
            t,
          ) ??
          appBarLight,
      Color.lerp(
            appBarDark,
            other.appBarDark,
            t,
          ) ??
          appBarDark,
      Color.lerp(
            appBarActionLight,
            other.appBarActionLight,
            t,
          ) ??
          appBarActionLight,
      Color.lerp(
            appBarActionDark,
            other.appBarActionDark,
            t,
          ) ??
          appBarActionDark,
      Color.lerp(
            lightDisabled,
            other.lightDisabled,
            t,
          ) ??
          lightDisabled,
      Color.lerp(
            darkDisabled,
            other.darkDisabled,
            t,
          ) ??
          darkDisabled,
    );
  }
}
