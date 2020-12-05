import 'package:flutter/material.dart';


class SubHeader extends StatelessWidget {
  final String text;
  SubHeader(this.text, {Key key}) : super(key: key);
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 42,
      margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}