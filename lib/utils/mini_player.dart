/// MIT License
///
/// Copyright (c) 2020 David Peters
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

// ignore_for_file: deprecated_member_use, constant_identifier_names, dangling_library_doc_comments

import 'dart:async';
import 'package:flutter/material.dart';

typedef MiniPlayerBuilder = Widget Function(double height, double percentage);
typedef DismissCallback = void Function(double percentage);

class MiniPlayer extends StatefulWidget {
  final double minHeight;
  final double maxHeight;
  final double elevation;
  final MiniPlayerBuilder builder;
  final Curve curve;
  final Duration duration;
  final ValueNotifier<double>? valueNotifier;
  final Function? onDismissed;
  final MiniPlayerController? controller;
  final bool tapToCollapse;

  const MiniPlayer({
    super.key,
    required this.minHeight,
    required this.maxHeight,
    required this.builder,
    this.curve = Curves.easeOut,
    this.elevation = 0,
    this.valueNotifier,
    this.duration = const Duration(milliseconds: 300),
    this.onDismissed,
    this.controller,
    this.tapToCollapse = true,
  });

  @override
  MiniPlayerState createState() => MiniPlayerState();
}

class MiniPlayerState extends State<MiniPlayer> with TickerProviderStateMixin {
  late ValueNotifier<double> heightNotifier;
  ValueNotifier<double> dragDownPercentage = ValueNotifier(0);
  Function? onDismissed;
  late double _dragHeight;
  late double _startHeight;
  bool dismissed = false;
  bool animating = false;
  int updateCount = 0;
  final StreamController<double> _heightController = StreamController<double>.broadcast();
  AnimationController? _animationController;

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) _resetAnimationController();
  }

  void _resetAnimationController({Duration? duration}) {
    if (_animationController != null) {
      _animationController!.dispose();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? widget.duration,
    );
    _animationController!.addStatusListener(_statusListener);
    animating = false;
  }

  @override
  void initState() {
    if (widget.valueNotifier == null) {
      heightNotifier = ValueNotifier(widget.minHeight);
    } else {
      heightNotifier = widget.valueNotifier!;
    }
    _resetAnimationController();
    _dragHeight = heightNotifier.value;
    if (widget.controller != null) {
      widget.controller!.addListener(controllerListener);
    }
    onDismissed = widget.onDismissed;
    super.initState();
  }

  @override
  void dispose() {
    _heightController.close();
    if (_animationController != null) {
      _animationController!.dispose();
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(controllerListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dismissed) {
      return Container();
    }
    return ValueListenableBuilder(
      valueListenable: heightNotifier,
      builder: (BuildContext context, double height, Widget? _) {
        final percentage = ((height - widget.minHeight)) / (widget.maxHeight - widget.minHeight);
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: height,
                child: GestureDetector(
                  child: ValueListenableBuilder(
                    valueListenable: dragDownPercentage,
                    builder: (BuildContext context, double value, Widget? child) {
                      return Opacity(
                        opacity: borderDouble(minRange: 0.0, maxRange: 1.0, value: 1 - value * 0.8),
                        child: Transform.translate(
                          offset: Offset(0.0, widget.minHeight * value * 0.5),
                          child: child,
                        ),
                      );
                    },
                    child: Material(
                      child: Container(
                        constraints: const BoxConstraints.expand(),
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[BoxShadow(color: Colors.black45, blurRadius: widget.elevation, offset: const Offset(0.0, 4))],
                          color: Theme.of(context).canvasColor,
                        ),
                        child: widget.builder(height, percentage),
                      ),
                    ),
                  ),
                  onTap: () => _dragHeight == widget.maxHeight && !widget.tapToCollapse ? null : _snapToPosition(_dragHeight != widget.maxHeight ? MiniPlayerPanelState.MAX : MiniPlayerPanelState.MIN),
                  onPanStart: (details) {
                    _startHeight = _dragHeight;
                    updateCount = 0;

                    if (animating) {
                      _resetAnimationController();
                    }
                  },
                  onPanEnd: (details) async {
                    double speed = (_dragHeight - _startHeight * _dragHeight < _startHeight ? 1 : -1) / updateCount * 100;
                    double snapPercentage = 0.005;
                    if (speed <= 4) {
                      snapPercentage = 0.2;
                    } else if (speed <= 9) {
                      snapPercentage = 0.08;
                    } else if (speed <= 50) {
                      snapPercentage = 0.01;
                    }
                    MiniPlayerPanelState snap = MiniPlayerPanelState.MIN;
                    final percentageMax = percentageFromValueInRange(min: widget.minHeight, max: widget.maxHeight, value: _dragHeight);

                    if (_startHeight > widget.minHeight) {
                      if (percentageMax > 1 - snapPercentage) {
                        snap = MiniPlayerPanelState.MAX;
                      }
                    } else {
                      if (percentageMax > snapPercentage) {
                        snap = MiniPlayerPanelState.MAX;
                      } else if (onDismissed != null &&
                          percentageFromValueInRange(
                                min: widget.minHeight,
                                max: 0,
                                value: _dragHeight,
                              ) >
                              snapPercentage) {
                        snap = MiniPlayerPanelState.DISMISS;
                      }
                    }
                    _snapToPosition(snap);
                  },
                  onPanUpdate: (details) {
                    if (dismissed) return;
                    _dragHeight -= details.delta.dy;
                    updateCount++;
                    _handleHeightChange();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleHeightChange({bool animation = false}) {
    if (_dragHeight >= widget.minHeight) {
      if (dragDownPercentage.value != 0) {
        dragDownPercentage.value = 0;
      }
      if (_dragHeight > widget.maxHeight) return;
      heightNotifier.value = _dragHeight;
    } else if (onDismissed != null) {
      final percentageDown = borderDouble(minRange: 0.0, maxRange: 1.0, value: percentageFromValueInRange(min: widget.minHeight, max: 0, value: _dragHeight));
      if (dragDownPercentage.value != percentageDown) {
        dragDownPercentage.value = percentageDown;
      }
      if (percentageDown >= 1 && animation && !dismissed) {
        if (onDismissed != null) {
          onDismissed!();
        }
        setState(() => dismissed = true);
      }
    }
  }

  void _snapToPosition(MiniPlayerPanelState snapPosition) {
    switch (snapPosition) {
      case MiniPlayerPanelState.MAX:
        _animateToHeight(widget.maxHeight);
        return;
      case MiniPlayerPanelState.MIN:
        _animateToHeight(widget.minHeight);
        return;
      case MiniPlayerPanelState.DISMISS:
        _animateToHeight(0);
        return;
    }
  }

  void _animateToHeight(final double h, {Duration? duration}) {
    if (_animationController == null) return;
    final startHeight = _dragHeight;
    if (duration != null) {
      _resetAnimationController(duration: duration);
    }
    Animation<double> sizeAnimation = Tween(
      begin: startHeight,
      end: h,
    ).animate(CurvedAnimation(parent: _animationController!, curve: widget.curve));
    sizeAnimation.addListener(() {
      if (sizeAnimation.value == startHeight) return;
      _dragHeight = sizeAnimation.value;
      _handleHeightChange(animation: true);
    });
    animating = true;
    _animationController!.forward(from: 0);
  }

  void controllerListener() {
    if (widget.controller == null) return;
    if (widget.controller!.value == null) return;

    switch (widget.controller!.value!.height) {
      case -1:
        _animateToHeight(
          widget.minHeight,
          duration: widget.controller!.value!.duration,
        );
        break;
      case -2:
        _animateToHeight(
          widget.maxHeight,
          duration: widget.controller!.value!.duration,
        );
        break;
      case -3:
        _animateToHeight(
          0,
          duration: widget.controller!.value!.duration,
        );
        break;
      default:
        _animateToHeight(
          widget.controller!.value!.height.toDouble(),
          duration: widget.controller!.value!.duration,
        );
        break;
    }
  }
}

enum MiniPlayerPanelState {
  MAX,
  MIN,
  DISMISS,
}

class ControllerData {
  final int height;
  final Duration? duration;

  const ControllerData(this.height, this.duration);
}

class MiniPlayerController extends ValueNotifier<ControllerData?> {
  MiniPlayerController() : super(null);

  void animateToHeight({
    double? height,
    MiniPlayerPanelState? state,
    Duration? duration,
  }) {
    ControllerData? data = value;
    if (state != null) {
      value = ControllerData(state.heightCode, duration);
    } else {
      if (height! < 0) return;
      value = ControllerData(height.round(), duration);
    }
    if (data == value) {
      notifyListeners();
    }
  }
}

extension SelectedColorExtension on MiniPlayerPanelState {
  int get heightCode {
    switch (this) {
      case MiniPlayerPanelState.MIN:
        return -1;
      case MiniPlayerPanelState.MAX:
        return -2;
      case MiniPlayerPanelState.DISMISS:
        return -3;
    }
  }
}

double percentageFromValueInRange({required double min, required double max, required double value}) {
  return (value - min) / (max - min);
}

double borderDouble({
  required double minRange,
  required double maxRange,
  required double value,
}) {
  if (value > maxRange) return maxRange;
  if (value < minRange) return minRange;
  return value;
}
