import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

class MobileMediaLibrarySortButtonPopupMenuItem<T> extends StatelessWidget {
  final T value;
  final bool checked;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets? padding;

  const MobileMediaLibrarySortButtonPopupMenuItem({
    super.key,
    required this.value,
    this.checked = false,
    required this.onTap,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: AnimatedOpacity(
        opacity: checked ? 1.0 : 0.0,
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: const Icon(Icons.done),
      ),
      title: child,
    );
  }
}
