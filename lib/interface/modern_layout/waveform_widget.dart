import 'dart:math';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/configuration.dart';

class WaveformComponent extends StatefulWidget {
  const WaveformComponent(
      {Key? key,
      required this.duration,
      required this.color,
      required this.curve,
      required this.boxMaxHeight,
      required this.boxMaxWidth,
      this.width,
      this.height,
      this.waveDataList})
      : super(key: key);

  final int duration;
  final Color color;
  final Curve curve;
  final double boxMaxHeight;
  final double boxMaxWidth;
  final double? width;
  final double? height;
  final List<double>? waveDataList;

  @override
  _WaveformComponentState createState() => _WaveformComponentState();
}

class _WaveformComponentState extends State<WaveformComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late double width;
  late double height;
  late List<double> waveDataList;

  @override
  void initState() {
    super.initState();
    width = widget.width ?? 4;
    height = widget.height ?? 15;
    animate();
    Random random = Random();
    waveDataList = [];
    waveDataList = List.generate(widget.boxMaxWidth ~/ (6.5),
        (index) => 5.0 + random.nextDouble() * (widget.boxMaxHeight - 10.0));
  }

  void animate() {
    controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    animation = Tween<double>(begin: 2, end: height).animate(
      CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ),
    );
    controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.boxMaxWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          widget.boxMaxWidth ~/ (6.5),
          (index) => SizedBox(
            width: width,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) => AnimatedContainer(
                  margin: EdgeInsets.only(right: 1.5),
                  duration: const Duration(milliseconds: 300),
                  height: waveDataList[index].toDouble(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        5 * Configuration.instance.borderRadiusMultiplier),
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.reset();
    controller.dispose();
    super.dispose();
  }
}

class WaveformSlider extends StatefulWidget {
  final double barWidth;
  final double gapWidth;
  final Color activeColor;
  final Color inactiveColor;

  WaveformSlider({
    this.barWidth = 5,
    this.gapWidth = 2,
    this.activeColor = Colors.deepPurple,
    this.inactiveColor = Colors.blueGrey,
  });

  @override
  _WaveformSliderState createState() => _WaveformSliderState();
}

class _WaveformSliderState extends State<WaveformSlider> {
  double bar2Position = 180.0;
  List<int> bars = [];

  void randomNumberGenerator() {
    Random r = Random();
    double numberOfBars =
        (MediaQuery.of(context).size.width - widget.gapWidth) /
            (widget.barWidth + widget.gapWidth);
    for (var i = 0; i < numberOfBars; i++) {
      bars.add(r.nextInt(40) + 10);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => randomNumberGenerator());
  }

  _onTapDown(TapDownDetails details) {
    var x = details.globalPosition.dx;
    print("tap down " + x.toString());
    setState(() {
      bar2Position = x;
    });
  }

  @override
  Widget build(BuildContext context) {
    int barItem = 0;
    return GestureDetector(
      onTapDown: (TapDownDetails details) => _onTapDown(details),
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          bar2Position = details.globalPosition.dx;
        });
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: bars.map((int height) {
            Color color = barItem + 1 < bar2Position / widget.barWidth
                ? widget.activeColor
                : widget.inactiveColor;
            barItem++;
            return Container(
              color: color,
              height: height.toDouble(),
              width: widget.barWidth,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// List<double> generateRandomValues(int count, double min, double max) {
//   Random random = Random();
//   return List.generate(count, (_) => min + random.nextDouble() * (max - min));
// }

// class AudioWaveform extends StatefulWidget {
//   final Uri uri;
//   final int duration;
//   final BuildContext context;
//   const AudioWaveform({super.key, required this.uri, this.duration = 5, required this.context});

//   @override
//   State<AudioWaveform> createState() => _AudioWaveformState();
// }

// class _AudioWaveformState extends State<AudioWaveform> {
//   final _waveformData = ValueNotifier<List<double>>([]);

//   @override
//   void initState() {
//     super.initState();
//     _waveformData.value = generateRandomValues(widget.duration, 0.0, 0.2);
//   }

//   List<double> generateRandomValues(int count, double min, double max) {
//     Random random = Random();
//     return List.generate(count, (_) => min + random.nextDouble() * (max - min));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Playback>(
//       builder: (context, playback, _) {
//         // Update the value of _waveformData when the duration changes
//         if (playback.duration.inSeconds != _waveformData.value.length) {
//           _waveformData.value = generateRandomValues(playback.duration.inSeconds, 0.0, 0.2);
//         }

//         return AudioFileWaveforms(
//           size: Size(MediaQuery.of(context).size.width, 50.0),
//           playerController: PlayerController(),
//           enableSeekGesture: true,
//           waveformType: WaveformType.fitWidth,
//           waveformData: _waveformData.value,
//           playerWaveStyle: const PlayerWaveStyle(
//             fixedWaveColor: Colors.white54,
//             liveWaveColor: Colors.blueAccent,
//             spacing: 6,
//           ),
//         );
//       },
//     );
//   }
// }


  // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: List<Widget>.generate(
    //     values.length,
    //     (index) => AnimatedContainer(
    //       duration: const Duration(milliseconds: 300),
    //       width: 2.5,
    //       height: values[index] * 200,
    //       child: AnimatedOpacity(
    //         opacity: 1.0,
    //         duration: const Duration(milliseconds: 300),
    //         child: Align(
    //           alignment: Alignment.center,
    //           child: Container(
    //             height: values[index] * 200,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(15 * Configuration.instance.borderRadiusMultiplier),
    //               color: Color.alphaBlend(Theme.of(context).colorScheme.onBackground.withAlpha(160), NowPlayingColorPalette.instance.modernColor),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );