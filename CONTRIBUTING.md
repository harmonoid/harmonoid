## Contribute

[Provider](https://github.com/rrousselGit/provider) is used for state management.

Checkout project structure below to get started.

The plan of project is to bring the best, cross platform music experience for all users.

Fork the project today & add your features. We are actively looking for contributors. If you decide to contribute, add yourself to the about page of the app.

## Project

Glad you're interested in contributing to the project, here is the project structure for guiding you to this codebase.

Labels marked with `*` have scope for improvement in future.

```
│   main.dart                     [Everyone knows this.]
│
├───core                          [Internal application logic.]
│       collection.dart           [For sorting, discovering, handling, updating, refreshing etc. of music.]
│       fileintent.dart           [For dealing with intents to open audio files.]
│       configuration.dart        [For saving application configuration.]*
│       discover.dart             [For interacting with server.]
│       download.dart             [For fetching content.]
│       mediatype.dart            [Various media structures used within application.]
│       playback.dart             [For playback using assets_audio_player or dart_vlc.]*
│
├───interface                     [Application user interface.]
│   │
│   ├───collection                [Widgets & screens related to music collection.]
│   │
│   │───settings                  [Widgets & screens related to application settings.]
|
│   ├───discover                  [Widgets & screens related to music discovery.]
│   │
│   │   nowplaying.dart           [Now playing widgets & screen.]
│   │   harmonoid.dart            [Root Widget of application.]
│   │   home.dart                 [Child of Harmonoid widget, contains tabs for different screens.]
│   │   exception.dart            [A minimal MaterialApp to replace Harmonoid in case of any exception.]
│   │   changenotifiers.dart      [General ChangeNotifiers for state management.]
│
│───utils
│       methods.dart              [General utility methods used across the application.]
│       widgets.dart              [Various Widgets that bring application to life.]
│
└───constants                     [General globalization related classes.]*
        language.dart
        strings.dart
```
