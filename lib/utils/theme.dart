/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

// DO NOT IMPORT ANYTHING FROM `package:harmonoid` IN THIS FILE.

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData createM3Theme({
  required ColorScheme colorScheme,
  required ThemeMode mode,
}) {
  final isLightMode = mode == ThemeMode.light;
  final isDesktopPlatform =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // TYPOGRAPHY

  // Material Design 2021 typography.
  TextTheme theme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displayMedium: TextStyle(
      fontSize: 45.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.16,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displaySmall: TextStyle(
      fontSize: 36.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.22,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.25,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineMedium: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.29,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineSmall: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.33,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleLarge: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      height: 1.27,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelSmall: TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  // Apply the modifications to the original Material Design 2021 typography.
  final primaryTextColor = colorScheme.onSurface;
  final secondaryTextColor = colorScheme.onSurfaceVariant;
  theme = theme.merge(
    isDesktopPlatform
        ? TextTheme(
            // Leading tile widgets text theme.
            displayLarge: TextStyle(
              color: primaryTextColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            // [AlbumTile] text theme.
            displayMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            displaySmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            headlineMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            headlineSmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
            // [ListTile] text theme.
            // [ListTile.title]'s text theme must be overrided to [headlineMedium], if it does not contain subtitle.
            titleMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            bodySmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            // Normal text shown everywhere.
            bodyMedium: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            // Used as [DataTable]'s column title text-theme.
            titleSmall: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            // Used as [AlertDialog]'s [title] text-theme.
            titleLarge: TextStyle(
              color: primaryTextColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            // Modify button text theme on desktop to be more consistent.
            labelLarge: TextStyle(
              letterSpacing: Platform.isLinux ? 0.8 : 1.6,
              fontWeight: FontWeight.w600,
            ),
          )
        : TextTheme(
            displayLarge: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 18.0,
            ),
            displayMedium: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 16.0,
            ),
            displaySmall: TextStyle(
              fontWeight: FontWeight.normal,
              color: secondaryTextColor,
              fontSize: 14.0,
            ),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 14.0,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.normal,
              color: secondaryTextColor,
              fontSize: 14.0,
            ),
            // [ListTile] text theme.
            titleMedium: TextStyle(color: primaryTextColor),
            bodySmall: TextStyle(color: secondaryTextColor),
          ),
  );
  // Enforce `Inter` font family on GNU/Linux.
  final fontFamily = Platform.isLinux ? 'Inter' : null;
  theme = theme.apply(fontFamily: fontFamily);

  // COLORS

  final iconColors = IconColors(
    Color.lerp(Colors.white, colorScheme.primary, 0.54),
    Color.lerp(Colors.black, colorScheme.primary, 0.54),
    colorScheme.onSurface,
    colorScheme.onSurface,
    colorScheme.onSurfaceVariant,
    colorScheme.onSurfaceVariant,
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

  final animationDuration = AnimationDuration();
  final searchBarTheme = SearchBarThemeData(
    borderRadius: BorderRadius.circular(28.0),
    accentColor: colorScheme.primary,
    backgroundColor: searchBarColor,
    shadowColor: colorScheme.shadow,
    elevation: 0.0,
    hintStyle: theme.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    queryStyle: theme.bodyLarge?.copyWith(
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

  // Edge-to-edge content.

  return ThemeData(
    useMaterial3: true,

    // TYPOGRAPHY

    textTheme: theme,
    primaryTextTheme: theme,
    fontFamily: fontFamily,

    // COLORS

    colorScheme: colorScheme,
    iconTheme: IconThemeData(
      color: isLightMode ? iconColors.lightIconColor : iconColors.darkIconColor,
      size: 24.0,
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
        color: isLightMode
            ? iconColors.appBarLightIconColor
            : iconColors.appBarDarkIconColor,
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: isLightMode
            ? iconColors.appBarActionLightIconColor
            : iconColors.appBarActionDarkIconColor,
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
      animationDuration,
      searchBarTheme,
      const MaterialStandard(3),
    },
  );
}

ThemeData createM2Theme({
  required Color color,
  required ThemeMode mode,
}) {
  final isLightMode = mode == ThemeMode.light;
  final isDesktopPlatform =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // TYPOGRAPHY

  // Material Design 2014 typography.
  TextTheme theme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 112.0,
      fontWeight: FontWeight.w100,
      letterSpacing: 0.0,
    ),
    displayMedium: TextStyle(
      fontSize: 56.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    displaySmall: TextStyle(
      fontSize: 45.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    headlineLarge: TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    headlineMedium: TextStyle(
      fontSize: 34.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    labelSmall: TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    ),
  );
  // Apply the modifications to the original Material Design 2014 typography.
  final primaryTextColor = isDesktopPlatform
      ? isLightMode
          ? Colors.black
          : Colors.white
      : isLightMode
          ? Colors.black.withOpacity(0.87)
          : Colors.white.withOpacity(0.87);
  final secondaryTextColor = isDesktopPlatform
      ? isLightMode
          ? Colors.black.withOpacity(0.87)
          : Colors.white.withOpacity(0.87)
      : isLightMode
          ? Colors.black.withOpacity(0.54)
          : Colors.white.withOpacity(0.70);
  theme = theme.merge(
    isDesktopPlatform
        ? TextTheme(
            // Leading tile widgets text theme.
            displayLarge: TextStyle(
              color: primaryTextColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            // [AlbumTile] text theme.
            displayMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            displaySmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            headlineMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            headlineSmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
            // [ListTile] text theme.
            // [ListTile.title]'s text theme must be overrided to [headlineMedium], if it does not contain subtitle.
            titleMedium: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            bodySmall: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            // Normal text shown everywhere.
            bodyMedium: TextStyle(
              color: secondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            // Used as [DataTable]'s column title text-theme.
            titleSmall: TextStyle(
              color: primaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            // Used as [AlertDialog]'s [title] text-theme.
            titleLarge: TextStyle(
              color: primaryTextColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            // Modify button text theme on desktop to be more consistent.
            labelLarge: TextStyle(
              letterSpacing: Platform.isLinux ? 0.8 : 1.6,
              fontWeight: FontWeight.w600,
            ),
          )
        : TextTheme(
            displayLarge: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 18.0,
            ),
            displayMedium: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 16.0,
            ),
            displaySmall: TextStyle(
              fontWeight: FontWeight.normal,
              color: secondaryTextColor,
              fontSize: 14.0,
            ),
            headlineMedium: TextStyle(
              fontWeight: FontWeight.normal,
              color: primaryTextColor,
              fontSize: 14.0,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.normal,
              color: secondaryTextColor,
              fontSize: 14.0,
            ),
            // [ListTile] text theme. Exactly same as 2014's except color.
            titleMedium: TextStyle(color: primaryTextColor),
            bodySmall: TextStyle(color: secondaryTextColor),
            // [FloatingSearchBar] search text theme.
            bodyLarge: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
            ),
          ),
  );
  // Enforce `Inter` font family on GNU/Linux.
  final fontFamily = Platform.isLinux ? 'Inter' : null;
  theme = theme.apply(fontFamily: fontFamily);

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
    surfaceVariant: isLightMode ? Colors.white : const Color(0xFF222222),
    onSurfaceVariant: secondaryTextColor,
    // Remove the fucking tint from popup menus, bottom sheets etc.
    surfaceTint: Colors.transparent,
    // Keep the Material Design 2 shadow.
    shadow: Colors.black,
  );
  // Additional colors based on official Material Design 2 guidelines.
  final focusColor = isLightMode
      ? Colors.black.withOpacity(0.12)
      : Colors.white.withOpacity(0.12);
  final hoverColor = isLightMode
      ? Colors.black.withOpacity(0.04)
      : Colors.white.withOpacity(0.04);
  final splashColor = isLightMode ? const Color(0x40CCCCCC) : Color(0x40CCCCCC);
  final disabledColor = isLightMode
      ? Color.lerp(Colors.white, Colors.black, 0.38)
      : Color.lerp(Colors.black, Colors.white, 0.38);
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
  final iconColors = IconColors(
    Color.lerp(Colors.white, Colors.black, 0.54),
    Color.lerp(Colors.black, Colors.white, 0.54),
    Color.lerp(Colors.white, Colors.black, 0.70),
    Color.lerp(Colors.black, Colors.white, 1.0),
    Color.lerp(Colors.white, Colors.black, 0.70),
    Color.lerp(Colors.black, Colors.white, 1.0),
  );

  final animationDuration = AnimationDuration();
  final searchBarTheme = SearchBarThemeData(
    borderRadius: BorderRadius.circular(4.0),
    accentColor: color,
    backgroundColor: cardColor,
    shadowColor: Colors.black,
    elevation: 4.0,
    hintStyle: theme.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    queryStyle: theme.bodyLarge?.copyWith(
      color: colorScheme.onSurface,
    ),
  );
  // For access inside page route transitions.
  MaterialRoute.animationDuration = animationDuration;

  return ThemeData(
    useMaterial3: true,

    // TYPOGRAPHY

    textTheme: theme,
    primaryTextTheme: theme,
    fontFamily: fontFamily,

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
      color: isLightMode ? iconColors.lightIconColor : iconColors.darkIconColor,
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
        }),
        // Keep the Material Design 2 shadow.
        shadowColor: const MaterialStatePropertyAll(Colors.transparent),
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

    // CARD, POPUP MENU & APP BAR

    cardTheme: CardTheme(
      elevation: 4.0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 4.0,
      color: popupMenuColor,
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
        color: isLightMode
            ? iconColors.appBarLightIconColor
            : iconColors.appBarDarkIconColor,
        size: 24.0,
      ),
      actionsIconTheme: IconThemeData(
        color: isLightMode
            ? iconColors.appBarActionLightIconColor
            : iconColors.appBarActionDarkIconColor,
        size: 24.0,
      ),
    ),

    // PAGE TRANSITIONS

    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
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

    // RADIO BUTTON & CHECKBOX

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
              return fillColor.resolve(states)?.withAlpha(0x1F);
            }
            if (states.contains(MaterialState.focused)) {
              return focusColor;
            }
            if (states.contains(MaterialState.hovered)) {
              return hoverColor;
            }
            return Colors.transparent;
          },
        ),
      );
    }(),
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
              return fillColor.resolve(states)?.withAlpha(0x1F);
            }
            if (states.contains(MaterialState.focused)) {
              return focusColor;
            }
            if (states.contains(MaterialState.hovered)) {
              return hoverColor;
            }
            return Colors.transparent;
          },
        ),
      );
    }(),

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
      titleTextStyle: theme.titleLarge?.copyWith(color: primaryTextColor),
      contentTextStyle: theme.titleMedium?.copyWith(color: secondaryTextColor),
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
      labelColor: isDesktopPlatform ? primaryTextColor : colorScheme.primary,
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
      animationDuration,
      searchBarTheme,
      const MaterialStandard(2),
    },
  );
}

