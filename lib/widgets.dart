import 'package:flutter/material.dart';


class SubHeader extends StatelessWidget {
  final String text;
  SubHeader(this.text, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 48,
      margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}


List<Widget> tileGridListWidgets({@required double tileHeight, @required double tileWidth, @required String subHeader, @required BuildContext context, @required int widgetCount, @required Widget Function(BuildContext context, int index) builder, @required String leadingSubHeader, @required Widget leadingWidget, @required int elementsPerRow}) {
  List<Widget> widgets = new List<Widget>();
  widgets.addAll([
    SubHeader(leadingSubHeader),
    leadingWidget,
    SubHeader(subHeader),
  ]);
  int rowIndex = 0;
  List<Widget> rowChildren = new List<Widget>();
  for (int index = 0; index < widgetCount; index++) {
    rowChildren.add(
      builder(context, index),
    );
    rowIndex++;
    if (rowIndex > elementsPerRow - 1) {
      widgets.add(
        new Container(
          height: tileHeight + 8.0,
          margin: EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
      rowIndex = 0;
      rowChildren = List<Widget>();
    }
  }
  if (widgetCount % elementsPerRow != 0) {
    rowChildren = <Widget>[];
    for (int index = widgetCount - (widgetCount % elementsPerRow); index < widgetCount; index++) {
      rowChildren.add(
        builder(context, index),
      );
    }
    for (int index = 0; index < elementsPerRow - (widgetCount % elementsPerRow); index++) {
      rowChildren.add(
        Container(
          height: tileHeight,
          width: tileWidth,
        ),
      );
    }
    widgets.add(
      new Container(
        height: tileHeight + 8.0,
        margin: EdgeInsets.only(left: 8, right: 8),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      ),
    );
  }
  return widgets;
}


class FadeFutureBuilder extends StatefulWidget {
  final Future<Object> Function() future;
  final Widget Function(BuildContext context) initialWidgetBuilder;
  final Widget Function(BuildContext context, Object object) finalWidgetBuilder;
  final Widget Function(BuildContext context, Object object) errorWidgetBuilder;
  final Duration transitionDuration;
  FadeFutureBuilder({Key key, @required this.future, @required this.initialWidgetBuilder, @required this.finalWidgetBuilder, @required this.errorWidgetBuilder, @required this.transitionDuration}) : super(key: key);
  FadeFutureBuilderState createState() => FadeFutureBuilderState();
}


class FadeFutureBuilderState extends State<FadeFutureBuilder> with SingleTickerProviderStateMixin {
  bool _init = true;
  Widget _currentWidget = Container();
  AnimationController _widgetOpacityController;
  Animation<double> _widgetOpacity;
  Object _futureResolve;

  @override
  void initState() {
    super.initState();
    this._currentWidget = widget.initialWidgetBuilder(context);
  }

  @override
  void didChangeDependencies() async { 
    super.didChangeDependencies();
    if (this._init) {
      this._currentWidget = widget.initialWidgetBuilder(context);
      this._widgetOpacityController = new AnimationController(
        vsync: this,
        duration: widget.transitionDuration,
        reverseDuration: widget.transitionDuration,
      );
      this._widgetOpacity = new Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        new CurvedAnimation(
          parent: this._widgetOpacityController,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        )
      );
      try {
        this._futureResolve = await widget.future();
        this._widgetOpacityController.forward();
        Future.delayed(widget.transitionDuration, () {
          this.setState(() {
            this._currentWidget = widget.finalWidgetBuilder(context, this._futureResolve);
          });
          this._widgetOpacityController.reverse();
        });
      }
      catch(exception) {
        this._widgetOpacityController.forward();
        Future.delayed(widget.transitionDuration, () {
          this.setState(() {
            this._currentWidget = widget.errorWidgetBuilder(context, exception);
          });
          this._widgetOpacityController.reverse();
        });
      }
      this._init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FadeTransition(
        opacity: this._widgetOpacity,
        child: this._currentWidget,
      ),
    );
  }
}


class NetworkExceptionWidget extends StatelessWidget {
  final dynamic exception;
  final EdgeInsets margin;
  NetworkExceptionWidget({Key key, @required this.exception, @required this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          height: 128,
          margin: this.margin,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.signal_cellular_connected_no_internet_4_bar, 
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              Text(
                '$exception',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              )
            ],
          ),
        ),
      ),
    );
  }
}


class FakeLinearProgressIndicator extends StatelessWidget {
  final String label;
  final Duration duration;
  final double width;
  final EdgeInsets margin;
  FakeLinearProgressIndicator({Key key, @required this.label, @required this.duration, this.width, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: this.duration,
      child: Text(this.label),
      curve: Curves.linear,
      builder: (BuildContext context, double value, Widget child) => Center(
        child: Container(
          margin: this.margin ?? EdgeInsets.zero,
          alignment: Alignment.center,
          width: this.width ?? 148.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                this.label,
                style: Theme.of(context).textTheme.headline4,
              ),
              Divider(
                height: 12.0,
                color: Colors.transparent,
              ),
              LinearProgressIndicator(
                value: value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
