<h1 align="center"><a href="https://github.com/alexmercerind/harmonoid">Harmonoid</a></h1>
<h3 align="center">A music app with a beautiful UI to play all your music.</h3>

<p align="center"><a href='https://play.google.com/store/apps/details?id=com.alexmercerind.harmonoid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img height='80' alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a></p>

<h4 align="center">With love... <a href="https://github.com/alexmercerind">alexmercerind</a>, <a href="https://github.com/raitonoberu">raitonoberu</a>, <a href="https://github.com/mytja">mytja</a>, <a href="https://github.com/bdlukaa">bdlukaa</a> and contributors.</h4>

<h4  align="center">Loving the project? Consider starring the repository ⭐</h4>


<img src="https://github.com/alexmercerind/harmonoid/blob/assets/0.0.5.jpg?raw=true" />

## Animations

<table>
  <tr align="center">
    <td><img height="400" src="https://github.com/alexmercerind/harmonoid/blob/assets/collection.gif?raw=true" /></td>
    <td><img height="400" src="https://github.com/alexmercerind/harmonoid/blob/assets/now-playing.gif?raw=true" /></td>
  </tr>
</table>

## Contribute

As of now, the project contains **OVER 10K LINES OF CODE**.

Recently, it is migrated to use [Provider](https://github.com/rrousselGit/provider) for its state management. At few, places `StatefulWidget`s are still present.

The project supports sorting of music based on media metadata tags & native playback directly from file explorer etc. The whole user interface strictly follows the material design guidelines.

Checkout [project structure](https://github.com/alexmercerind/harmonoid#structure) to get started.

The plan of project is to bring the best, cross platform music experience for all users.


## Features

- **Powerful music collection generation**
  - Music automatically gets arranged into albums, artists & tracks.

- **Time synced lyrics**
  - Get time synced lyrics for all your saved music.
  - See lyrics of currently playing song directly in your notifications.
 
- **Play local music**
  - Play music saved on your device either from the collection in the app or using file browser.

- **Beautiful user interface**
  - Every element on screen beautifully animated & very strictly follows [material.io](https://material.io) guidelines. 

- **Ads free forever**
  - No advertisements! No profits associated with the project.
  
- **Playlists**
  - Make own playlists & play your favorite music on the go.
  
- **Freedom**
  - Share music from the app to other devices with a single tap.

- **Personalization**
  - Change accent color & theme of the app.

- **Download music**
  - A personal dedicated server is required for downloading music. [NOT INCLUDED IN APP]

## Workings

The majority of the logical & core code of this app is [here](https://github.com/alexmercerind/harmonoid/tree/master/lib/core) in the repository.

## Acknowledgements

Thanks to following people & organizations for their indirect contribution.

|Package                                                                              |Maintainer                                              |
|-------------------------------------------------------------------------------------|--------------------------------------------------------|
|[provider](https://github.com/rrousselGit/provider)                                  |[rrousselGit](https://github.com/rrousselGit)           |
|[assets_audio_player](https://github.com/florent37/Flutter-AssetsAudioPlayer)        |[florent37](https://github.com/florent37)               |
|[media_metadata_retriever](https://github.com/alexmercerind/media_metadata_retriever)|[alexmercerind](https://github.com/alexmercerind)       |
|[flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications) |[MaikuB](https://github.com/MaikuB)                     |
|[permission_handler](https://github.com/Baseflow/flutter-permission-handler)         |[Baseflow](https://github.com/Baseflow)                 |
|[animations](https://pub.dev/packages/animations)                                    |[flutter](https://github.com/flutter)                   |
|[http](https://pub.dev/packages/http)                                                |[flutter](https://github.com/flutter)                   |
|[path](https://pub.dev/packages/path)                                                |[flutter](https://github.com/flutter)                   |
|[path_provider](https://pub.dev/packages/path_provider)                              |[flutter](https://github.com/flutter)                   |
|[share](https://pub.dev/packages/share)                                              |[flutter](https://github.com/flutter)                   |
|[url_launcher](https://pub.dev/packages/url_launcher)                                |[flutter](https://github.com/flutter)                   |

## Structure

Glad you're interested in contributing to the project, here is the project structure for guiding you to this codebase.

Labels marked with `*` have scope for improvement in future.

```
harmonoid/lib
│
│   main.dart                     [Everyone knows this.]
│
├───core                          [Internal application logic.]
│       collection.dart           [For sorting, discovering, handling, updating, refreshing etc. of music.]
│       fileintent.dart           [For dealing with intents to open audio files.]
│       configuration.dart        [For saving application configuration.]* (Can be improved.)
│       discover.dart             [For interacting with server.]
│       download.dart             [For fetching content.]
│       mediatype.dart            [Various media structures used within application.]
│       playback.dart             [For playback using assets_audio_player or dart_vlc.]* (Yet to be done for desktop.)
│
├───interface                     [Application user interface.]
│   │
│   ├───collection                [Widgets & screens related to music collection.]
│   │
│   │───settings                  [Widgets & screens related to application settings.]
│   │
│   └───discover                  [Widgets & screens related to music discovery.]* (Yet to be migrated to Provider.)
│    
│       nowplaying.dart           [Now playing widgets & screen.]
│       harmonoid.dart            [Root Widget of application.]
│       home.dart                 [Child of Harmonoid widget, contains tabs for different screens.]
│       exception.dart            [A minimal MaterialApp to replace Harmonoid in case of any exception.]
│       changenotifiers.dart      [General ChangeNotifiers for state management.]
│
│───utils
│       methods.dart              [General utility methods used across the application.]
│       widgets.dart              [Various Widgets that bring application to life.]
│
└───constants                     [General globalization related classes.]* (Can be improved.)
        language.dart
        strings.dart
```

## License

GNU General Public License v3

## Translations

Thanks a lot for your contribution.

|Language       |Provider       |
|---------------|---------------|
|Russian        |@raitonoberu   |
|Slovenian      |@mytja         |
|Portuguese     |@bdlukaa       |
|Hindi          |@alexmercerind |
|German         |@MickLesk      |
|Dutch          |@kebabinjeneus |

You can see the app running in your own language by providing me translations.

For that purpose, you can add your changes to [this](https://github.com/alexmercerind/harmonoid/blob/master/lib/constants/language.dart) file on the repository.
You can translate this, even if you have little to no knowledge of Dart.
