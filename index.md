The app is meant to be used in such a way, that you download your favorite music offline & listen it whenever without internet connection.

##### Please consider ⭐ starring the repository, if you are enjoying the app. You can join [Gitter](https://gitter.im/harmonoid/community) for feedback.


## 💎 The Experience You Always Wanted

|Browse Offline|Listen Offline|
|-|-|
|![browse_offline](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/browse_offline.jpg?raw=true)|![search_modes](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/now_playing_demo.jpg?raw=true)|

#### UI In Motion

These GIFs are only 25 FPS 😅. Please wait for the GIFs to load, if they appear choppy to you.

|||
|-|-|
|![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/album_demo.gif?raw=true) |![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/ui_demo.gif?raw=true)|

## ✅ Features

 Beautiful looking, yet full of unique features.

- 💾 __Free Music Download__
  - You download the music of your choice for free and listen offline.

- ✨ __Stunning User Interface__
  - The app has every element on screen beautifully animated, & very strictly follows [material.io](https://material.io) guidelines. 

- 💝 __Ads Free Forever__
  - No advertisements!
  
- 💌 __Safe To Use__
  - The app does not ask for any of your device permissions at all. (Not even storage).


## 👌 Currently Added

- 🔎 Album & track search.
- 💾 Track downloads for offline playback. (Generally a track will take under ~~30~~ **10** seconds to be downloaded. ~~20~~ **5** seconds, if you have good connection.)
- ⏯ Saving track & album metadata offline.
- 📱 Background play & media notification.
- 📃 Adding whole album to playlist, when playing a track from it.
- ❎ Deleting downloaded tracks.
- ⚡ Simultaneously downloading tracks of an album.
- 🔖 Playlist Support (Very basic at the moment, will improve in future.)
- 🎉 Now Playing (Will improve in future.) &  About Screens
- 🌈 Accent Colors 
- 😎 Dark Mode

## 🎉 Help With Translations

You can help me by providing translations for the app in your language & see the app running in your native language.

For that purpose, you can checkout [this](https://github.com/alexmercerind/harmonoid/blob/master/lib/scripts/globalsupdater.dart) file on the repository, you can translate this, even if you have little to no knowledge of Dart.

## ❔ FAQ

_For pre-release v0.0.2+2_

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
