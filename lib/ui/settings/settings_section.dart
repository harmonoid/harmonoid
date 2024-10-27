import 'package:flutter/material.dart';

import 'package:harmonoid/ui/settings/settings_spacer.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    required this.subtitle,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 64.0),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 64.0),
  });

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SizedBox(
        width: kDesktopCenteredLayoutWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: headerPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
            const SettingsSpacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeader(title),
        const SizedBox(height: 2.0),
        ...children,
        const Divider(height: 1.0),
        const SettingsSpacer(),
      ],
    );
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
