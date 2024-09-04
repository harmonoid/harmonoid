import 'package:flutter/material.dart';

import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class SettingsSpacer extends StatelessWidget {
  const SettingsSpacer({super.key});

  Widget _buildDesktopLayout(BuildContext context) => const SizedBox(height: kDesktopSettingsTileSpacerHeight);

  Widget _buildTabletLayout(BuildContext context) => throw UnimplementedError();

  Widget _buildMobileLayout(BuildContext context) => const SizedBox(height: kMobileSettingsTileSpacerHeight);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
