import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

class SlideOnEnter extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  const SlideOnEnter({super.key, required this.child, this.duration, this.curve});

  @override
  State<SlideOnEnter> createState() => SlideOnEnterState();
}

class SlideOnEnterState extends State<SlideOnEnter> {
  Offset offset = const Offset(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState(() => offset = Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration ?? Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero;
    final curve = widget.curve ?? Curves.easeInOut;
    return AnimatedSlide(
      offset: offset,
      duration: duration,
      curve: curve,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                setState(() => offset = const Offset(0.0, 1.0));
                await Navigator.of(context).maybePop();
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
