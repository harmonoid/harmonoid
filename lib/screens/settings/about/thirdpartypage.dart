import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:harmonoid/screens/settings/settings.dart';

class ThirdPartyPage extends StatelessWidget {
  const ThirdPartyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO(bdlukaa): add Icons.open_in_new to the trailing of these tiles
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          iconSize: Theme.of(context).iconTheme.size,
          splashRadius: Theme.of(context).iconTheme.size - 8,
          onPressed: Navigator.of(context).pop,
        ),
        title: Text('Third Party Credits'),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 16.0),
        children: [
          SettingsTile(
            title: 'Images',
            subtitle: 'Pictures & camera work credits. '
                'Thanks to following people for providing pleasant images.',
            child: Column(
              children: () {
                // To add a new credit, just add the info in 'credits' below
                final credits = [
                  {
                    'Oleg Ivanov': {
                      'asset': 'assets/images/credits-albums.jpg',
                      'launch': 'https://unsplash.com/photos/7x4ngEfelyE'
                    },
                  },
                  {
                    'Mink Mingle': {
                      'asset': 'assets/images/credits-tracks.jpg',
                      'launch': 'https://unsplash.com/photos/HRyjETL87Gg'
                    },
                  },
                  {
                    'Austin Neill': {
                      'asset': 'assets/images/credits-artists.jpg',
                      'launch': 'https://unsplash.com/photos/hgO1wFPXl3I'
                    },
                  },
                  {
                    'Sarah Kilian': {
                      'asset': 'assets/images/credits-exception.jpg',
                      'launch': 'https://unsplash.com/photos/52jRtc2S_VE'
                    },
                  },
                ];
                return List.generate(credits.length, (index) {
                  final credit = credits[index];
                  final name = credit.keys.first;
                  final value = credit[name];
                  return ListTile(
                    onTap: () => launcher.launch(value['launch']),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(value['asset']),
                    ),
                    trailing: Icon(Icons.open_in_new),
                    title: Text(name),
                  );
                });
              }(),
            ),
          ),
          SettingsTile(
            title: 'Album Arts',
            subtitle:
                'The album arts showed in various screenshots of the project belong to NoCopyrightSounds.',
            child: Column(children: [
              ListTile(
                onTap: () => launcher
                    .launch('https://www.youtube.com/watch?v=y07YAT1qdOQ'),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/CsLz1eLJ7qBu9Ad-wO8Nypz6RUAvATsW0MUTxZI2giSW1TnFs5S6HWtutXr50T14oNmTn5Ka1FcYsno=w60-h60-l90-rj'),
                ),
                title: Text('Sunburst'),
                subtitle: Text('Tobu'),
              ),
              ListTile(
                onTap: () => launcher
                    .launch('https://www.youtube.com/watch?v=BmrSzhw3rGE'),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/npz6DWheubb-oT57BWT9RGMFnq-dICZW-Y6fP9zsqr6hYZVdZ7lquE1jXcq-TDnWjOedNMiUFIuSttl7jQ=w60-h60-l90-rj'),
                ),
                title: Text('Hope'),
                subtitle: Text('Tobu'),
              ),
              ListTile(
                onTap: () => launcher
                    .launch('https://www.youtube.com/watch?v=Z1xRUgnT0-0'),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/2je-mCKeSSzqvtlvtBT3NjkZ8jSoVwnk-CCAsFYpZHz1TgkDk-6-cDNvyNz9miLHZWN2m88n0_nEf_Mu=w60-h60-l90-rj'),
                ),
                title: Text('Safe And Sound'),
                subtitle: Text('DEAF KEV'),
              ),
              ListTile(
                onTap: () => launcher
                    .launch('https://www.youtube.com/watch?v=m3YZ0l0l1Q8'),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/-5xRRnRbxiaPKOTOLI8Fb7JcNkh1aGMMRA6Do86bYgGXKG5AZvRTcXhSMlVaVKN5Wv6RrKrRaCl17TIa=w60-h60-l90-rj'),
                ),
                title: Text('NCS: Alpha'),
                subtitle: Text('Various Artists'),
              ),
            ]),
            actions: [
              MaterialButton(
                onPressed: () => launcher.launch(
                  'https://www.youtube.com/user/NoCopyrightSounds',
                ),
                child: Text(
                  'YOUTUBE',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
              MaterialButton(
                onPressed: () => launcher.launch('https://ncs.io/'),
                child: Text(
                  'NOCOPYRIGHTSOUNDS',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
            ],
          ),
          SettingsTile(
            title: 'Third Party Licenses',
            subtitle:
                'Open source libraries used. Following projects made this project possible.',
            child: Column(children: [
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/florent37/Flutter-AssetsAudioPlayer/blob/master/LICENSE'),
                title: Text('assets_audio_player'),
                subtitle: Text('florent37'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/alexmercerind/media_metadata_retriever/blob/master/LICENSE'),
                title: Text('media_metadata_retriever'),
                subtitle: Text('alexmercerind'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/florent37/Flutter-AssetsAudioPlayer/blob/master/LICENSE'),
                title: Text('assets_audio_player'),
                subtitle: Text('florent37'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/MaikuB/flutter_local_notifications/blob/master/LICENSE'),
                title: Text('flutter_local_notifications'),
                subtitle: Text('MaikuB'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/Baseflow/permission_handler/blob/master/LICENSE'),
                title: Text('permission_handler'),
                subtitle: Text('Baseflow'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/flutter/packages/blob/master/packages/animations/LICENSE'),
                title: Text('animations'),
                subtitle: Text('flutter'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/dart-lang/http/blob/master/LICENSE'),
                title: Text('http'),
                subtitle: Text('dart-lang'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/dart-lang/path/blob/master/LICENSE'),
                title: Text('path'),
                subtitle: Text('dart-lang'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/LICENSE'),
                title: Text('path_provider'),
                subtitle: Text('flutter'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/flutter/plugins/blob/master/packages/share/LICENSE'),
                title: Text('share'),
                subtitle: Text('flutter'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE'),
                title: Text('url_launcher'),
                subtitle: Text('flutter'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/flutter/packages/blob/master/LICENSE'),
                title: Text('palette_generator'),
                subtitle: Text('flutter'),
              ),
              ListTile(
                onTap: () => launcher.launch(
                    'https://github.com/bnxm/implicitly_animated_reorderable_list/blob/master/LICENSE'),
                title: Text('implicitly_animated_reorderable_list'),
                subtitle: Text('bnxm'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
