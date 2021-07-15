import 'package:flutter/material.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:http/http.dart' as http;

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:provider/provider.dart';

const String VERIFICATION_STRING = 'harmonoid';

enum ServerChangeState {
  initial,
  changing,
  done,
  invalidException,
  networkException,
}

extension ServerChangeStateExtension on ServerChangeState {
  Widget indicator({required BuildContext context}) {
    late Widget widget;
    switch (this) {
      case ServerChangeState.initial:
        {
          widget = Container();
        }
        break;
      case ServerChangeState.changing:
        {
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
                language!.STRING_SETTING_SERVER_CHANGE_CHANGING,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.0,
                ),
              )
            ],
          );
        }
        break;
      case ServerChangeState.done:
        {
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
                language!.STRING_SETTING_SERVER_CHANGE_DONE,
                style: TextStyle(
                  color: Colors.greenAccent[700],
                  fontSize: 12.0,
                ),
              )
            ],
          );
        }
        break;
      case ServerChangeState.invalidException:
        {
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
                language!.STRING_SETTING_SERVER_CHANGE_ERROR_INVALID,
                style: TextStyle(
                  color: Colors.redAccent[400],
                  fontSize: 12.0,
                ),
              )
            ],
          );
        }
        break;
      case ServerChangeState.networkException:
        {
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
                language!.STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK,
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

class ServerSetting extends StatefulWidget {
  ServerSetting({Key? key}) : super(key: key);

  @override
  ServerState createState() => ServerState();
}

class ServerState extends State<ServerSetting> {
  ServerChangeState _serverChangeState = ServerChangeState.initial;
  TextEditingController _textFieldController =
      new TextEditingController(text: configuration.homeAddress);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language!.STRING_SETTING_SERVER_CHANGE_TITLE,
      subtitle: language!.STRING_SETTING_SERVER_CHANGE_SUBTITLE,
      child: Container(
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
                      labelText:
                          language!.STRING_SETTING_SERVER_CHANGE_SERVER_LABEL,
                      hintText:
                          language!.STRING_SETTING_SERVER_CHANGE_SERVER_HINT,
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      hintStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
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
                      if (this._textFieldController.text == '') {
                        Provider.of<Server>(context, listen: false)
                            .update(homeAddress: '');
                        return;
                      } else {
                        this.setState(() {
                          this._serverChangeState = ServerChangeState.changing;
                        });
                        http
                            .get(Uri.https(this._textFieldController.text, ""))
                            .then((http.Response response) {
                          if (response.body == VERIFICATION_STRING) {
                            this._serverChangeState = ServerChangeState.done;
                            Provider.of<Server>(context, listen: false).update(
                                homeAddress: this._textFieldController.text);
                          } else {
                            this._serverChangeState =
                                ServerChangeState.invalidException;
                          }
                          this.setState(() {});
                        }).catchError((exception) {
                          this._serverChangeState =
                              ServerChangeState.networkException;
                          Provider.of<Server>(context, listen: false)
                              .update(homeAddress: configuration.homeAddress);
                          this.setState(() {});
                        });
                      }
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
      ),
      margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
    );
  }
}
