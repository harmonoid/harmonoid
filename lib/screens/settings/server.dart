import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/scripts/configuration.dart';


const String VERIFICATION_STRING = 'harmonoid';

enum ServerChangeState {
  initial,
  changing,
  done,
  invalidException,
  networkException,
}


extension ServerChangeStateExtension on ServerChangeState {
  Widget indicator({@required BuildContext context}) {
    Widget widget;
    switch(this) {
      case ServerChangeState.initial: {
        widget = Container();
      }
      break;
      case ServerChangeState.changing: {
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.info,
                color: Theme.of(context).primaryColor,
                size: 24.0,
              ),
            ),
            Text(
              Constants.STRING_SETTING_SERVER_CHANGE_CHANGING,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12.0,
              ),
            )
          ],
        );
      }
      break;
      case ServerChangeState.done: {
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.check,
                color: Colors.greenAccent[700],
                size: 24.0,
              ),
            ),
            Text(
              Constants.STRING_SETTING_SERVER_CHANGE_DONE,
              style: TextStyle(
                color: Colors.greenAccent[700],
                fontSize: 12.0,
              ),
            )
          ],
        );
      }
      break;
      case ServerChangeState.invalidException: {
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.close,
                color: Colors.redAccent[400],
                size: 24.0,
              ),
            ),
            Text(
              Constants.STRING_SETTING_SERVER_CHANGE_ERROR_INVALID,
              style: TextStyle(
                color: Colors.redAccent[400],
                fontSize: 12.0,
              ),
            )
          ],
        );
      }
      break;
      case ServerChangeState.networkException: {
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.close,
                color: Colors.redAccent[400],
                size: 24.0,
              ),
            ),
            Text(
              Constants.STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK,
              style: TextStyle(
                color: Colors.redAccent[400],
                fontSize: 12.0,
              ),
            )
          ],
        );
      }
      break;
    }
    return widget;
  }
}


class Server extends StatefulWidget {
  Server({Key key}) : super(key: key);

  @override
  ServerState createState() => ServerState();
}


class ServerState extends State<Server> {
  ServerChangeState _serverChangeState = ServerChangeState.initial;
  TextEditingController _textFieldController = new TextEditingController(text: configuration.homeAddress);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: this._textFieldController,
                    cursorWidth: 1.0,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                      ),
                      labelText: Constants.STRING_SETTING_SERVER_CHANGE_SERVER_LABEL,
                      hintText: Constants.STRING_SETTING_SERVER_CHANGE_SERVER_HINT,
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.0),
                    child: IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                    splashRadius: 24.0,
                    onPressed: () {
                      this.setState(() {
                        this._serverChangeState = ServerChangeState.changing;
                      });
                      http.get(Uri.https(this._textFieldController.text, ''))
                      .then((http.Response response) {
                        if (response.body == VERIFICATION_STRING) {
                          this._serverChangeState = ServerChangeState.done;
                          configuration.save(
                            homeAddress: this._textFieldController.text,
                          );
                        }
                        else {
                          this._serverChangeState = ServerChangeState.invalidException;
                        }
                        this.setState(() {});
                      })
                      .catchError((exception) {
                        this._serverChangeState = ServerChangeState.networkException;
                        this.setState(() {});
                      });
                    },
                  ),
                ),
              ],
            ),
            Divider(
              height: 8.0,
              color: Colors.transparent,
            ),
            _serverChangeState.indicator(context: context),
          ],
       ),
    );
  }
}