class MaterialRoute extends MaterialPageRoute {
  MaterialRoute({required WidgetBuilder builder}) : super(builder: builder);

  // A simple "hack" to access the animation duration from the [ThemeExtension] without using [BuildContext].
  static AnimationDuration? animationDuration;
  static const kDefaultTransitionDuration = Duration(milliseconds: 300);

  @override
  Duration get transitionDuration =>
      animationDuration?.medium ?? kDefaultTransitionDuration;
}

// Theme extensions:

// https://m3.material.io/components/search
// Not implemented in Flutter.
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

class AnimationDuration extends ThemeExtension<AnimationDuration> {
  final Duration fast;
  final Duration medium;
  final Duration slow;

  const AnimationDuration({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 300),
    this.slow = const Duration(milliseconds: 450),
  });

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
}

class IconColors extends ThemeExtension<IconColors> {
  final Color? lightIconColor;
  final Color? darkIconColor;
  final Color? appBarLightIconColor;
  final Color? appBarDarkIconColor;
  final Color? appBarActionLightIconColor;
  final Color? appBarActionDarkIconColor;

  const IconColors(
    this.lightIconColor,
    this.darkIconColor,
    this.appBarLightIconColor,
    this.appBarDarkIconColor,
    this.appBarActionLightIconColor,
    this.appBarActionDarkIconColor,
  );

