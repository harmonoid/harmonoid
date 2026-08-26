import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/routing/router.dart';

const double kDesktopHeaderHeight = 52.0;
const double kMobileHeaderHeight = 56.0;

const double kDesktopMargin = 16.0;
const double kMobileMargin = 8.0;

const double kDesktopLinearTileHeight = ListItemTableState.kDesktopRowHeight;
const double kMobileLinearTileHeight = ListItemTableState.kMobileRowHeight;

const double kMobileSearchBarHeight = 56.0;

const double kDesktopSliverTileSpacerHeight = 32.0;
const double kMobileSliverTileSpacerHeight = 16.0;

double get margin {
  if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.desktop) {
    return kDesktopMargin;
  } else if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.tablet) {
    throw UnimplementedError();
  } else if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.mobile) {
    return kMobileMargin;
  }
  throw UnimplementedError();
}

double get linearTileHeight {
  if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.desktop) {
    return kDesktopLinearTileHeight;
  } else if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.tablet) {
    throw UnimplementedError();
  } else if (Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.mobile) {
    return kMobileLinearTileHeight;
  }
  throw UnimplementedError();
}

double get captionHeight {
  try {
    return WindowPlus.instance.captionHeight;
  } catch (_) {
    return 0.0;
  }
}

double get navigationBarHeight => Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value == 3 ? 80.0 : kBottomNavigationBarHeight;
