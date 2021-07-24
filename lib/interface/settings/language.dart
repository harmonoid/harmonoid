import 'package:flag/flag.dart';
import 'package:flutter/material.dart' hide ExpansionTile;
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:provider/provider.dart';

class LanguageSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final regions = LanguageRegion.values.toList()
      ..removeWhere((languageRegion) =>
          languageRegion ==
          Provider.of<Language>(context, listen: false).current)
      ..insert(0, Provider.of<Language>(context, listen: false).current);
    List<LanguageRegion> rgion = [];
    regions.forEach((element) {
      if (element != null) {
        rgion.add(element);
      }
    });
    return Consumer<Language>(
      builder: (context, language, _) => Card(
        margin: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 4.0,
          bottom: 4.0,
        ),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            tileShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            tilePadding: EdgeInsets.only(
              top: 8.0,
              left: 16.0,
              right: 16.0,
              bottom: 4.0,
            ),
            title: (context, animation) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.STRING_SETTING_LANGUAGE_TITLE,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        Divider(color: Colors.transparent, height: 4.0),
                        Text(
                          language.STRING_SETTING_LANGUAGE_SUBTITLE,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Divider(color: Colors.transparent, height: 8.0),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0.0,
                      end: 0.5,
                    ).animate(animation as Animation<double>),
                    child: Icon(Icons.expand_more),
                  ),
                ]),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
            ),
            fixedChild: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildLanguageRegionTile(language.current),
            ),
            children: [
              ImplicitlyAnimatedList<LanguageRegion>(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                areItemsTheSame: (a, b) => a == b,
                items: rgion,
                itemBuilder: (context, animation, region, index) {
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    curve: Curves.easeInOut,
                    animation: animation,
                    child: _buildLanguageRegionTile(region),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRegionTile(LanguageRegion? languageRegion, {Key? key}) {
    return Consumer<Language>(
      builder: (context, language, _) => RadioListTile<LanguageRegion?>(
        key: key,
        value: languageRegion,
        title: Text(languageRegion!.name),
        subtitle: Text(languageRegion.country),
        groupValue: configuration.languageRegion,
        onChanged: (languageRegion) async =>
            await language.set(languageRegion: languageRegion),
        secondary: Container(
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          child: SizedBox(
            height: 12,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Flag.fromString(languageRegion.countryCode,
                  fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

const Duration _kExpand = Duration(milliseconds: 200);

class ExpansionTile extends StatefulWidget {
  const ExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.fixedChild,
    this.trailing,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.tileShape,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
  })  : assert(
          expandedCrossAxisAlignment != CrossAxisAlignment.baseline,
          'CrossAxisAlignment.baseline is not supported since the expanded children '
          'are aligned in a column, not a row. Try to use another constant.',
        ),
        super(key: key);

  final Widget? leading;
  final Widget Function(BuildContext child, Animation? animation) title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Widget? fixedChild;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool maintainState;
  final EdgeInsetsGeometry? tilePadding;
  final ShapeBorder? tileShape;
  final Alignment? expandedAlignment;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final EdgeInsetsGeometry? childrenPadding;

  @override
  _ExpansionTileState createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<ExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController? _controller;
  late Animation<double> _heightFactor;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller!.drive(_easeInTween);
    _headerColor = _controller!.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller!.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller!.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller!.value = 1.0;
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller!.forward();
      } else {
        _controller!.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged!(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: (<Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              onTap: _handleTap,
              contentPadding: widget.tilePadding,
              leading: widget.leading,
              subtitle: widget.subtitle,
              shape: widget.tileShape,
              title: AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) => widget.title(context, _controller),
              ),
            ),
          ),
          if (widget.fixedChild != null && !_isExpanded) widget.fixedChild!,
          ClipRect(
            child: Align(
              alignment: widget.expandedAlignment ?? Alignment.center,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.subtitle1!.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColorTween.end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller!.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
        child: TickerMode(
          child: Padding(
            padding: widget.childrenPadding ?? EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: widget.expandedCrossAxisAlignment ??
                  CrossAxisAlignment.center,
              children: widget.children,
            ),
          ),
          enabled: !closed,
        ),
        offstage: closed);

    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }
}