  @override
  ThemeExtension<IconColors> copyWith({
    Color? lightIconColor,
    Color? darkIconColor,
    Color? appBarLightIconColor,
    Color? appBarDarkIconColor,
    Color? appBarActionLightIconColor,
    Color? appBarActionDarkIconColor,
  }) {
    return IconColors(
      lightIconColor ?? this.lightIconColor,
      darkIconColor ?? this.darkIconColor,
      appBarLightIconColor ?? this.appBarLightIconColor,
      appBarDarkIconColor ?? this.appBarDarkIconColor,
      appBarActionLightIconColor ?? this.appBarActionLightIconColor,
      appBarActionDarkIconColor ?? this.appBarActionDarkIconColor,
    );
  }

  @override
  ThemeExtension<IconColors> lerp(ThemeExtension<IconColors>? other, double t) {
    if (other is! IconColors) {
      return this;
    }
    return IconColors(
      Color.lerp(
        lightIconColor,
        other.lightIconColor,
        t,
      ),
      Color.lerp(
        darkIconColor,
        other.darkIconColor,
        t,
      ),
      Color.lerp(
        appBarLightIconColor,
        other.appBarLightIconColor,
        t,
      ),
      Color.lerp(
        appBarDarkIconColor,
        other.appBarDarkIconColor,
        t,
      ),
      Color.lerp(
        appBarActionLightIconColor,
        other.appBarActionLightIconColor,
        t,
      ),
      Color.lerp(
        appBarActionDarkIconColor,
        other.appBarActionDarkIconColor,
        t,
      ),
    );
  }
}
