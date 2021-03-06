import 'package:flutter/material.dart';
import 'dart:async';


List<Widget> tileGridListWidgets({
  @required double tileHeight,
  @required double tileWidth,
  @required String subHeader,
  @required BuildContext context,
  @required int widgetCount,
  @required Widget Function(BuildContext context, int index) builder,
  @required String leadingSubHeader,
  @required Widget leadingWidget,
  @required int elementsPerRow,
}) {
  List<Widget> widgets = <Widget>[];
  widgets.addAll([
    SubHeader(leadingSubHeader),
    leadingWidget,
    SubHeader(subHeader),
  ]);
  int rowIndex = 0;
  List<Widget> rowChildren = <Widget>[];
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
      rowChildren = <Widget>[];
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


class SubHeader extends StatelessWidget {
  final String text;

  const SubHeader(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 48,
      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}


class FadeFutureBuilder extends StatefulWidget {
  final Future<Object> Function() future;
  final Widget Function(BuildContext context) initialWidgetBuilder;
  final Widget Function(BuildContext context, Object object) finalWidgetBuilder;
  final Widget Function(BuildContext context, Object object) errorWidgetBuilder;
  final Duration transitionDuration;

  const FadeFutureBuilder({
    Key key,
    @required this.future,
    @required this.initialWidgetBuilder,
    @required this.finalWidgetBuilder,
    @required this.errorWidgetBuilder,
    @required this.transitionDuration,
  }) : super(key: key);
  FadeFutureBuilderState createState() => FadeFutureBuilderState();
}


class FadeFutureBuilderState extends State<FadeFutureBuilder>
    with SingleTickerProviderStateMixin {
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
      ).animate(new CurvedAnimation(
        parent: this._widgetOpacityController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ));
      try {
        this._futureResolve = await widget.future();
        this._widgetOpacityController.forward();
        Future.delayed(widget.transitionDuration, () {
          this.setState(() {
            this._currentWidget =
                widget.finalWidgetBuilder(context, this._futureResolve);
          });
          this._widgetOpacityController.reverse();
        });
      } catch (exception) {
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


class ExceptionWidget extends StatelessWidget {
  final EdgeInsets margin;
  final double height;
  final Icon icon;
  final String title;
  final String subtitle;
  final String assetImage;

  const ExceptionWidget({
    Key key,
    this.assetImage,
    this.icon,
    @required this.margin,
    @required this.height,
    @required this.title,
    @required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2.0,
        clipBehavior: Clip.antiAlias,
        margin: this.margin,
        child: Container(
          width: MediaQuery.of(context).size.width - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (this.assetImage != null)
                Image.asset(
                  this.assetImage,
                  height: this.height,
                  width: this.height,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                )
              else
                Container(
                  height: this.height,
                  width: this.height,
                  alignment: Alignment.center,
                  color: Theme.of(context).dividerColor,
                  child: Icon(
                    Icons.library_music,
                    size: 56.0,
                  ),
                ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                width: MediaQuery.of(context).size.width - 32 - this.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      this.title,
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 4.0,
                    ),
                    Text(
                      this.subtitle,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}


class FakeLinearProgressIndicator extends StatelessWidget {
  final String label;
  final Duration duration;
  final double width;
  final EdgeInsets margin;

  FakeLinearProgressIndicator({
    Key key,
    @required this.label,
    @required this.duration,
    this.width,
    this.margin,
  }) : super(key: key);

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
              LinearProgressIndicator(value: value),
            ],
          ),
        ),
      ),
    );
  }
}


class ClosedTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const ClosedTile({Key key, @required this.open, @required this.title, @required this.subtitle}) : super(key: key);

  final Function open;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 4.0,
        bottom: 4.0,
      ),
      color: Theme.of(context).cardColor,
      elevation: 2.0,
      child: ListTile(
        title: Text(this.title),
        subtitle: Text(this.subtitle),
        onTap: open,
      ),
    );
  }
}
