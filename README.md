# [Harmonoid](https://github.com/harmonoid/harmonoid)

**🎵 Elegant music app to play & manage music library. Lyrics & playlists. YouTube Music support.**

_Still a work-in-progress (Windows & Linux is available)._

- [Download](#download)
- [Discord](https://discord.gg/2Rc3edFWd8)
- [Features](#features)
- [Limitations](#limitations)
- [Guide](#guide)
- [Acknowledgements](#acknowledgements)
- [Compiling](#compiling)
- [License](#license)
- [Third-Party Credits](#third-party-credits)

![](https://github.com/harmonoid/harmonoid/blob/assets/151304862-f4d336c6-4559-477b-b82e-a876f78f5eec.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304870-6d1d18db-7120-43bd-87fa-9fa369244bfd.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304875-dc120964-3b98-4460-beaf-d28c75b45109.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304879-cdb10677-30c5-45bb-9e67-f520297280da.webp?raw=true)

## Motion

![](https://user-images.githubusercontent.com/28951144/151239401-be199319-0a22-4139-8bef-fe1edac2d576.gif)

## Download

See [limitations](#limitations) aswell.

### Windows

Supports Windows 7 or later.

- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe">Setup</a>
- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-exe.zip">Portable</a>
- winget install harmonoid

On Windows, [setup](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe) is recommended as it automatically links with files & file explorer context menus.

### Linux

Any modern Linux distribution.

- [.deb](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.deb)
- [.rpm](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.rpm)
- [.tar.gz](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.tar.gz)

On Debian or Ubuntu based distros, you need to install `mpv` & `libmpv-dev` to be able to install & run the app.

```bash
sudo apt install mpv libmpv-dev
sudo dpkg -i harmonoid-linux-x86_64.deb
```

Similar instructions can be followed on your favorite distro.

### Android

- Coming soon (again).

## Features

### Current features

- Powerful music library management based on metadata tags. Indexes music into group of albums & artists.
- Capable of indexing 20 files/second (on Windows) & saves cache for future app start-ups.
- Cross-platform (currently aiming Windows, Linux & Android).
- mpv based music playback for strong format support (on Linux & Windows) using `dart:ffi`.
- Taskbar & System Media Transport Controls for Windows.
- Small installer (< 25 MB) & low RAM usage (< 120 MB) (tested on Windows, still see [limitations](#limitations)).
- Lyrics for all your music.
- Very strictly follows [Material Design](https://material.io/) guidelines for UI & animations.
- Ability to create persistent or "Now playing" playlists.
- Context menu integrations & file associations (exclusive to setup version).
- Discord RPC integration.
- Portable (if you wish).
- Does not use [electron.js](https://www.electronjs.org/).
- D-Bus MPRIS controls for Linux.

### Upcoming features

- Mini-window mode.
- Minimization to system tray.
- Music visualizations.
- Tag editor.
- Time-synced lyrics.
- Importing playlists from YouTube & Spotify using Web API.
- Equalizer.
- Improvising YouTube support to be close to official web-client.
- Last.fm scrobbling.
- Plugin API.
- Windows 11 `IExplorerCommand` integration.
- Publishing to Microsoft Store & other places.
- Support for remaining macOS & iOS platforms.
- YOU Tell 😄

**NOTE:** Project is NEVER going to offer feature for downloading music from YouTube.

## Limitations

[hopefully these will be resolved over time]

A lot of time has went into making this project possible using [Flutter](https://github.com/flutter/flutter) & nearly everything has been written from ground-up (from low-level C/C++ plugins to UI & business-logic in Flutter/Dart).

[Flutter](https://github.com/flutter/flutter) is quite new at the time for desktop & every new (even basic) functionality in the app is a research itself.

Nothing at the time is very stable & every new feature is a new discovery. Just have fun, learn & share your knowledge!

Few issues regarding memory usage alone can be:

- https://github.com/flutter/flutter/issues/73402
- https://github.com/flutter/flutter/issues/90547
- https://github.com/flutter/flutter/issues/92318
- https://github.com/flutter/flutter/issues/95092

In most cases as of now (Windows & Linux), memory usage will be really low at fresh start of the application & will continue to rise (although slowly) overtime with no specific reason.

## Guide

### 1. Keyboard shortcuts

- <kbd>Space</kbd>: Play or pause.
- <kbd>Alt</kbd> + <kbd>N</kbd>: Next song.
- <kbd>Alt</kbd> + <kbd>B</kbd>: Previous song.
- <kbd>Alt</kbd> + <kbd>M</kbd>: mute or un-mute.
- <kbd>Alt</kbd> + <kbd>V</kbd>: Volume increase.
- <kbd>Alt</kbd> + <kbd>C</kbd>: Volume decrease.
- <kbd>Alt</kbd> + <kbd>X</kbd>: Seek forwards.
- <kbd>Alt</kbd> + <kbd>Z</kbd>: Seek backwards.

### 2. Indexing your music

To show your local music inside Harmonoid, you can go to the settings & click "ADD NEW FOLDER". This will show a new window, where you can select a folder where all your music is stored. After selecting the folder, your music collection inside the application will start building.

Your music will be categorized into albums, artists etc. & you'll be able to freely browse music album-wise or artist-wise etc. while being able to sort it alphabetically or year-wise etc.

As of now, you can still browse/play your music while it is being indexed.

Next time when you start the app, your music collection will be retrieved from the cache.

To remove a folder from your music collection, just click on "REMOVE" next to the folder you might wanna remove in the settings page.

### 3. Managing playback queue

By default, the app will attempt to play the song that you click on, while adding songs after it to the queue. To add more songs to the queue, simply right click on the new song & click "Add to now playing".

You can also configure to automatically play other songs from your collection when the queue is finished.

### 4. Creating a playlist

To create a new playlist, you need to go the the "PLAYLISTS" tab & click "CREATE NEW PLAYLIST". This will ask you a name for your new shiny playlist. After its creation, you can click on your favorite song to add it to the required playlist. This can help you greatly organize your music collection.

You can add both local music & music from YouTube Music to these playlists.

### 5. Playing songs from YouTube Music

Currently, YouTube Music support is very basic but it works _well_ in terms of performance & timing. Right now, you can:

- Play.
- Play from URL.
- Search.
- Get recommendations.
- Get suggestions.
- Add to playlist.

We intend to improve in future & you can contribute to this. Downloading is never going to be a feature inside the application.

### 6. Viewing a YouTube Music song on website

If you're playing a song from YouTube Music & want to hear it on website instead, you can simply go to the "Now Playing Screen" by an arrow in the bottom-right corner of the application. Hovering over the album art, you'll see an icon hinting to open the song in your web-browser. Click on it & you're on YouTube Music website.

### 7. Playing a YouTube URL

Just enter the YouTube or YouTube Music URL in the search field & hit enter. It'll start playing immediately.

### 8. Playing from File Explorer

You can play music directly from file explorer if you installed Harmonoid using the setup installer or from Microsoft Store.

You can also right click a folder to "Add to Harmonoid's Playlist".

### 9. Troubleshoot

If you encounter some problem like you're unable to start the app or see an error screen, you can try to delete the `.Harmonoid` folder in your home directory.
WARNING: This will also delete your music indexing cache & playlists. Best decision can be to report us at our Discord.

### 10. Hacking

If you wish to really configure properties of the app which are not available in the UI yet, you may edit the `.JSON` files in `~/.Harmonoid` directory.

## Acknowledgements

An incomplete list of people who are working (or worked) on the project in past:

### Developers

<ul>
  <li>
    <img src='https://avatars.githubusercontent.com/u/28951144?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/alexmercerind'>Hitesh Kumar Saini</a></strong>
    <ul>
      <li>Lead developer. Deals with playback & indexing of media. Writes UI, state management & lifecycle code. Manages native plugins.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/946652?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://www.github.com/YehudaKremer'>Yehuda Kremer</a></strong>
    <ul>
      <li>UI & animation improvements. Application persistence & other important features. MSIX package for the store publishing.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/64320078?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/raitonoberu'>Denis</a></strong>
    <ul>
      <li>Windows installer & major bug fixes. Russian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/52399966?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/mytja'>Mitja Ševerkar</a></strong>
    <ul>
      <li>WinGet package. Backward Windows compatiblity checks. Improvements to YouTube Music support. Bug reports. CI. Slovenian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/41370460?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/prateekmedia'>Prateek Sunal</a></strong>
    <ul>
      <li>RPM package. Bug reports. Hindi translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/45696119?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/bdlukaa'>Bruno D'Luka</a></strong>
    <ul>
      <li>User interface & design. Portuguese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/43904633?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/gaetan1903'>Gaetan Jonathan BAKARY</a></strong>
    <ul>
      <li>Linux related bug-fixes. French translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/31634638?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/arafatamim'>Tamim Arafat</a></strong>
    <ul>
      <li>User interface & design. Bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/75587960?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/LeonHoog'>Leon</a></strong>
    <ul>
      <li>User interface fixes, app persistence improvements. Dutch translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/75587960?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/LeonHoog'>Leon</a></strong>
    <ul>
      <li>User interface fixes, app persistence improvements. Dutch translation.</li>
    </ul>
  </li>
</ul>

### Artists

<ul>
  <li>
    <img src='https://drive.google.com/uc?id=1eI-dHiALVQM123_HnQIcYe9HtbX0uS_W' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://www.instagram.com/shinybluebelll'>Bluebell</a></strong>
    <ul>
      <li>Artwork & iconography used in the application.</li>
    </ul>
  </li>
</ul>

### Testers

<ul>
  <li>
    <img src='https://avatars.githubusercontent.com/u/23397550?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/Sombian'>Sombian</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/88533953?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/SleepDaemon'>SleepDaemon</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/8049534?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/ilopX'>ilopX</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/56985621?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/7HAVEN'>Ankit Rana</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
</ul>

### Translators

<ul>
  <li>
    <img src='https://avatars.githubusercontent.com/u/12989935?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/RedyAu'>Fodor Benedek</a></strong>
    <ul>
      <li>Hungarian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/10137?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='mailto:max.haureus@gmail.com'>Max Haureus</a></strong>
    <ul>
      <li>Swedish translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/16196003?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/kebabinjeneus'>Lars</a></strong>
    <ul>
      <li>Dutch translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/47820557?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/MickLesk'>CanbiZ</a></strong>
    <ul>
      <li>German translation.</li>
    </ul>
  </li>

  <li>
    <img src='https://avatars.githubusercontent.com/u/2262007?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/stonega'>stonegate</a></strong>
    <ul>
      <li>Mandarin translation & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/66313777?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/HiSubway'>さぶうぇい</a></strong>
    <ul>
      <li>Japanese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/66092540?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/TuranBerlin'>Yusuf Kamil Turan</a></strong>
    <ul>
      <li>Turkish translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/29723448?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/yulog'>yulog</a></strong>
    <ul>
      <li>Update Japanese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/25613162?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/ejacquemoud'>ejacquemoud</a></strong>
    <ul>
      <li>Update French translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/11423362?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/maisondasilva'>Maison</a></strong>
    <ul>
      <li>Update Portuguese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/64814866?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/mi875'>mi875</a></strong>
    <ul>
      <li>Update Japanese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/74368520?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/Lucifer25x'>Lucifer25x</a></strong>
    <ul>
      <li>Add Azerbaijani & update Turkish translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/50566073?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/0xj0hn'>0xj0hn</a></strong>
    <ul>
      <li>Add Persian translation.</li>
    </ul>
  </li>
</ul>

## Compiling

- [Compiling without private packages](#compiling-without-private-packages)
- [Compiling with private packages](#compiling-with-private-packages)

Ensure that you have Flutter SDK & the required toolchain e.g. Visual Studio for Windows, Android Studio for Android installed.

```
git clone https://github.com/harmonoid/harmonoid.git --single-branch --recursive --branch master
cd harmonoid
flutter build windows
flutter build linux
...
```

### Compiling without private packages

See [reasons to not provide private packages openly](#reasons-to-not-provide-private-packages-openly) first.

You can still compile Harmonoid yourself by removing references to following private plugins & replacing them with my following other _already publicly available_ packages:
|Private package |Open-source alternative |Notes |
|------------------|---------------------------|--------|
|[libmpv.dart](https://github.com/harmonoid/libmpv.dart)|[dart_vlc](https://github.com/alexmercerind/dart_vlc) & [flutter_media_metadata](https://github.com/alexmercerind/flutter_media_metadata)| YouTube playback may not work & performance may not be as _tuned_. The resultant bundle size _may_ be larger in size.|
|[smtc-win32](https://github.com/harmonoid/smtc-win32)|[libwinmedia](https://github.com/harmonoid/libwinmedia)| libwinmedia was used in earlier versions of application for media playback & still available under MIT license.|
|[mpris_service.dart](https://github.com/harmonoid/mpris_service.dart)| - | No alternatives available. |
|[harmonoid_visual_assets](https://github.com/harmonoid/harmonoid_visual_assets)| - | Contains iconography & pictures used within the project. You can simply disable.|

### Compiling with private packages

As of now, if you wish to gain access to all the private packages used in [Harmonoid](https://github.com/harmonoid/harmonoid), you may become a [Patreon](https://www.patreon.com/harmonoid). You'll be given all the private packages & lifetime updates to them (+ other perks).

### Reasons to not provide private packages openly

1. I no longer wish to share my code openly for free.
2. I wish to keep the project-specific packages private since I have spent a lot of time on those.
3. The enforcement of open-source licenses is REALLY hard & I can't bear my work getting stolen.
4. After a long run of maintaining open-source packages at [my GitHub profile](https://github.com/alexmercerind), things haven't been very rewarding to say the least. Simply, I no longer want to set my code free in this project.
5. I don't want people to re-distribute (or even sell) my work without my permission on their websites or distribute from their privately owned servers.
6. I don't feel safe putting my work publicly anymore.
7. Users still can compile their own [open version](#compiling-without-private-packages) of the app (if they don't wish to acquire the private packages).
8. I like to get paid for my work & software-development is not _cheap_ either in terms of time spent or resources used.
9. The new version of the app is complete rewrite & it no longer is the _old app_.
10. With no doubt, there are better open-source alternatives present right now. But, we've just started & see [limitations](#limitations) for more details.

## License

Source code and official releases/binaries are distributed under our [End-User License Agreement for Harmonoid (EULA)](./EULA.txt).

## Third-Party Credits

- Harmonoid is (for the most part) written in Dart programming language using [Flutter SDK](https://github.com/flutter/flutter). Refrences to all the other external "plugins" & "packages" used at the time of building application can be found [here](./pubspec.yaml).

- Harmonoid uses a modified version of [libmpv](https://github.com/mpv-player/mpv/tree/master/libmpv) for media playback capabilities on desktop. The compilation setup & other information can be found [here](https://github.com/alexmercerind/harmonoid-custom-codec). The application bundles a minimal & LGPL compilant version of [mpv](https://github.com/mpv-player/mpv) shared library (`mpv-2.dll`). Users are free to update/change to their own preferred libmpv by replacing the `mpv-2.dll` file present in Harmonoid's application directory.

## Bonus

Well you've scrolled this down... How about seeing more ✨ _colorful_ ✨ stuff.

<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/4.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/2.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/3.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/4.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/5.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/0.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/1.jpeg?raw=true'></img>
