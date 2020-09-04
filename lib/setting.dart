import 'dart:async';
import 'dart:convert' as convert;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:http/http.dart' as http;

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/globalspersistent.dart';

enum LanguageRegion {
  enUs,
  ruRu,
  slSi,
  ptBr,
  hiIn,
  deDe,
}

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key : key);
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {

  String _repository = 'harmonoid';
  String _developer = 'alexmercerind';

  String _repository1 = 'spotiyt-server';
  String _developer1 = 'raitonoberu';

  TextEditingController _serverInputController = new TextEditingController(text: Globals.STRING_HOME_URL);
  LanguageRegion _language;
  Widget _serverLabelWidget = Container(
    height: 18,
  );

  void _updateServerURL(String url) {
    this.setState(() {
      this._serverLabelWidget = Container(
        height: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                Globals.STRING_SETTING_SERVER_CHANGE_CHANGING,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ); 
    });
    http.get(Uri.https(url, '/', {}))
    .then((response) {
      this.setState(() {
        if (response.body == Globals.VERIFICATION_STRING) {
          Globals.STRING_HOME_URL = url;
          GlobalsPersistent.changeConfiguration('server', url);
          this._serverLabelWidget = Container(
            height: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 24,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    Globals.STRING_SETTING_SERVER_CHANGE_DONE,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        else {
          this._serverLabelWidget = Container(
            height: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 24,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    Globals.STRING_SETTING_SERVER_CHANGE_ERROR_INVALID,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      });
    })
    .catchError((error) => this.setState(() {
      print(error);
      this._serverLabelWidget = Container(
        height: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.close,
              color: Colors.red,
              size: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                Globals.STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }));
  }

  String _serverURL = Globals.STRING_HOME_URL;

  void _showRestartDialog() {
    Timer(Duration(milliseconds: 400), () => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Globals.STRING_SETTING_LANGUAGE_RESTART_DIALOG_TITLE),
        content: Text(Globals.STRING_SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE),
        actions: [
          MaterialButton(
            splashColor: Colors.deepPurple[50],
            highlightColor: Colors.deepPurple[100],
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              Globals.STRING_OK,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _projectInfo = Center(
    child: Container(
      margin: EdgeInsets.all(56),
      child: CircularProgressIndicator(),
    ),
  );
  Widget _projectInfo1 = Center(
    child: Container(
      margin: EdgeInsets.all(56),
      child: CircularProgressIndicator(),
    ),
  );
  List<Widget> _githubStargazers = [CircularProgressIndicator()];

  @override
  void initState() {
    super.initState();

    GlobalsPersistent.getConfiguration('language')
    .then((value) {
      this.setState(() {
        if (value == 'en_us') this._language = LanguageRegion.enUs;
        else if (value == 'ru_ru') this._language = LanguageRegion.ruRu;
        else if (value == 'sl_si') this._language = LanguageRegion.slSi; 
        else if (value == 'pt_br') this._language = LanguageRegion.ptBr; 
        else if (value == 'hi_in') this._language = LanguageRegion.hiIn; 
        else if (value == 'de_de') this._language = LanguageRegion.deDe; 
      });
    });

    Uri githubRepoUri = Uri.https('api.github.com', '/repos/${this._developer}/${this._repository}', {});
    Uri githubRepoUri1 = Uri.https('api.github.com', '/repos/${this._developer1}/${this._repository1}', {});
    Uri githubStargazersUri = Uri.https('api.github.com', '/repos/${this._developer}/${this._repository}/stargazers', {'per_page': '100'});
    http.get(githubRepoUri)
    .then((response) {
      Map<String, dynamic> githubRepo = convert.jsonDecode(response.body);
      this.setState(() {
        this._projectInfo = Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                indent: 32,
                endIndent: 32,
                height: 4,
                thickness: 1,
                color: Colors.black12,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(githubRepo['owner']['avatar_url']),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          githubRepo['name'],
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          githubRepo['owner']['login'],
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 8),
                child: Text(
                  githubRepo['license']['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
                child: Text(
                  'Copyright © ' + githubRepo['updated_at'].split('-')[0],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Chip(
                      avatar: CircleAvatar(
                        child: Icon(
                          Icons.star_border,
                          color: Colors.white,
                        ),
                        backgroundColor: Color(0x00000000),
                      ),
                      backgroundColor: Colors.black26,
                      label: Text(
                        githubRepo['stargazers_count'].toString() + ' stars'
                      ),
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Chip(
                    avatar: CircleAvatar(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                      ),
                      backgroundColor: Color(0x00000000),
                    ),
                    backgroundColor: Colors.black26,
                    label: Text(
                      githubRepo['forks_count'].toString() + ' forks'
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.white,
                height: 4,
                thickness: 0,
              ),
              Divider(
                indent: 32,
                endIndent: 32,
                color: Colors.black12,
                height: 1,
                thickness: 1,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MaterialButton(
                    splashColor: Colors.deepPurple[50],
                    highlightColor: Colors.deepPurple[100],
                    onPressed: () => url_launcher.launch(githubRepo['html_url']),
                    child: Text(
                      Globals.STRING_SETTING_STAR_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  MaterialButton(
                    splashColor: Colors.deepPurple[50],
                    highlightColor: Colors.deepPurple[100],
                    onPressed: () => url_launcher.launch(githubRepo['html_url'] + '/blob/master/README.md'),
                    child: Text(
                      Globals.STRING_SETTING_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ); 
      });
    })
    .catchError((error) {
      this.setState(() {
        this._projectInfo = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              indent: 32,
              endIndent: 32,
              height: 4,
              thickness: 1,
              color: Colors.black12,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 32,
              padding: EdgeInsets.only(top: 16, bottom: 4),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: CircleAvatar(
                      backgroundColor: Color(0x00000000),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this._repository,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        height: 4,
                        thickness: 0,
                      ),
                      Text(
                        this._developer,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 8),
              child: Text(
                'GNU General Public License v3.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
              child: Text(
                'Copyright © 2020',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                MaterialButton(
                  splashColor: Colors.deepPurple[50],
                  highlightColor: Colors.deepPurple[100],
                  onPressed: () => url_launcher.launch('https://github.com/alexmercerind/harmonoid'),
                  child: Text(
                    Globals.STRING_SETTING_STAR_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
                  splashColor: Colors.deepPurple[50],
                  highlightColor: Colors.deepPurple[100],
                  onPressed: () => url_launcher.launch('https://github.com/alexmercerind/harmonoid/blob/master/README.md'),
                  child: Text(
                    Globals.STRING_SETTING_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        );
      });
    });
    http.get(githubRepoUri1)
    .then((response) {
      Map<String, dynamic> githubRepo = convert.jsonDecode(response.body);
      this.setState(() {
        this._projectInfo1 = Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                indent: 32,
                endIndent: 32,
                height: 4,
                thickness: 1,
                color: Colors.black12,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(githubRepo['owner']['avatar_url']),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          githubRepo['name'],
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          githubRepo['owner']['login'],
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 8),
                child: Text(
                  githubRepo['license']['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
                child: Text(
                  'Copyright © ' + githubRepo['updated_at'].split('-')[0],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 2,),
                child: Text(
                  "Thanks a lot for your help. I'm really glad.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
                child: Text(
                  "Improvements made by you to the server are really great.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Chip(
                      avatar: CircleAvatar(
                        child: Icon(
                          Icons.star_border,
                          color: Colors.white,
                        ),
                        backgroundColor: Color(0x00000000),
                      ),
                      backgroundColor: Colors.black26,
                      label: Text(
                        githubRepo['stargazers_count'].toString() + ' stars'
                      ),
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Chip(
                    avatar: CircleAvatar(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                      ),
                      backgroundColor: Color(0x00000000),
                    ),
                    backgroundColor: Colors.black26,
                    label: Text(
                      githubRepo['forks_count'].toString() + ' forks'
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.white,
                height: 4,
                thickness: 0,
              ),
              Divider(
                indent: 32,
                endIndent: 32,
                color: Colors.black12,
                height: 1,
                thickness: 1,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MaterialButton(
                    splashColor: Colors.deepPurple[50],
                    highlightColor: Colors.deepPurple[100],
                    onPressed: () => url_launcher.launch(githubRepo['html_url']),
                    child: Text(
                      Globals.STRING_SETTING_STAR_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  MaterialButton(
                    splashColor: Colors.deepPurple[50],
                    highlightColor: Colors.deepPurple[100],
                    onPressed: () => url_launcher.launch(githubRepo['html_url'] + '/blob/master/README.md'),
                    child: Text(
                      Globals.STRING_SETTING_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ); 
      });
    })
    .catchError((error) {
      this.setState(() {
        this._projectInfo1 = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              indent: 32,
              endIndent: 32,
              height: 4,
              thickness: 1,
              color: Colors.black12,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 32,
              padding: EdgeInsets.only(top: 16, bottom: 4),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: CircleAvatar(
                      backgroundColor: Color(0x00000000),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this._repository,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        height: 4,
                        thickness: 0,
                      ),
                      Text(
                        this._developer,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 8),
              child: Text(
                'MIT License',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
              child: Text(
                'Copyright © 2020',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 2,),
              child: Text(
                "Thanks a lot for your help. I'm really glad.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 8,),
              child: Text(
                "Improvements made by you to the server are really great.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                MaterialButton(
                  splashColor: Colors.deepPurple[50],
                  highlightColor: Colors.deepPurple[100],
                  onPressed: () => url_launcher.launch('https://github.com/raitonoberu/harmonoid-service'),
                  child: Text(
                    Globals.STRING_SETTING_STAR_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
                  splashColor: Colors.deepPurple[50],
                  highlightColor: Colors.deepPurple[100],
                  onPressed: () => url_launcher.launch('https://github.com/raitonoberu/harmonoid-service/blob/master/README.md'),
                  child: Text(
                    Globals.STRING_SETTING_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        );
      });
    });
    http.get(githubStargazersUri)
    .then((response) {
      this.setState(() {
        List<dynamic> githubStargazers = convert.jsonDecode(response.body);
        this._githubStargazers.clear();
        for (Map<String, dynamic> stargazer in githubStargazers) {
          this._githubStargazers.add(
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(stargazer['avatar_url']),
              ),
              title: Text(stargazer['login']),
            )
          );
        } 
      });
    })
    .catchError((error) {
      this.setState(() {
        this._githubStargazers = [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              Globals.STRING_SETTING_STARGAZERS_INFORMATION_ERROR,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ];
      });
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Card(
            elevation: 1,
            margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_SERVER_CHANGE_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_SERVER_CHANGE_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: this._serverInputController,
                                  onSubmitted: (value) => this._updateServerURL(value),
                                  onChanged: (value) => this._serverURL = value,
                                  autocorrect: false,
                                  autofocus: false,
                                  cursorWidth: 1,
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                                    ),
                                    hintText: Globals.STRING_SETTING_SERVER_CHANGE_SERVER_HINT,
                                    hintStyle: TextStyle(
                                      color: Colors.black26,
                                    ),
                                    labelText: Globals.STRING_SETTING_SERVER_CHANGE_SERVER_LABEL,
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 56,
                                width: 56,
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () => this._updateServerURL(this._serverURL),
                                  icon: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  iconSize: 24,
                                  splashRadius: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                        this._serverLabelWidget,
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 1,
            margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_LANGUAGE_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_SETTING_LANGUAGE_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Color(0x00000000),
                          height: 16,
                          thickness: 0,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('English'),
                    subtitle: Text('United States'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'en_us');
                      this.setState(() {
                        this._language = LanguageRegion.enUs;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.enUs,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'en_us');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Русский'),
                    subtitle: Text('Россия'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'ru_ru');
                      this.setState(() {
                        this._language = LanguageRegion.ruRu;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.ruRu,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'ru_ru');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Slovenščina'),
                    subtitle: Text('Slovenia'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'sl_si');
                      this.setState(() {
                        this._language = LanguageRegion.slSi;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.slSi,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'sl_si');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Português'),
                    subtitle: Text('Brasil'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'pt_br');
                      this.setState(() {
                        this._language = LanguageRegion.ptBr;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.ptBr,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'pt_br');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('हिन्दी'),
                    subtitle: Text('भारत'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'hi_in');
                      this.setState(() {
                        this._language = LanguageRegion.hiIn;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.hiIn,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'hi_in');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Deutsche'),
                    subtitle: Text('Deutschland'),
                    onTap: () {
                      GlobalsPersistent.changeConfiguration('language', 'de_de');
                      this.setState(() {
                        this._language = LanguageRegion.deDe;
                      });
                      this._showRestartDialog();
                    },
                    leading: Radio(
                      value: LanguageRegion.deDe,
                      groupValue: this._language,
                      onChanged: (LanguageRegion language) {
                        GlobalsPersistent.changeConfiguration('language', 'de_de');
                        this.setState(() {
                          this._language = language;
                        });
                        this._showRestartDialog();
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                    height: 16,
                    thickness: 0,
                  ),
                ],
              ),
            ),
          ),
          OpenContainer(
            closedElevation: 0,
            closedColor: Color(0x00000000),
            openElevation: 0,
            openColor: Color(0x00000000),
            transitionDuration: Duration(milliseconds: 400),
            closedBuilder: (ctx, act) => Card(
              margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: ListTile(
                title: Text(Globals.STRING_ABOUT_TITLE),
                subtitle: Text(Globals.STRING_ABOUT_SUBTITLE),
              ),
            ),
            openBuilder: (ctx, act) => Scaffold(
              appBar: AppBar(
                leading: Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 24,
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ),
                title: Text(Globals.STRING_ABOUT_TITLE)
              ),
              body: ListView(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/about.jpg',
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                          ),
                          this._projectInfo,
                        ],
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://github.com/raitonoberu/harmonoid-service/blob/master/downloaded_track.PNG?raw=true',
                            fit: BoxFit.fitWidth,
                            height: 128,
                            width: MediaQuery.of(context).size.width - 32,
                            alignment: Alignment.topCenter,
                          ),
                          this._projectInfo1,
                        ],
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  color: Color(0x00000000),
                                  height: 16,
                                  thickness: 0,
                                ),
                                Text(
                                  Globals.STRING_SETTING_LANGUAGE_PROVIDERS_TITLE,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                                Divider(
                                  color: Color(0x00000000),
                                  height: 4,
                                  thickness: 0,
                                ),
                                Text(
                                  Globals.STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                Divider(
                                  color: Color(0x00000000),
                                  height: 16,
                                  thickness: 0,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: Text('raitonoberu'),
                            subtitle: Text('Русский'),
                            onTap: () => url_launcher.launch('https://github.com/raitonoberu'),
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.black26,
                              ),
                              backgroundColor: Color(0x00000000),
                            )
                          ),
                          ListTile(
                            title: Text('mytja'),
                            subtitle: Text('Slovenščina'),
                            onTap: () => url_launcher.launch('https://github.com/mytja'),
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.black26,
                              ),
                              backgroundColor: Color(0x00000000),
                            ),
                            trailing: CircleAvatar(
                              child: Icon(
                                Icons.star_border,
                                color: Colors.yellow,
                              ),
                              backgroundColor: Color(0x00000000),
                            ),
                          ),
                          ListTile(
                            title: Text('bdlukaa'),
                            subtitle: Text('Português'),
                            onTap: () => url_launcher.launch('https://github.com/bdlukaa'),
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.black26,
                              ),
                              backgroundColor: Color(0x00000000),
                            )
                          ),
                          ListTile(
                            title: Text('alexmercerind'),
                            subtitle: Text('हिन्दी'),
                            onTap: () => url_launcher.launch('https://github.com/alexmercerind'),
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.black26,
                              ),
                              backgroundColor: Color(0x00000000),
                            )
                          ),
                          ListTile(
                            title: Text('mytja'),
                            subtitle: Text('Deutsche'),
                            onTap: () => url_launcher.launch('https://github.com/mytja'),
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.black26,
                              ),
                              backgroundColor: Color(0x00000000),
                            ),
                            trailing: CircleAvatar(
                              child: Icon(
                                Icons.star_border,
                                color: Colors.yellow,
                              ),
                              backgroundColor: Color(0x00000000),
                            ),
                          ),
                          Divider(
                            color: Colors.white,
                            height: 16,
                            thickness: 0,
                          ),
                        ]
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  color: Color(0x00000000),
                                  height: 16,
                                  thickness: 0,
                                ),
                                Text(
                                  Globals.STRING_SETTING_STARGAZERS_TITLE,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                                Divider(
                                  color: Color(0x00000000),
                                  height: 4,
                                  thickness: 0,
                                ),
                                Text(
                                  Globals.STRING_SETTING_STARGAZERS_SUBTITLE,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                Divider(
                                  color: Color(0x00000000),
                                  height: 16,
                                  thickness: 0,
                                ),
                              ],
                            ),
                          )
                        ] + this._githubStargazers.reversed.toList() + [
                          Divider(
                            color: Colors.white,
                            height: 16,
                            thickness: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
