# [Harmonoid](https://github.com/alexmercerind/harmonoid/)

#### The music app, that can download music from spotify for free & has no advertisements!

The app is meant to be used in such a way, that you download your favorite music offline & listen it whenever without internet connection.

###### :arrow_down: Android users can download pre-compiled APK here: [Download](https://github.com/alexmercerind/harmonoid/releases/download/v0.0.2/harmonoid-v0.0.2-pre-release.apk) (Changelog: [v0.0.2-pre-release](https://github.com/alexmercerind/harmonoid/releases/tag/v0.0.2))
###### NOTE: You might see a dialog "Your phone and personal data are more vulnerable to attack by unknown apps." when installing this app. But let me tell you that, this app is safe as you are seeing the code in this repository & secondly the app will not ask for any of your device permissions at all (not even storage). So, you are safe. Still, it is your choice.


## :camera: The Fluid Experience

|Browse Offline|Download Music|Listen Offline|
|-|-|-|
|![browse_offline](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/browse_offline.jpg)|![download_music](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/download_music.jpg)|![search_modes](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/now_playing_demo.jpg)|

#### More Motion

These GIFs are only 25 FPS :worried:. Please wait for the GIFs to load, if they appear choppy to you.

|||
|-|-|
|![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/album_demo.gif) |![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/ui_demo.gif)|


## :warning: THIS IS JUST A PRE-RELEASE

THE CURRENT PRE-RELEASE OF APP IS JUST TO HAVE BASIC FEATURES, LIKE FREE MUSIC DOWNLOAD, OFFLINE PLAYBACK & USER INTERFACE. YOU CAN LOOK AT TEMPORARILY INCLUDED [CURRENTLY ADDED](#zap-currently-added) SECTION OF README, FOR THE SENSE OF PROGRESS. MANY FEATURES, THAT AN IDEAL MUSIC APP HAS, ARE STILL MISSING. YOU CAN CONTRIBUTE, IF YOU WANT TO. THE UI SHOULD BE SMOOTH BUT, YOU CAN ENCOUNTER DOWNLOAD RELATED BUGS RARELY AT THE MOMENT & I'M TRYING TO FIX THEM. **PLEASE** :star: STAR THE REPOSITORY TO SUPPORT THE PROJECT. IF YOU FEEL CONFUSED WHEN USING THE APP, THEN YOU CAN TAKE HELP FROM THE [FAQ](#grey_question-FAQ).

You can open issues if you get confused in the UI of app & request features too!


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
- Accent Colors 
- Dark Mode


## :information_source: Features Planned & Current Bugs

| :honeybee: Bugs                                                                         | :zap: Features Upcoming                                                                  |
|-----------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
|~~Refresh button is to be pressed for refreshing downloaded music.~~                     |Exporting tracks outside the app for sharing.                                              |
|Artist search result page does not work at the moment.                                   |Searching downloaded tracks & albums.                                                          |
|The track search result page uses same widgets as album result page                      |Determinate loading bar for downloading tracks in notification area.                              |
|~~Downloaded tracks do not play sometimes.~~                                             |Better management for downloaded albums & tracks, which includes sorting them acc. to date added, A to Z etc.  (It is very basic at the moment)|
|~~Recent searches don't show under "Your recent searches"~~                              |Lyrics for downloaded tracks                                                                    |
|~~Improve download speed~~                                                               |                                                                                                  |


## :book: Inner Workings

This app is uses Python 3 in its back-end. You can see the repository powering this app [here](https://github.com/raitonoberu/spotiyt-server).


## :white_check_mark: Help With Translations

You can help me by providing translations for the app in your language & see the app running in your native language.

For that purpose, you can checkout [this](https://github.com/alexmercerind/harmonoid/blob/master/lib/scripts/globalsupdater.dart) file on the repository, you can translate this, even if you have little to no knowledge of Dart.

##### Translation Credits

|Language       |Provider       |
|---------------|---------------|
|Russian        |@raitonoberu   |
|Slovenian      |@mytja         |
|Portuguese     |@bdlukaa       |
|Hindi          |@alexmercerind |
|German         |@MickLesk      |

Thankyou!


## :arrow_down: Dependencies

|Package                                                        |Maintainer                               |
|---------------------------------------------------------------|-----------------------------------------|
|[animations](https://pub.dev/packages/animations)              |[flutter](https://github.com/flutter)    |
|[http](https://pub.dev/packages/http)                          |[flutter](https://github.com/flutter)    |
|[path](https://pub.dev/packages/path)                          |[flutter](https://github.com/flutter)    |
|[path_provider](https://pub.dev/packages/path_provider)        |[flutter](https://github.com/flutter)    |
|[just_audio](https://github.com/ryanheise/audio_service)       |[ryanheise](https://github.com/ryanheise)|
|[audio_service](https://github.com/ryanheise/audio_service)    |[ryanheise](https://github.com/ryanheise)|
|[url_launcher](https://pub.dev/packages/url_launcher)          |[flutter](https://github.com/flutter)    |


## :grey_question: FAQ

_For pre-release v0.0.1_

- __How do I download music?__
  - Go to the 'Collection' tab, and tap on the search bar. Then, enter a keyword to search & select the mode (i.e Album or Track) in which you want to search. You'll be greeted with the music close to your keyword in a moment. Tap on your preferred result, it's album will show up to you. Now, tap on the tracks you want to save offline.

- __How do I play my saved music?__
  - Go to the 'Collection' tab (or the starting screen of the app), and tap (or should I say, spin) the refresh button to see your latest music. Now, play whatever you want.
  
- __How do I control media playback?__
  - 'Now Playing' tab of the app is for this job. You can do the basic job from the app notification itself.

- __How do I delete a saved track?__
  - In your 'Collection' tab, open the album to which that track belongs. Long press that track (which you want to delete) and tap 'YES' for deleting confirmation.

- __How do I delete a saved album?__
  - In your 'Collection' tab, open the album that you wanna delete. Press the bin button in the top right corner.
  
- __Why is the first search on app generally slower & delayed ?__
  - This is because of the fact that our backend goes to sleep, if no users are online. So it takes time for it, to warm up again on your first request.
  
- __My favorite music is incorrectly downloaded. What is wrong with it?__
  - Open issue, providing the name of album & track.
  
- __I'm seeing the error 'We all have bad days' when downloading my music. What is wrong?__
  - This will most likely happen when something is wrong on our side (like dependencies of server are not up to date or our server's IP got blocked with 429 responses due to high amount of requests etc.). You can open issue, if you see this over a long period of time, generally I'll fix this quickly.


## :closed_book: Starting Development

This application is powered by Flutter, which uses Dart as its programming language.

The only reason to choose Flutter for this app was because, it seemed promising & has great pre-defined widgets and styles. It was a great moment for me to learn it, as it is growing (becoming popular) at a very fast rate. 

Assuming that you have already installed [Flutter](https://flutter.dev) SDK on your device.

You can start the app in following way:

- **Clone the repository and enter it**
  - ```git clone https://github.com/alexmercerind/harmonoid.git && cd harmonoid```
- **Get the dependencies**
  - ```flutter packages get```
- **Run the application on your device**
  - ```flutter run```
  - This will run the application in the debug mode. To get the optimal performance, use any of the additional paramters ```--release``` or ```--profile```.

**For building a performant APK, you can write following in your terminal:**

Don't forget to setup your keystore.

```
flutter build apk
```

You can use additional parameter ```--split-per-abi``` to reduce APK size by building separate APKs for each architecture.
