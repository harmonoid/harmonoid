# [Harmonoid](https://github.com/alexmercerind/harmonoid/)

### A 🎵 music app that has beautiful UI, can download music for free & has no ads.

[![Discord](https://img.shields.io/discord/774213213113810944?color=%23738ADB&label=Discord&logo=Discord&style=for-the-badge)](https://discord.gg/mRxH9zYkGy)

✒ Hello Everyone! As of November 6, 2020, I as the maintainer & main developer of project, has decided to rewrite this project & start from scratch, because current version of app has few issues in its core & code is less managable. Newer version of app (i.e. v3.0.0) will be a completely new app, with a lot more new features & control over your music. The project is alive & you can see the progress in the [development](https://github.com/alexmercerind/harmonoid/tree/development) branch of this repository. You can join Discord server of Harmonoid with above button, to get an early look at upcoming features and provide feedback or you may just talk to us about anything you want & chill. Thanks a lot for your love 💙!

#### From [alexmercerind](https://github.com/alexmercerind) & [contributors](https://github.com/alexmercerind/harmonoid/graphs/contributors)

## 🎵 Experience

|Browse Offline|Download Music|Listen Offline|
|-|-|-|
|![browse_offline](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/browse_offline.jpg)|![download_music](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/download_music.jpg)|![search_modes](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/now_playing_demo.jpg)|

The app is meant to be used in such a way, that you download your favorite music offline & listen it whenever without internet connection.

## 📂 Download

##### 💾 Android users can download pre-compiled APK here: [Download](https://github.com/alexmercerind/harmonoid/releases/download/v0.0.2%2B2/harmonoid-v0.0.2+2-pre-release.apk) (Changelog: [v0.0.2+2-pre-release](https://github.com/alexmercerind/harmonoid/releases/tag/v0.0.2%2B2))
###### NOTE: You might see a dialog "Your phone and personal data are more vulnerable to attack by unknown apps." when installing this app. But let me tell you that, this app is safe as app will not ask for any of your device permissions at all (not even storage) & you are seeing the code in this repository. Still, it is your choice.

## ⛷ Motion

These GIFs are only 25 FPS 😣. Please wait for the GIFs to load, if they appear choppy to you.

|||
|-|-|
|![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/album_demo.gif) |![](https://github.com/alexmercerind/harmonoid/blob/master/README%20Assets/ui_demo.gif)|

## ✅ Features

 Beautiful looking, yet full of unique features.

- 💾 __Free Music Download__
  - You download the music of your choice for free and listen offline.

- ✨ __Stunning User Interface__
  - The app has every element on screen beautifully animated, & very strictly follows [material.io](https://material.io) guidelines. 

- 💝 __Ads Free Forever__
  - No advertisements! This app is powered completely by YOUR LOVE.
  
- 🔒 __Safe To Use__
  - The app does not ask for any of your device permissions at all. (Not even storage).

## 👌 Progress

- 🔍 Album & track search.
- 💾 Track downloads for offline playback. (generally a track will take under ~~30~~ **10** seconds to be downloaded. ~~20~~ **5** seconds, if you have good connection.)
- 🧷 Saving track & album metadata offline.
- ⏯ Background play & media notification.
- 📃 Adding whole album to playlist, when playing a track from it.
- ❎ Deleting downloaded tracks.
- 📁 Simultaneously downloading tracks of an album.
- 📃 Playlist Support (very basic at the moment, will improve in future).
- 🎵 Now Playing (will improve in future) &  About Screens
- 🌈 Accent Colors 
- 😎 Dark Mode

## 🎉 Contributions

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

## 📖 Working

The code that this app uses for the majority of work like saving, deleting, playing music & managing history etc. is [here](https://github.com/alexmercerind/harmonoid/tree/master/lib/scripts) in the repository.

Apart from above, the app uses Python 3 based back-end for serving to the user requests. You can see it [here in this repository](https://github.com/raitonoberu/harmonoid-service). It is managed by [@raitonoberu](https://github.com/raitonoberu) & me.

## ❔ FAQ

For pre-release v0.0.3

- __How do I download music?__
  - Go to the 'Collection' tab, and tap on the search bar. Then, enter a keyword to search & select the mode (i.e Album, Artist or Track) in which you want to search. You'll be greeted with the music close to your keyword in a moment. Tap on your preferred result, it's album will show up to you. Now, tap on the tracks you want to save offline.

- __How do I play my saved music?__
  - Go to the 'Collection' tab (or the starting screen of the app), and tap (or should I say, spin) the refresh button to see your latest music. Now, play whatever you want.
  
- __How do I control media playback?__
  - 'Now Playing' tab of the app is for this job. You can do the basic job from the app notification itself.

- __How do I delete a saved track?__
  - In your 'Collection' tab, open the album to which that track belongs. Long press that track (which you want to delete) and tap 'YES' for deleting confirmation.

- __How do I delete a saved album?__
  - In your 'Collection' tab, open the album that you wanna delete. Press the bin button in the top right corner.
  
- __Why is the first search on app generally slower & delayed?__
  - This is because of the fact that our backend goes to sleep, if no users are online. So it takes time for it, to warm up again on your first request.
  
- __My favorite music is incorrectly downloaded. What is wrong with it?__
  - Open issue, providing the name of album & track.
  
- __I'm seeing the error 'We all have bad days' when downloading my music. What is wrong?__
  - This will most likely happen when something is wrong on our side (like dependencies of server are not up to date or our server's IP got blocked with 429 responses due to high amount of requests etc). You can open issue, if you see this over a long period of time, generally I'll fix this quickly.
