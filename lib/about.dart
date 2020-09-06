import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:harmonoid/globals.dart' as Globals;


class AboutScreen extends StatefulWidget {
  AboutScreen({Key key}) : super(key : key);
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {

  String _repository = 'harmonoid';
  String _developer = 'alexmercerind';

  String _repository1 = 'spotiyt-server';
  String _developer1 = 'raitonoberu';
  List<Widget> _githubStargazers = [CircularProgressIndicator()];

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

  @override
  void initState() {
    super.initState();
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
                    onPressed: () => url_launcher.launch(githubRepo['html_url']),
                    child: Text(
                      Globals.STRING_SETTING_STAR_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  MaterialButton(
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
                  onPressed: () => url_launcher.launch('https://github.com/alexmercerind/harmonoid'),
                  child: Text(
                    Globals.STRING_SETTING_STAR_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
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
                    onPressed: () => url_launcher.launch(githubRepo['html_url']),
                    child: Text(
                      Globals.STRING_SETTING_STAR_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  MaterialButton(
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
                        this._repository1,
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
                        this._developer1,
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
                  onPressed: () => url_launcher.launch('https://github.com/raitonoberu/harmonoid-service'),
                  child: Text(
                    Globals.STRING_SETTING_STAR_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}