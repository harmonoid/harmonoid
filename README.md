# [Harmonoid](https://github.com/alexmercerind/harmonoid/)

#### The music app, that can download music from spotify for free & has no advertisements!

The app is meant to be used in such a way, that you download your favorite music offline & listen it whenever without internet connection.

## :warning: THIS IS JUST A PRE-RELEASE

THE CURRENT PRE-RELEASE OF APP IS JUST TO HAVE BASIC FEATURES, LIKE FREE MUSIC DOWNLOAD, OFFLINE PLAYBACK & USER INTERFACE. YOU CAN LOOK AT TEMPORARILY INCLUDED [CURRENTLY ADDED](#zap-currently-added) SECTION OF README, FOR THE SENSE OF PROGRESS. MANY FEATURES, THAT AN IDEAL MUSIC APP HAS, ARE STILL MISSING. YOU CAN CONTRIBUTE, IF YOU WANT TO. THE UI SHOULD BE SMOOTH BUT, YOU CAN ENCOUNTER DOWNLOAD RELATED BUGS RARELY AT THE MOMENT & I'M TRYING TO FIX THEM. **PLEASE** :star: STAR THE REPOSITORY TO SUPPORT THE PROJECT. YOU CAN OPEN ISSUES, IF YOU FEEL CONFUSED WHEN USING THE APP.


## :camera: The Fluid Experience

These GIFs are only 25 FPS :worried:. Please wait for the GIFs to load, if they appear choppy to you.

|||
|-|-|
|![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/album_demo.gif) |![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/ui_demo.gif)|

#### More Screenshots

|Browse Offline|Download Music|Listen Offline|
|-|-|-|
|![browse_offline](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/browse_offline.jpg)|![download_music](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/download_music.jpg)|![search_modes](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/now_playing_demo.jpg)|


## :heavy_check_mark: Features


 Beautiful looking, yet full of unique features.

- :arrow_down: __Free Music Download__
  - You download the music of your choice for free and listen offline.

- :sparkler: __Stunning User Interface__
  - The app has every element on screen beautifully animated, & very strictly follows [material.io](https://material.io) guidelines. 

- :heart: __Ads Free Forever__
  - No advertisements! Please star :star: the repository, project needs YOUR SUPPORT to grow.
  
- :shield: __Safe To Use__
  - The app does not ask for any of your device permissions at all. (Not even storage).


## :zap: Currently Added

- Album & track search.
- Track downloads for offline playback. (Generally a track will take under ~~30~~ **10** seconds to be downloaded. ~~20~~ **5** seconds, if you have good connection.)
- Saving track & album metadata offline.
- Background play & media notification.
- Adding whole album to playlist, when playing a track from it.
- Deleting downloaded tracks.
- Simultaneously downloading tracks of an album.
- Playlist Support (Very basic at the moment, will improve in future.)
- Now Playing (Will improve in future.) &  About Screens


## :information_source: Features Planned & Current Bugs

| :honeybee: Bugs                                                                         | :zap: Features Upcoming                                                                  |
|-----------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
|Refresh button is to be pressed for refreshing downloaded music.                         |Exporting tracks outside the app for sharing.                                              |
|Artist search result page does not work at the moment.                                   |Searching downloaded tracks & albums.                                                          |
|The track search result page uses same widgets as album result page                      |Determinate loading bar for downloading tracks in notification area.                              |
|~~Downloaded tracks do not play sometimes.~~                                             |Better management for downloaded albums & tracks, which includes sorting them acc. to date added, A to Z etc.  (It is very basic at the moment)|
|~~Recent searches don't show under "Your recent searches"~~                              |Lyrics for downloaded tracks                                                                    |
|~~Improve download speed~~                                                               |                                                                                                  |


## :white_check_mark: Help With Translations

You can help me by providing translations for the app in your language & see the app running in your native language.

For that purpose, you can checkout [this](https://github.com/alexmercerind/harmonoid/blob/master/lib/globals.dart) file on the repository, you can translate this, even if you have little to no knowledge of Dart.

Thankyou!


## :page_facing_up: LICENSE


```
MIT License

Copyright (c) 2020 Hitesh Kumar Saini

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


## :arrow_down: Dependencies

|Package                                                        |Maintainer                               |
|---------------------------------------------------------------|-----------------------------------------|
|[animations](https://pub.dev/packages/animations)              |[flutter](https://github.com/flutter)    |
|[http](https://pub.dev/packages/http)                          |[flutter](https://github.com/flutter)    |
|[path](https://pub.dev/packages/path)                          |[flutter](https://github.com/flutter)    |
|[path_provider](https://pub.dev/packages/path_provider)        |[flutter](https://github.com/flutter)    |
|[palette_generator](https://pub.dev/packages/palette_generator)|[flutter](https://github.com/flutter)    |
|[just_audio](https://github.com/ryanheise/audio_service)       |[ryanheise](https://github.com/ryanheise)|
|[audio_service](https://github.com/ryanheise/audio_service)    |[ryanheise](https://github.com/ryanheise)|
|[url_launcher](https://pub.dev/packages/url_launcher)          |[flutter](https://github.com/flutter)    |
