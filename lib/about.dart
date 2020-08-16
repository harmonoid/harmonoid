import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:http/http.dart' as http;

import 'package:harmonoid/globals.dart';


class About extends StatefulWidget {
  About({Key key}) : super(key : key);
  AboutState createState() => AboutState();
}

class AboutState extends State<About> {

  Widget _projectInfo = Center(
    child: Container(
      margin: EdgeInsets.all(56),
      child: CircularProgressIndicator(),
    ),
  );
  List<Widget> _githubStargazers = [CircularProgressIndicator()];

  @override
  void initState() {
    super.initState();

    Uri githubRepoUri = Uri.https('api.github.com', '/repos/alexmercerind/harmonoid', {});
    Uri githubStargazersUri = Uri.https('api.github.com', '/repos/alexmercerind/harmonoid/stargazers', {});
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
                          color: Colors.white,
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
                  'Copyright © ' + githubRepo['updated_at'].split('-')[0] + ' ' +  githubRepo['owner']['login'],
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
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                child: Text(
                  githubRepo['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
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
                      Globals.STRING_ABOUT_STAR_GITHUB,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  MaterialButton(
                    splashColor: Colors.deepPurple[50],
                    highlightColor: Colors.deepPurple[100],
                    onPressed: () => url_launcher.launch(githubRepo['html_url'] + '/blob/master/README.md'),
                    child: Text(
                      Globals.STRING_ABOUT_GITHUB,
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
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                Globals.STRING_ABOUT_REPOSITORY_INFORMATION_ERROR,
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
                    Globals.STRING_ABOUT_STAR_GITHUB,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                MaterialButton(
                  splashColor: Colors.deepPurple[50],
                  highlightColor: Colors.deepPurple[100],
                  onPressed: () => url_launcher.launch('https://github.com/alexmercerind/harmonoid/blob/master/README.md'),
                  child: Text(
                    Globals.STRING_ABOUT_GITHUB,
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
              Globals.STRING_ABOUT_STARGAZERS_INFORMATION_ERROR,
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
            clipBehavior: Clip.antiAlias,
            elevation: 2,
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
            elevation: 2,
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
                          color: Colors.white,
                          height: 16,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_ABOUT_STARGAZERS_TITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                          height: 4,
                          thickness: 0,
                        ),
                        Text(
                          Globals.STRING_ABOUT_STARGAZERS_SUBTITLE,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Divider(
                          color: Colors.white,
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