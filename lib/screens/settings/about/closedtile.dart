import 'package:flutter/material.dart';
import 'package:harmonoid/language/constants.dart';

class ClosedAboutTile extends StatelessWidget {
  const ClosedAboutTile({Key key, @required this.open}) : super(key: key);

  final Function open;

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 4.0),
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      elevation: 2.0,
      child: ListTile(
        title: Text(Constants.STRING_ABOUT_TITLE),
        subtitle: Text(Constants.STRING_ABOUT_SUBTITLE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        trailing: Icon(Icons.navigate_next),
        onTap: open,
      ),
    );
  }
}
