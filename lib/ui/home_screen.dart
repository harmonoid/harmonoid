import 'package:flutter/material.dart';

import 'package:harmonoid/utils/rendering.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  Widget _buildDesktopLayout(BuildContext context) {
    return child;
  }

  Widget _buildTabletLayout(BuildContext context) {
    return child;
  }

  Widget _buildMobileLayout(BuildContext context) {
    return child;
  }

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
